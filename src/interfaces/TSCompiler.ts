import { Parallel, Volatility } from './PLV8ify.js'

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
  customSchema?: string
  isTrigger?: boolean
}

export type TSFunction = TSFunctionMetadata

export interface TSCompiler {
  createSourceFile(inputFilePath: string): void

  getFunctions: () => TSFunction[]
}
