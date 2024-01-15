import { Context } from 'effect'

export type Volatility = 'VOLATILE' | 'STABLE' | 'IMMUTABLE'
export type Mode = 'inline' | 'start_proc' | 'bundle'

export interface BuildArgs {
  mode: Mode
  inputFile: string
  scopePrefix: string
}

export interface GetPLV8SQLFunctionsArgs {
  scopePrefix: string
  pgFunctionDelimiter: string
  mode: Mode
  bundledJs: string
  fallbackReturnType: string
  defaultVolatility: Volatility
  outputFolder: string
}

export interface PLV8ify {
  init(inputFilePath: string): void
  build: (options: BuildArgs) => Promise<string>

  getPLV8SQLFunctions({
    mode,
    scopePrefix,
    pgFunctionDelimiter,
    fallbackReturnType,
    bundledJs,
  }: GetPLV8SQLFunctionsArgs): {
    filename: string
    sql: string
  }[]
}

export const PLV8ify = Context.Tag<PLV8ify>()
