import { Parallel, Security, Volatility } from './PLV8ify.js'

export interface TSFunctionParameter {
  name: string
  type: string
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
  customSchema?: string
  isTrigger?: boolean
  grants?: string[]
  revokes?: string[]
}

export type TSFunction = TSFunctionMetadata

export interface TSCompiler {
  createSourceFile(inputFilePath: string): void

  getFunctions: () => TSFunction[]
}
