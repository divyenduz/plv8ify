import tap from 'tap'

import {
  getInitFunction,
  getInitFunctionFilename,
  getInitFunctionName,
} from './init'

tap.test('getInitFunctionName', async (t) => {
  const initFunctionName = getInitFunctionName('plv8ify')
  t.matchSnapshot(initFunctionName)
})

tap.test('getInitFunction', async (t) => {
  const initFunctionName = getInitFunctionName('plv8ify')
  const initFunction = getInitFunction(
    initFunctionName,
    `plv8.elog(NOTICE, plv8.version);`
  )

  t.matchSnapshot(initFunction)
})

tap.test('getInitFunctionFilename', async (t) => {
  const initFunctionFilename = getInitFunctionFilename('plv8ify-dist', 'init')
  t.matchSnapshot(initFunctionFilename)
})
