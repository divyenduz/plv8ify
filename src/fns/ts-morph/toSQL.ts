// TS to SQL helpers
import dedent from 'dedent'
import { ParameterDeclaration } from 'ts-morph'
import { match } from 'ts-pattern'

import { Mode } from '../..'

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
  debug,
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
  paramsBind: string
  paramsCall: string
  fallbackType: string
  mode: Mode
  bundledJs: string
}

export const getSQLFunction = ({
  scopedName,
  paramsBind,
  paramsCall,
  fallbackType,
  mode,
  bundledJs,
}: GetSQLFunctionArgs) => {
  return dedent(`DROP FUNCTION IF EXISTS ${scopedName}(${paramsBind});
    CREATE OR REPLACE FUNCTION ${scopedName}(${paramsBind}) RETURNS ${fallbackType} AS $$
    ${
      // In inline mode, write the bundle text directly to the function
      match(mode)
        .with('inline', () => dedent(`${bundledJs}`))
        .otherwise(() => ``)
    }
    return plv8ify.${name}(${paramsCall})
    
    $$ LANGUAGE plv8 IMMUTABLE STRICT;`)
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
