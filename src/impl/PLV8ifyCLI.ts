import { Layer } from 'effect'
import { Mode } from 'fs'
import { BundlerType } from 'src/helpers/ParseCLI.js'
import { Bundler } from 'src/interfaces/Bundler.js'
import {
  BuildArgs,
  GetPLV8SQLFunctionsArgs,
  PLV8ify,
  Volatility,
} from 'src/interfaces/PLV8ify.js'
import {
  TSCompiler,
  TSFunction,
  TSFunctionParameter,
} from 'src/interfaces/TSCompiler.js'
import { match } from 'ts-pattern'

import { BunBuild } from './BunBuild.js'
import { EsBuild } from './EsBuild.js'
import { TsMorph } from './TsMorph.js'

interface GetPLV8SQLFunctionArgs {
  fn: TSFunction
  scopePrefix: string
  pgFunctionDelimiter: string
  mode: Mode
  bundledJs: string
  fallbackReturnType: string
  defaultVolatility: Volatility
}

interface GetInitSQLFunctionArgs {
  fn: TSFunction
  scopePrefix: string
  bundledJs: string
  volatility: Volatility
}

export class PLV8ifyCLIImpl implements PLV8ify {
  private _bundler: Bundler
  private _tsCompiler: TSCompiler

  private _typeMap = {
    number: 'float8',
    string: 'text',
    boolean: 'boolean',
    trigger: 'TRIGGER',
  }

  constructor(bundler: BundlerType = 'esbuild') {
    this._bundler = match(bundler)
      .with('esbuild', () => new EsBuild())
      .with('bun', () => new BunBuild())
      .exhaustive()

    this._tsCompiler = new TsMorph()
  }

  init(inputFilePath: string) {
    this._tsCompiler.createSourceFile(inputFilePath)
  }

