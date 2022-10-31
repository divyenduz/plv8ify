import fs from 'fs'
import { inject, injectable } from 'inversify'
import 'reflect-metadata'
import TYPES from 'src/interfaces/types'
import { match } from 'ts-pattern'

interface GetPLV8SQLFunctionArgs {
  fn: TSFunction
  scopePrefix: string
  pgFunctionDelimiter: string
  mode: Mode
  bundledJs: string
  fallbackReturnType: string
  defaultVolatility: Volatility
}

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

  build(options: BundleArgs) {
    return this._bundler.bundle(options)
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

getScopedName(fn: TSFunction, scopePrefix: string) {
  const scopedName = scopePrefix + '_' + fn.name
  return scopedName
}

  getFileName(outputFolder: string, fn: TSFunction, scopePrefix: string) {
    const scopedName = this.getScopedName(fn, scopePrefix)
    return `${outputFolder}/${scopedName}.plv8.sql`
  }

  getFunctions() {
    return this._tsCompiler.getFunctions().map(fn => {
      return {
        ...fn,
        returnType: this._typeMap[fn.returnType]
      }
    })
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
    fns,
    scopePrefix,
    pgFunctionDelimiter,
    mode,
    bundledJs,
    fallbackReturnType,
    defaultVolatility,
    outputFolder
  }: GetPLV8SQLFunctionsArgs) {
    const sqls = fns.map(fn => {
      return {
        filename: this.getFileName(outputFolder, fn, scopePrefix),
        sql: this.getPLV8SQLFunction({
          fn,
    scopePrefix,
    pgFunctionDelimiter,
    mode,
    bundledJs,
    fallbackReturnType,
    defaultVolatility
        })
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
    defaultVolatility
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
