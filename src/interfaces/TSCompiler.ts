interface TSFunctionParameter {
  name: string
  type: string
}

interface TSFunction {
  name: string
  isExported: boolean
  parameters: TSFunctionParameter[]
  comments: string[]
  returnType: string
}

interface TSCompiler {
  createSourceFile(inputFilePath: string)

  getFunctions: () => TSFunction[]
}
