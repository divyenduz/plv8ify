import { TSCompiler } from 'src/interfaces/TSCompiler.js'
import { FunctionDeclaration, Project, SourceFile } from 'ts-morph'

export class TsMorph implements TSCompiler {
  private sourceFile: SourceFile

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
    const fns = this.sourceFile.getFunctions()
    return fns.map((fn) => {
      return {
        name: fn.getName(),
        isExported: fn.isExported(),
        parameters: this.getFunctionParameters(fn),
        comments: this.getFunctionComments(fn),
        returnType: this.getFunctionReturnType(fn),
      }
    })
  }
}
