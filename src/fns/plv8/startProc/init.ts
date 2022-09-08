import dedent = require('dedent')
import { Volatility } from '../../../'

export const getInitFunctionName = (scopePrefix) => scopePrefix + '_init'

interface Options {
  fnName: string
  source: string
  volatility: Volatility
}

export const getInitFunction = ({
  fnName, 
  source,
  volatility
}: Options) =>
  dedent(`DROP FUNCTION IF EXISTS ${fnName}();
CREATE OR REPLACE FUNCTION ${fnName}() RETURNS VOID AS $$
${source}
$$ LANGUAGE plv8 ${volatility} STRICT;
`)

export const getInitFunctionFilename = (outputFolder: string, fnName: string) =>
  `${outputFolder}/${fnName}.plv8.sql`
