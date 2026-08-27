import fs from 'fs'
import {
  Expression,
  Node,
  ObjectLiteralExpression,
  Project,
  SyntaxKind,
} from 'ts-morph'

export function unwrapExpression(expr: Expression): Expression {
  if (
    Node.isAsExpression(expr) ||
    Node.isTypeAssertion(expr) ||
    Node.isParenthesizedExpression(expr)
  ) {
    return unwrapExpression(expr.getExpression())
  }
  if (
    (expr as any).getExpression &&
    typeof (expr as any).getExpression === 'function'
  ) {
    const inner = (expr as any).getExpression()
    if (inner && inner !== expr) {
      return unwrapExpression(inner)
    }
  }
  return expr
}

export function extractObjectLiteral(
  objLiteral: ObjectLiteralExpression
): Record<string, string> {
  const result: Record<string, string> = {}
  for (const prop of objLiteral.getProperties()) {
    if (Node.isPropertyAssignment(prop)) {
      const name = prop.getName().replace(/^['"]|['"]$/g, '')
      let init = prop.getInitializer()
      if (init) {
        init = unwrapExpression(init)
        if (
          Node.isStringLiteral(init) ||
          Node.isNoSubstitutionTemplateLiteral(init)
        ) {
          result[name] = init.getLiteralValue()
        } else {
          result[name] = init.getText().replace(/^['"]|['"]$/g, '')
        }
      }
    }
  }
  return result
}

export function parseCustomTypeMap(
  typesFilePath?: string
): Record<string, string> {
  if (!typesFilePath || !fs.existsSync(typesFilePath)) {
    return {}
  }

  try {
    const fileContent = fs.readFileSync(typesFilePath, 'utf8')
    const trimmed = fileContent.trim()

    // Support JSON configuration files directly
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        const parsed = JSON.parse(trimmed)
        if (
          typeof parsed === 'object' &&
          parsed !== null &&
          !Array.isArray(parsed)
        ) {
          return parsed as Record<string, string>
        }
      } catch {
        // Fall through to ts-morph AST parsing
      }
    }

    const project = new Project({ useInMemoryFileSystem: true })
    const sourceFile = project.createSourceFile(typesFilePath, fileContent)

    // 1. Check for export default { ... }
    const defaultExport = sourceFile.getDefaultExportSymbol()
    if (defaultExport) {
      for (const decl of defaultExport.getDeclarations()) {
        if (Node.isExportAssignment(decl)) {
          let expr = decl.getExpression()
          if (expr) {
            expr = unwrapExpression(expr)
            if (Node.isObjectLiteralExpression(expr)) {
              return extractObjectLiteral(expr)
            }
          }
        }
      }
    }

    // 2. Check for named export or variable declaration named 'typeMap' or 'customTypeMap' or 'types'
    const variableDeclarations = sourceFile.getVariableDeclarations()
    for (const varDecl of variableDeclarations) {
      const name = varDecl.getName()
      if (
        ['typeMap', 'customTypeMap', 'types', 'default'].includes(name) ||
        variableDeclarations.length === 1
      ) {
        let init = varDecl.getInitializer()
        if (init) {
          init = unwrapExpression(init)
          if (Node.isObjectLiteralExpression(init)) {
            return extractObjectLiteral(init)
          }
        }
      }
    }

    // 3. Check for expression statements (e.g. typeMap = { ... } or module.exports = { ... })
    for (const stmt of sourceFile.getStatements()) {
      if (Node.isExpressionStatement(stmt)) {
        let expr = stmt.getExpression()
        if (expr) {
          expr = unwrapExpression(expr)
          if (Node.isBinaryExpression(expr)) {
            let right = expr.getRight()
            right = unwrapExpression(right)
            if (Node.isObjectLiteralExpression(right)) {
              return extractObjectLiteral(right)
            }
          } else if (Node.isObjectLiteralExpression(expr)) {
            return extractObjectLiteral(expr)
          }
        }
      }
    }

    // 4. Fallback: find any ObjectLiteralExpression in the AST
    const firstObj = sourceFile.getFirstDescendantByKind(
      SyntaxKind.ObjectLiteralExpression
    )
    if (firstObj) {
      return extractObjectLiteral(firstObj)
    }
  } catch {
    return {}
  }

  return {}
}
