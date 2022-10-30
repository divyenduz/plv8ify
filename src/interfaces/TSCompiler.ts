interface TSFunctionParameter {
  name: string
  type: string
}

interface TSFunction {
  name: string
  isExported: boolean
  parameters: TSFunctionParameter[] // TODO: fixme, any
  comments: string[]
  returnType: string | undefined // TODO: fixme, undefined
}

interface TSCompiler {
  createSourceFile(inputFilePath: string)

  getFunctions: () => TSFunction[]
}
