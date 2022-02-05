import tap from 'tap'

import { getClientInitFileName, getClientInitSQL } from './client'

tap.test('getClientInitSQL', async (t) => {
  const sql = getClientInitSQL()
  t.matchSnapshot(sql)
})

tap.test('getClientInitFileName', async (t) => {
  const filename = getClientInitFileName('plv8ify-dist')
  t.matchSnapshot(filename)
})
