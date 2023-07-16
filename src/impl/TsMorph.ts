import assert from 'node:assert/strict'
import { TSCompiler } from 'src/interfaces/TSCompiler'
import { FunctionDeclaration, Project, SourceFile } from 'ts-morph'

export class TsMorph implements TSCompiler {
  private sourceFile?: SourceFile

  // TODO: figure out how to do constructors with literal variables in inversify
  // https://stackoverflow.com/questions/37439798/inversifyjs-injecting-literal-constructor-parameters
  createSourceFile(inputFilePath: string) {
    const project = new Project()
    this.sourceFile = project.addSourceFileAtPath(inputFilePath)
  }

  private getFunctionReturnType(fn: FunctionDeclaration) {
    return fn.getReturnType().getText()
  }

  private getFunctionParameters(fn: FunctionDeclaration) {
    const params = fn.getParameters()
    return params.map((p) => {
      return {
        name: p.getName(),
        type: p.getType().getText(),
      }
    })
  }

  private getFunctionComments(fn: FunctionDeclaration) {
    const comments = fn.getLeadingCommentRanges().map((cr) => cr.getText())
    return comments
  }

  getFunctions() {
    const fns = this.sourceFile?.getFunctions() || []
    return fns.map((fn) => {
      const fnName = fn.getName()
      assert(fnName !== undefined, 'Failed to find function name')

      return {
        name: fnName,
        isExported: fn.isExported(),
        parameters: this.getFunctionParameters(fn),
        comments: this.getFunctionComments(fn),
        returnType: this.getFunctionReturnType(fn),
      }
    })
  }
}
