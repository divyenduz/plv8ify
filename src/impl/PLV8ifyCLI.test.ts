import tap from 'tap'

import { PLV8ifyCLI } from './PLV8ifyCLI'

tap.test('getSQLFunction with parameters', async (t) => {
  const plv8ify = new PLV8ifyCLI()
  const sql = plv8ify.getPLV8SQLFunction({
    fn: {
      name: 'test',
      parameters: [],
      comments: [],
    },
    scopePrefix: 'plv8ify',
    mode: 'inline',
    defaultVolatility: 'IMMUTABLE',
    bundledJs: console.log('hello'),
    pgFunctionDelimiter: '$plv8ify$',
    fallbackReturnType: 'JSONB',
  })
  t.matchSnapshot(sql)
})

tap.test('getSQLFunction with delimiter', async (t) => {
  const plv8ify = new PLV8ifyCLI()
  const sql = plv8ify.getPLV8SQLFunction({
    fn: {
      name: 'test',
      parameters: [],
      comments: [],
    },
    scopePrefix: 'plv8ify',
    mode: 'inline',
    defaultVolatility: 'IMMUTABLE',
    bundledJs: console.log('hello'),
    pgFunctionDelimiter: '$function$',
    fallbackReturnType: 'JSONB',
  })

  t.matchSnapshot(sql)
})
