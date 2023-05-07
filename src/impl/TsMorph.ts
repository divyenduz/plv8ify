import fs from 'fs'
import { injectable } from 'inversify'
import { EventEmitter } from 'stream'
import {
  DeclarationName,
  FunctionDeclaration,
  Project,
  SourceFile,
} from 'ts-morph'

// TODO: fixme, this is exported only for tests, is that needed?
@injectable()
export class TsMorph implements TSCompiler {
  private sourceFile: SourceFile

  // TODO: figure out how to do constructors with literal variables in inversify
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

  private resolveExportDeclarations(
    eventEmitter: EventEmitter,
    declaration: DeclarationName,
    resolvedFiles = new Set<string>()
  ) {
    const symbol = declaration.getSymbol()
    if (!symbol) {
      return
    }

    // Get the source file of the declaration
    const sourceFile = declaration.getSourceFile()
    if (
      sourceFile === this.sourceFile ||
      resolvedFiles.has(sourceFile.getFilePath())
    ) {
      return
    }

    // Add the file to the set of resolved files
    resolvedFiles.add(sourceFile.getFilePath())

    const valueDeclaration = symbol.getValueDeclaration()
    if (!valueDeclaration) {
      return
    }

    // console.log(
    //   `Resolved symbol "${symbol.getName()}" in file "${sourceFile.getFilePath()}":\n${valueDeclaration.getText()}\n`
    // )
    eventEmitter.emit('fn', valueDeclaration.getText())

    const exports = sourceFile.getExportSymbols()
    exports.forEach((exportSymbol) =>
      this.resolveExportDeclarations(
        eventEmitter,
        //@ts-expect-error
        exportSymbol.getDeclarations()[0],
        resolvedFiles
      )
    )
  }

  getFunctions() {
    const eventEmitter = new EventEmitter()
    let fnStrings = []
    eventEmitter.on('fn', (fn) => {
      fnStrings.push(fn)
    })

    const exports = this.sourceFile.getExportSymbols()
    exports.forEach((exportSymbol) => {
      const declarations = exportSymbol.getDeclarations()
      console.log(declarations.length)
      if (declarations.length > 0) {
        // @ts-expect-error
        this.resolveExportDeclarations(eventEmitter, declarations[0])
      }
    })

    fs.writeFileSync('fake.ts', fnStrings.join('\n'))

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