  private removeExportBlock(bundledJs: string) {
    return bundledJs.replace(/export\s*{[^}]*};/gs, '')
  }

  async build({ mode, inputFile, scopePrefix }: BuildArgs) {
    const bundledJsR = await this._bundler.bundle({
      inputFile,
    })
    const bundledJs = this.removeExportBlock(bundledJsR)
    const modeAdjustedBundledJs = match(mode)
      .with('inline', () => bundledJs)
      .with('start_proc', () =>
        // Remove var from var plv8ify to make it attach to the global scope in start_proc mode
        bundledJs.replace(`var ${scopePrefix} =`, `this.${scopePrefix} =`)
      )
      .with('bundle', () =>
        // Remove var from var plv8ify to make it attach to the global scope in start_proc mode
        bundledJs.replace(`var ${scopePrefix} =`, `globalThis.${scopePrefix} =`)
      )
      .exhaustive()
    return modeAdjustedBundledJs
  }

  private getScopedName(fn: TSFunction, scopePrefix: string) {
    const scopedName = scopePrefix + '_' + fn.name
    return scopedName
  }

  private getFileName(
    outputFolder: string,
    fn: TSFunction,
    scopePrefix: string
  ) {
    const scopedName = this.getScopedName(fn, scopePrefix)
    return `${outputFolder}/${scopedName}.plv8.sql`
  }

  private getFunctions() {
    return this._tsCompiler.getFunctions().map((fn) => {
      if (this.getFunctionTrigger(fn)) {
        fn.returnType = 'trigger'
      }
      return {
        ...fn,
        returnType: this._typeMap[fn.returnType],
      }
    })
  }

  private getExportedFunctions() {
    return this.getFunctions().filter((fn) => fn.isExported)
  }

  private getFunctionVolatility(fn: TSFunction, defaultVolatility: Volatility) {
    const volatilityStr = '//@plv8ify-volatility-'
    const comments = fn.comments
    const volatility = (comments
      .filter((comment) => comment.includes(volatilityStr))
      .map((comment) => comment.replace(volatilityStr, ''))[0] ||
      defaultVolatility) as Volatility
    return volatility
  }

  private getFunctionTrigger(fn: TSFunction) {
    const triggerStr = '//@plv8ify-trigger'
    const comments = fn.comments
    const trigger = comments.filter((comment) => comment.includes(triggerStr))
      .length
      ? true
      : false
    return trigger
  }

  // Input: parsed parameters, output of FunctionDeclaratioin.getParameters()
  // Output: SQL string of bind params
  private getSQLParametersString(
    parameters: TSFunctionParameter[],
    fallbackReturnType: string
  ) {
    return parameters
      .map((p) => {
        const { name, type } = p
        const mappedType = this._typeMap[type] || fallbackReturnType
        return `${name} ${mappedType}`
      })
      .join(',')
  }

  private getJSParametersString(parameters: TSFunctionParameter[]) {
    return parameters
      .map((p) => {
        const { name } = p
        return `${name}`
      })
      .join(',')
  }

  getPLV8SQLFunctions({
    scopePrefix,
    pgFunctionDelimiter,
    mode,
    bundledJs,
    fallbackReturnType,
    defaultVolatility,
    outputFolder,
  }: GetPLV8SQLFunctionsArgs) {
    const fns = this.getExportedFunctions()
    const sqls = fns.map((fn) => {
      return {
        filename: this.getFileName(outputFolder, fn, scopePrefix),
        sql: this.getPLV8SQLFunction({
          fn,
          scopePrefix,
          pgFunctionDelimiter,
          mode,
          bundledJs,
          fallbackReturnType,
          defaultVolatility,
        }),
      }
    })

    let startProcSQLs = []
    if (mode === 'start_proc' || mode === 'bundle') {
      // -- PLV8 + Server
      const initFunctionName = 'init'
      const virtualInitFn = {
        name: initFunctionName,
      } as TSFunction // TODO: fixme, risky because it doesn't have all the properties of a virtual function

      const initFunction = this.getInitSQLFunction({
        fn: virtualInitFn,
        scopePrefix,
        bundledJs,
        volatility: defaultVolatility,
      })
      const initFileName = this.getFileName(
        outputFolder,
        virtualInitFn,
        scopePrefix
      )
      startProcSQLs.push({
        filename: initFileName,
        sql: initFunction,
      })
    }

    if (mode === 'start_proc') {
      const startFunctionName = 'start'
      const virtualStartFn = {
        name: startFunctionName,
      } as TSFunction // TODO: fixme, risky because it doesn't have all the properties of a virtual function
      const startProcSQLScript = this.getStartProcSQLScript({ scopePrefix })
      const startProcFileName = this.getFileName(
        outputFolder,
        virtualStartFn,
        scopePrefix
      )
      startProcSQLs.push({
        filename: startProcFileName,
        sql: startProcSQLScript,
      })
    }

    return sqls.concat(startProcSQLs)
  }

  getPLV8SQLFunction({
    fn,
    scopePrefix,
    pgFunctionDelimiter,
    mode,
    bundledJs,
    fallbackReturnType,
    defaultVolatility,
  }: GetPLV8SQLFunctionArgs) {
    const scopedName = scopePrefix + '_' + fn.name
    if (this.getFunctionTrigger(fn)) {
      fn.returnType = 'TRIGGER'
    }

    const sqlParametersString =
      fn.returnType && fn.returnType.toUpperCase() === 'TRIGGER'
        ? ''
        : this.getSQLParametersString(fn.parameters, fallbackReturnType)
    const jsParametersString = this.getJSParametersString(fn.parameters)
    const volatility = this.getFunctionVolatility(fn, defaultVolatility)
    const returnType = fn.returnType || fallbackReturnType

    return [
      `DROP FUNCTION IF EXISTS ${scopedName}(${sqlParametersString});`,
      `CREATE OR REPLACE FUNCTION ${scopedName}(${sqlParametersString}) RETURNS ${returnType} AS ${pgFunctionDelimiter}`,
      match(mode)
        .with('inline', () => bundledJs)
        .with(
          'bundle',
          () =>
            `if (globalThis.${scopePrefix} === undefined) plv8.execute('SELECT ${scopePrefix}_init();');`
        )
        .otherwise(() => ''),
      `return ${fn.name}(${jsParametersString})`,
      '',
      `${pgFunctionDelimiter} LANGUAGE plv8 ${volatility} STRICT;`,
    ].join('\n')
  }

  // TODO: fixme, can this be replaced with getPLV8SQLFunction
  private getInitSQLFunction({
    fn,
    scopePrefix,
    bundledJs,
    volatility,
  }: GetInitSQLFunctionArgs) {
    const scopedName = scopePrefix + '_' + fn.name
    return `DROP FUNCTION IF EXISTS ${scopedName}();
CREATE OR REPLACE FUNCTION ${scopedName}() RETURNS VOID AS $$
${bundledJs}
$$ LANGUAGE plv8 ${volatility} STRICT;
`
  }

  private getStartProcSQLScript = ({ scopePrefix }) =>
    `
SET plv8.start_proc = ${scopePrefix}_init;
SELECT plv8_reset();
`
}

// TODO: this should be lazily evaluated
const plv8ify = new PLV8ifyCLIImpl()

export const PLV8ifyCLILive = Layer.succeed(
  PLV8ify,
  PLV8ify.of({
    init: (inputFilePath: string) => {
      return plv8ify.init(inputFilePath)
    },
    build: (args) => {
      return plv8ify.build(args)
    },
    getPLV8SQLFunctions: (args) => {
      return plv8ify.getPLV8SQLFunctions(args)
    },
  })
)
