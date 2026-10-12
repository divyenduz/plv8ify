import { Parallel, Security, Volatility } from './PLV8ify.js'

export interface TSFunctionParameter {
  name: string
  type: string
  /** the TypeScript initializer when it is a literal (null, a string, a number, true or false): rendered as the SQL DEFAULT */
  defaultLiteral?: string
}

export interface TSFunctionParamOverride {
  paramName: string
  sqlType: string
}

export interface TSFunctionMetadata {
  name: string
  isExported: boolean
  parameters: TSFunctionParameter[]
  returnType: string
  sqlReturnType?: string
  paramTypeOverrides?: Record<string, string>
  volatility?: Volatility
  parallel?: Parallel
  security?: Security
  searchPath?: string
  customSchema?: string
  isTrigger?: boolean
  /** false renders CALLED ON NULL INPUT instead of STRICT (`@plv8ify_strict false`) */
  strict?: boolean
  grants?: string[]
  revokes?: string[]
}

export type TSFunction = TSFunctionMetadata

export interface TSCompiler {
  createSourceFile(inputFilePath: string): void

  getFunctions: () => TSFunction[]
}
