import dedent = require('dedent')

export const getInitFunctionName = (scopePrefix) => scopePrefix + '_init'

export const getInitFunction = (fnName: string, source: string) =>
  dedent(`DROP FUNCTION IF EXISTS ${fnName}();
CREATE OR REPLACE FUNCTION ${fnName}() RETURNS VOID AS $$
${source}
$$ LANGUAGE plv8 IMMUTABLE STRICT;
`)

export const getInitFunctionFilename = (outputFolder: string, fnName: string) =>
  `${outputFolder}/${fnName}.plv8.sql`
