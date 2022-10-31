type Volatility = 'VOLATILE' | 'STABLE' | 'IMMUTABLE'

interface GetPLV8SQLFunctionsArgs {
  fns: TSFunction[]
  scopePrefix: string
  pgFunctionDelimiter: string
  mode: Mode
  bundledJs: string
  fallbackReturnType: string
  defaultVolatility: Volatility
  outputFolder: string // TODO: fixme, does this belong here?
}

interface PLV8ify {
  init(inputFilePath: string): void
  build: (options: BundleArgs) => Promise<string>
  write: (path: string, string: string) => void

  getScopedName(fn: TSFunction, scopePrefix: string): string

  /**
   * @description Get the name of the SQL file containing the PLV8 function that will be written to disk
   * @param {string} outputFolder
   * @param {fn} TSFunction
   * @param {string} scopePrefix
   * @returns {string} returns the path to the SQL file to be written
   */
  getFileName(outputFolder: string, fn: TSFunction, scopePrefix: string): string

  getFunctions: () => TSFunction[]

  getPLV8SQLFunctions({
    fns,
    scopePrefix,
    pgFunctionDelimiter,
    fallbackReturnType,
    mode,
    bundledJs,
  }: GetPLV8SQLFunctionsArgs): {
    filename: string
    sql: string
  }[]
}