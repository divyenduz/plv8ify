export const getClientInitSQL = () =>
  `
SET plv8.start_proc = plv8ify_init;
SELECT plv8_reset();
`

export const getClientInitFileName = (outputFolder: string) =>
  `${outputFolder}/plv8ify_start.plv8.sql`
