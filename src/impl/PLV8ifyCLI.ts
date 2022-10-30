import fs from 'fs'
import { inject, injectable } from 'inversify'
import 'reflect-metadata'
import TYPES from 'src/interfaces/types'
import { match } from 'ts-pattern'

@injectable()
export class PLV8ifyCLI implements PLV8ify {
  @inject(TYPES.Bundler) private _bundler: Bundler;
  @inject(TYPES.TSCompiler) private _tsCompiler: TSCompiler;

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
    return this._tsCompiler.getFunctions()
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
    // TODO: fixme, common place for typeMap
    const typeMap = {
      number: 'float8',
      string: 'text',
      boolean: 'boolean',
    }

    return parameters
      .map((p) => {
        const { name, type } = p
        const mappedType = typeMap[type] || fallbackReturnType
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
    // TODO: fixme, fix fallback type
    const sqlParametersString = this.getSQLParametersString(
      fn.parameters,
      fallbackReturnType
    )
    const jsParametersString = this.getJSParametersString(fn.parameters)
    // TODO: fixme, fix default volatility
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
