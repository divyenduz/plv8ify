// TS to JS helpers
import { ParameterDeclaration } from 'ts-morph'

interface getParamsCallArgs {
  params: ParameterDeclaration[]
}

// Input: parsed parameters, output of FunctionDeclaratioin.getParameters()
// Output: JS string of params, comma separated, that can be placed in a function call (without the curly braces)
export const getParamsCall = ({ params }: getParamsCallArgs) => {
  return params
    .map((p) => {
      const name = p.getName()
      return `${name}`
    })
    .join(',')
}
