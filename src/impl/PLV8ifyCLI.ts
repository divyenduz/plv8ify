import fs, { Mode } from 'fs'
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

export class PLV8ifyCLI implements PLV8ify {
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

  init(inputFilePath: string, typesFilePath?: string) {
    if (fs.existsSync(inputFilePath)) {
      this._tsCompiler.createSourceFile(inputFilePath)
    }
    this._typeMap = {
      ...this._typeMap,
      ...this.getCustomTypeMap(typesFilePath),
    }
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

  private writeFile(filePath: string, content: string) {
    try {
      fs.unlinkSync(filePath)
    } catch (e) {}
    fs.writeFileSync(filePath, content)
  }

  write(path: string, string: string) {
    this.writeFile(path, string)
  }

  private getCustomTypeMap(typesFilePath: string) {
    let customTypeMap = null
    let typeMap = {}
    if (fs.existsSync(typesFilePath)) {
      customTypeMap = fs.readFileSync(typesFilePath, 'utf8')
      eval(customTypeMap)
      return typeMap
    }
    return {}
  }

  private getScopedName(fn: TSFunction, scopePrefix: string) {
    const scopedName = scopePrefix + fn.name
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
  private getTypeFromMap(type: string) {
    const typeLocal = type.split('.').pop()
    return this._typeMap[typeLocal ?? type]
  }

  private getFunctions() {
    return this._tsCompiler.getFunctions().map((fn) => {
      if (this.getFunctionTrigger(fn)) {
        fn.returnType = 'trigger'
      }
      return {
        ...fn,
        returnType: this.getTypeFromMap(fn.returnType),
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

  private getFunctionCustomSchema(fn: TSFunction) {
    const schemaStr = '//@plv8ify-schema-name '
    const comments = fn.comments
    const schema = comments
      .filter((comment) => comment.includes(schemaStr))
      .map((comment) => comment.replace(schemaStr, ''))[0]
    return schema
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
        const mappedType = this.getTypeFromMap(type) || fallbackReturnType
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
      const virtualInitFn: TSFunction = {
        name: '_init',
        comments: [],
        isExported: false,
        parameters: [],
        returnType: 'void',
      }

      const initFunction = this.getPLV8SQLFunction({
        fn: virtualInitFn,
        scopePrefix,
        pgFunctionDelimiter: '$$',
        mode: 'inline',
        bundledJs,
        defaultVolatility,
        fallbackReturnType: 'void',
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
      const virtualStartFn: TSFunction = {
        name: startFunctionName,
        comments: [],
        isExported: false,
        parameters: [],
        returnType: 'void',
      }
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
    const customSchema = this.getFunctionCustomSchema(fn)
    const scopedName =
      (customSchema ? customSchema + '.' : '') + scopePrefix + fn.name
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
      match(returnType.toLowerCase())
        .with('void', () => '')
        .otherwise(() => `return ${fn.name}(${jsParametersString})`),
      '',
      `${pgFunctionDelimiter} LANGUAGE plv8 ${volatility} STRICT;`,
    ].join('\n')
  }

  private getStartProcSQLScript = ({ scopePrefix }) =>
    `
SET plv8.start_proc = ${scopePrefix}_init;
SELECT plv8_reset();
`
}
