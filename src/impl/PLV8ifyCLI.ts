import fs from 'fs'
import { inject, injectable } from 'inversify'
import TYPES from 'src/interfaces/types'
import { match } from 'ts-pattern'
import "reflect-metadata"

interface GetPLV8SQLFunctionArgs {
  fn: TSFunction
  scopePrefix: string
  pgFunctionDelimiter: string
  mode: Mode
  bundledJs: string
  fallbackReturnType: string
  defaultVolatility: Volatility
}

// TODO: fixme, this is exported only for tests, is that needed?

@injectable()
export class PLV8ifyCLI implements PLV8ify {
  @inject(TYPES.Bundler) private _bundler: Bundler;
  @inject(TYPES.TSCompiler) private _tsCompiler: TSCompiler;

  private _typeMap = {
    number: 'float8',
    string: 'text',
    boolean: 'boolean',
  }

  init(inputFilePath: string) {
    this._tsCompiler.createSourceFile(inputFilePath)
  }

  async build({ mode, inputFile, scopePrefix }: BuildArgs) {
    const bundledJs = await this._bundler.bundle({
      inputFile,
      globalName: scopePrefix,
    })
    const modeAdjustedBundledJs = match(mode)
      .with('inline', () => bundledJs)
      .with('start_proc', () =>
        // Remove var from var plv8ify to make it attach to the global scope in start_proc mode
        bundledJs.replace(`var ${scopePrefix} =`, `this.${scopePrefix} =`)
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

  private getScopedName(fn: TSFunction, scopePrefix: string) {
    const scopedName = scopePrefix + '_' + fn.name
    return scopedName
  }

  private getFileName(outputFolder: string, fn: TSFunction, scopePrefix: string) {
    const scopedName = this.getScopedName(fn, scopePrefix)
    return `${outputFolder}/${scopedName}.plv8.sql`
  }

  private getFunctions() {
    return this._tsCompiler.getFunctions().map((fn) => {
      return {
        ...fn,
        returnType: this._typeMap[fn.returnType],
      }
    })
  }

  private getExportedFunctions() {
    return this.getFunctions().filter(fn => fn.isExported)
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
    return sqls
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
    const sqlParametersString = this.getSQLParametersString(
      fn.parameters,
      fallbackReturnType
    )
    const jsParametersString = this.getJSParametersString(fn.parameters)
    const volatility = this.getFunctionVolatility(fn, defaultVolatility)
    const returnType = fn.returnType || fallbackReturnType

    return [
      `DROP FUNCTION IF EXISTS ${scopedName}(${sqlParametersString});`,
      `CREATE OR REPLACE FUNCTION ${scopedName}(${sqlParametersString}) RETURNS ${returnType} AS ${pgFunctionDelimiter}`,
      match(mode)
        .with('inline', () => bundledJs)
        .otherwise(() => ''),
      `return plv8ify.${fn.name}(${jsParametersString})`,
      '',
      `${pgFunctionDelimiter} LANGUAGE plv8 ${volatility} STRICT;`,
    ].join('\n')
  }
}
