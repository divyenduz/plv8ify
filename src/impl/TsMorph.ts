import { Parallel, Volatility } from 'src/interfaces/PLV8ify.js'
import {
  TSCompiler,
  TSFunction,
  TSFunctionParameter,
} from 'src/interfaces/TSCompiler.js'
import { FunctionDeclaration, Project, SourceFile, Type } from 'ts-morph'

export class TsMorph implements TSCompiler {
  private sourceFile: SourceFile

  createSourceFile(inputFilePath: string) {
    const project = new Project()
    this.sourceFile = project.addSourceFileAtPath(inputFilePath)
  }

  private getTypeName(type: Type): string {
    if (type.isArray()) {
      const elemType = type.getArrayElementType()
      return elemType ? `${this.getTypeName(elemType)}[]` : 'any[]'
    }
    if (type.isBoolean()) {
      return 'boolean'
    }
    if (type.isUnion()) {
      const unionTypes = type.getUnionTypes()
      const hasTrue = unionTypes.some(
        (t) => t.isBooleanLiteral() && t.getText() === 'true'
      )
      const hasFalse = unionTypes.some(
        (t) => t.isBooleanLiteral() && t.getText() === 'false'
      )
      const hasBoolean = hasTrue && hasFalse

      const nonBoolTypes = hasBoolean
        ? unionTypes.filter((t) => !t.isBooleanLiteral())
        : unionTypes

      const resolved = nonBoolTypes.map((t) => this.getTypeName(t))
      if (hasBoolean) {
        resolved.push('boolean')
      }
      return resolved.join(' | ')
    }
    const symbol = type.getAliasSymbol() ?? type.getSymbol()
    if (symbol) {
      const name = symbol.getName()
      if (name && !name.startsWith('__') && name !== 'Array') {
        return name
      }
    }
    return type.getText()
  }

  private getFunctionReturnType(fn: FunctionDeclaration) {
    return this.getTypeName(fn.getReturnType())
  }

  private getFunctionParameters(fn: FunctionDeclaration): TSFunctionParameter[] {
    const params = fn.getParameters()
    return params.map((p) => {
      return {
        name: p.getName(),
        type: this.getTypeName(p.getType()),
      }
    })
  }

  private parseJsDocMetadata(fn: FunctionDeclaration): {
    sqlReturnType?: string
    paramTypeOverrides?: Record<string, string>
    volatility?: Volatility
    parallel?: Parallel
    customSchema?: string
    isTrigger?: boolean
  } {
    const tags = fn.getJsDocs().flatMap((jsdoc) => jsdoc.getTags())
    let sqlReturnType: string | undefined
    const paramTypeOverrides: Record<string, string> = {}
    let volatility: Volatility | undefined
    let parallel: Parallel | undefined
    let customSchema: string | undefined
    let isTrigger: boolean | undefined

    for (const tag of tags) {
      const tagName = tag.getTagName()
      const comment = tag.getCommentText()?.trim() || ''

      if (tagName === 'plv8ify_volatility') {
        const upper = comment.toUpperCase()
        if (upper === 'STABLE' || upper === 'IMMUTABLE' || upper === 'VOLATILE') {
          volatility = upper as Volatility
        }
      } else if (tagName === 'plv8ify_parallel') {
        const upper = comment.toUpperCase()
        if (upper === 'SAFE' || upper === 'UNSAFE' || upper === 'RESTRICTED') {
          parallel = upper as Parallel
        }
      } else if (tagName === 'plv8ify_schema_name') {
        if (comment) {
          customSchema = comment
        }
      } else if (tagName === 'plv8ify_trigger') {
        isTrigger = true
      } else if (tagName === 'plv8ify_param') {
        const openBrace = comment.indexOf('{')
        const closeBrace = comment.indexOf('}', openBrace)
        if (openBrace !== -1 && closeBrace !== -1) {
          const type = comment.slice(openBrace + 1, closeBrace).trim()
          const rest = comment.slice(closeBrace + 1).trim()
          const paramName = rest.split(/\s+/)[0]
          if (paramName && type) {
            paramTypeOverrides[paramName] = type
          }
        }
      } else if (tagName === 'plv8ify_return' || tagName === 'plv8ify_returns') {
        const openBrace = comment.indexOf('{')
        const closeBrace = comment.indexOf('}', openBrace)
        if (openBrace !== -1 && closeBrace !== -1) {
          const type = comment.slice(openBrace + 1, closeBrace).trim()
          if (type) {
            sqlReturnType = type
          }
        }
      }
    }

    return {
      sqlReturnType,
      paramTypeOverrides:
        Object.keys(paramTypeOverrides).length > 0
          ? paramTypeOverrides
          : undefined,
      volatility,
      parallel,
      customSchema,
      isTrigger,
    }
  }

  getFunctions(): TSFunction[] {
    const fns = this.sourceFile.getFunctions()
    return fns.map((fn) => {
      const jsDocMeta = this.parseJsDocMetadata(fn)
      return {
        name: fn.getName(),
        isExported: fn.isExported(),
        parameters: this.getFunctionParameters(fn),
        returnType: this.getFunctionReturnType(fn),
        ...jsDocMeta,
      }
    })
  }
}
