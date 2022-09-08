// TS to SQL helpers
import { ParameterDeclaration } from 'ts-morph'
import { match } from 'ts-pattern'

import { Mode, Volatility } from '../../'

const typeMap = {
  number: 'float8',
  string: 'text',
  boolean: 'boolean',
}

interface GetBindParamsArgs {
  params: ParameterDeclaration[]
  fallbackType: string
  debug: boolean
}

// Input: parsed parameters, output of FunctionDeclaratioin.getParameters()
// Output: SQL string of bind params
export const getBindParams = ({
  params,
  fallbackType,
  debug, // TODO: use a proper debugging library
}: GetBindParamsArgs) => {
  return params
    .map((p) => {
      const name = p.getName()
      const type = p.getType().getText()
      const mappedType = typeMap[type] || fallbackType
      if (debug && !typeMap[type]) {
        console.log(`DEBUG: Using fallback type for ${type}`)
      }
      return `${name} ${mappedType}`
    })
    .join(',')
}

interface GetSQLFunctionArgs {
  scopedName: string
  fnName: string
  pgFunctionDelimiter: string
  paramsBind: string
  paramsCall: string
  fallbackType: string
  mode: Mode
  bundledJs: string
  volatility: Volatility
}

export const getSQLFunction = ({
  scopedName,
  fnName,
  pgFunctionDelimiter,
  paramsBind,
  paramsCall,
  fallbackType,
  mode,
  bundledJs,
  volatility
}: GetSQLFunctionArgs) => {
  return [
    `DROP FUNCTION IF EXISTS ${scopedName}(${paramsBind});`,
    `CREATE OR REPLACE FUNCTION ${scopedName}(${paramsBind}) RETURNS ${fallbackType} AS ${pgFunctionDelimiter}`,
    match(mode)
      .with('inline', () => bundledJs)
      .otherwise(() => ''),
    `return plv8ify.${fnName}(${paramsCall})`,
    '',
    `${pgFunctionDelimiter} LANGUAGE plv8 ${volatility} STRICT;`,
  ].join('\n')
}

interface GetSQLFunctionFileNameArgs {
  outputFolder: string
  scopedName: string
}

export const getSQLFunctionFileName = ({
  outputFolder,
  scopedName,
}: GetSQLFunctionFileNameArgs) => {
  return `${outputFolder}/${scopedName}.plv8.sql`
}
