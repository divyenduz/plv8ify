import { injectable } from 'inversify'
import 'reflect-metadata'
import { FunctionDeclaration, Project, SourceFile } from 'ts-morph'

// TODO: this is exported only for tests, is that needed?
@injectable()
export class TsMorph implements TSCompiler {
  private sourceFile: SourceFile

  // TODO: fixme, figure out how to do constructors with literal variables in inversify
  // https://stackoverflow.com/questions/37439798/inversifyjs-injecting-literal-constructor-parameters
  createSourceFile(inputFilePath: string) {
    const project = new Project()
    // TODO: needs access to the file system, can this be pure?
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

    // TODO: fixme, this class can't be aware of PLV8
    const typeMap = {
      number: 'float8',
      string: 'text',
      boolean: 'boolean',
    }

    const fns = this.sourceFile.getFunctions()
    return fns.map((fn) => {
      return {
        name: fn.getName(),
        isExported: fn.isExported(),
        parameters: this.getFunctionParameters(fn),
        comments: this.getFunctionComments(fn),
        returnType: typeMap[this.getFunctionReturnType(fn)],
      }
    })
  }
}
