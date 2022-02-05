import dedent = require('dedent')

export const getClientInitSQL = () =>
  dedent(`
SET plv8.start_proc = plv8ify_init;
SELECT plv8_reset();
`)

export const getClientInitFileName = (outputFolder: string) =>
  `${outputFolder}/start.plv8.sql`
