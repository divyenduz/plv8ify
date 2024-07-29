export interface TSFunctionParameter {
  name: string
  type: string
}

export interface TSFunction {
  name: string
  isExported: boolean
  parameters: TSFunctionParameter[]
  returnType: string
  jsdocTags: { name: string, commentText: string }[]
}

export interface TSCompiler {
  createSourceFile(inputFilePath: string)

  getFunctions: () => TSFunction[]
}
