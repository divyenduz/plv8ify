import tap from 'tap'

import { getSQLFunction } from './toSQL'

tap.test('getSQLFunction with parameters', async (t) => {
  const sql = getSQLFunction({
    scopedName: 'plv8ify_test',
    pgFunctionDelimiter: '$$',
    paramsBind: '',
    paramsCall: '',
    fallbackType: 'JSONB',
    mode: 'inline',
    bundledJs: 'console.log("hello")',
  })
  t.matchSnapshot(sql)
})

tap.test('getSQLFunction with delimiter', async (t) => {
  const sql = getSQLFunction({
    scopedName: 'plv8ify_test',
    pgFunctionDelimiter: '$function$',
    paramsBind: '',
    paramsCall: '',
    fallbackType: 'JSONB',
    mode: 'inline',
    bundledJs: 'console.log("hello")',
  })
  t.matchSnapshot(sql)
})
