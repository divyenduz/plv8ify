import fs, { Mode } from 'fs'
import { BundlerType } from 'src/helpers/ParseCLI.js'
import { Bundler } from 'src/interfaces/Bundler.js'
import {
  BuildArgs,
  GetPLV8SQLFunctionsArgs,
  PLV8ify,
  Volatility,
  Parallel,
} from 'src/interfaces/PLV8ify.js'
import {
  TSCompiler,
  TSFunction,
  TSFunctionParameter,
} from 'src/interfaces/TSCompiler.js'
import { Project } from 'ts-morph'
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

/** configuration for how a JS function should be transformed into a SQL function */
type FnSqlConfig = {
  paramTypeMapping: {
    [name: string]: string | null
  }
  volatility: Volatility | null,
  parallel: Parallel | null,
  sqlReturnType: string | null,
  customSchema: string,
  trigger: boolean,
}

export class PLV8ifyCLI implements PLV8ify {
  private _bundler: Bundler
  private _tsCompiler: TSCompiler
  private bundleId: string | number
  private _exportMap: Record<string, string> = {}

  private _typeMap: Record<string, string> = {
    number: 'float8',
    string: 'text',
    boolean: 'boolean',
  }

  constructor(bundler: BundlerType = 'esbuild', bundleId?: string | number) {
    this._bundler = match(bundler)
      .with('esbuild', () => new EsBuild())
      .with('bun', () => new BunBuild())
      .exhaustive()

    this._tsCompiler = new TsMorph()
    this.bundleId = bundleId !== undefined ? bundleId : Date.now()
  }

  private getBundleIdLiteral(): string {
    return typeof this.bundleId === 'string' && isNaN(Number(this.bundleId))
      ? JSON.stringify(this.bundleId)
      : String(this.bundleId)
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

  private extractExports(bundledJs: string): {
    exportMap: Record<string, string>
    cleanJs: string
  } {
    const project = new Project({ useInMemoryFileSystem: true })
    const sourceFile = project.createSourceFile('bundle.js', bundledJs)
    const exportMap: Record<string, string> = {}

    for (const exportDecl of sourceFile.getExportDeclarations()) {
      for (const namedExport of exportDecl.getNamedExports()) {
        const alias = namedExport.getAliasNode()
        if (alias) {
          let aliasText = alias.getText()
          if (
            (aliasText.startsWith('"') && aliasText.endsWith('"')) ||
            (aliasText.startsWith("'") && aliasText.endsWith("'"))
          ) {
            aliasText = aliasText.slice(1, -1)
          }
          exportMap[aliasText] = namedExport.getName()
        } else {
          exportMap[namedExport.getName()] = namedExport.getName()
        }
      }
      exportDecl.remove()
    }

    const cleanJs = sourceFile.getFullText()
    return { exportMap, cleanJs }
  }

  async build({ inputFile, esbuildDefine }: BuildArgs) {
    const bundledJsR = await this._bundler.bundle({
      inputFile,
      define: esbuildDefine,
    })
    const { exportMap, cleanJs: bundledJs } = this.extractExports(bundledJsR)
    this._exportMap = exportMap
    return bundledJs
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
    return this._typeMap[type]
  }

  private getFunctions() {
    return this._tsCompiler.getFunctions()
  }

  private getExportedFunctions() {
    return this.getFunctions().filter((fn) => fn.isExported)
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
    if (bundledJs.includes('export')) {
      const { exportMap, cleanJs } = this.extractExports(bundledJs)
      this._exportMap = { ...this._exportMap, ...exportMap }
      bundledJs = cleanJs
    }

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
        isExported: false,
        parameters: [],
        returnType: 'void',
      }

      if (mode === 'bundle' || mode === 'start_proc') {
        // make the function declarations available in the global scope
        for (const fn of fns) {
          const localBinding = this._exportMap[fn.name] || fn.name
          bundledJs += `globalThis.${fn.name} = ${localBinding};\n`
        }

        // set a global symbol so that we can check if the init function has been called
        if (mode === 'bundle') {
          bundledJs += `globalThis[Symbol.for('${scopePrefix}_initialized')] = ${this.getBundleIdLiteral()};\n`
        }
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

  /**
   * handles all the processing for jsdoc
   */
  private getFnSqlConfig (fn: TSFunction): FnSqlConfig {
    const config: FnSqlConfig = {
      // defaults
      paramTypeMapping: {},
      volatility: fn.volatility ?? null,
      parallel: fn.parallel ?? null,
      sqlReturnType:
        fn.sqlReturnType ?? (this.getTypeFromMap(fn.returnType) || null),
      customSchema: fn.customSchema ?? '',
      trigger: fn.isTrigger ?? false,
    }

    // default param type mapping
    for (const param of fn.parameters) {
      config.paramTypeMapping[param.name] =
        fn.paramTypeOverrides?.[param.name] ??
        (this.getTypeFromMap(param.type) || null)
    }

    // triggers don't have return types
    if (config.trigger) config.sqlReturnType = 'TRIGGER'

    return config;
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
    let {
      customSchema,
      paramTypeMapping,
      volatility,
      parallel,
      sqlReturnType,
      trigger
    } = this.getFnSqlConfig(fn);
    if (!volatility) volatility = defaultVolatility
    if (!sqlReturnType) sqlReturnType = fallbackReturnType

    const sqlParametersString = trigger
      ? '' // triggers don't have parameters
      : fn.parameters.map(param => `${param.name} ${paramTypeMapping[param.name] || fallbackReturnType}`).join(',')

    const jsParametersString = fn.parameters.map(param => param.name).join(',')

    const scopedName =
      (customSchema ? customSchema + '.' : '') + scopePrefix + fn.name

    const localFnName = this._exportMap[fn.name] || fn.name
    const targetCallName = mode === 'inline' ? localFnName : fn.name

    return [
      `DROP FUNCTION IF EXISTS ${scopedName}(${sqlParametersString});`,
      `CREATE OR REPLACE FUNCTION ${scopedName}(${sqlParametersString}) RETURNS ${sqlReturnType} AS ${pgFunctionDelimiter}`,
      match(mode)
        .with('inline', () => bundledJs)
        .with(
          'bundle',
          () =>
            `if (globalThis[Symbol.for('${scopePrefix}_initialized')] !== ${this.getBundleIdLiteral()}) plv8.execute('SELECT ${scopePrefix}_init();');`
        )
        .otherwise(() => ''),
      match(sqlReturnType.toLowerCase())
        .with('void', () => '')
        .otherwise(() => `return ${targetCallName}(${jsParametersString})`),
      '',
      `${pgFunctionDelimiter} LANGUAGE plv8 ${volatility}${parallel ? ` PARALLEL ${parallel}` : ''} STRICT;`,
    ].join('\n')
  }

  private getStartProcSQLScript = ({ scopePrefix }) =>
    `
SET plv8.start_proc = ${scopePrefix}_init;
SELECT plv8_reset();
`
}
