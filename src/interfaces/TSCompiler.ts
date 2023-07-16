export interface TSFunctionParameter {
  name: string
  type: string
}

export interface TSFunction {
  name: string
  isExported: boolean
  parameters: TSFunctionParameter[]
  comments: string[]
  returnType: string
}

export interface TSCompiler {
  createSourceFile(inputFilePath: string): void

  getFunctions: () => TSFunction[]
}
