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
    {
      fnName: initFunctionName,
      source: `plv8.elog(NOTICE, plv8.version);`,
      volatility: 'IMMUTABLE'
    }

  )

  t.matchSnapshot(initFunction)
})

tap.test('getInitFunctionFilename', async (t) => {
  const initFunctionFilename = getInitFunctionFilename('plv8ify-dist', 'init')
  t.matchSnapshot(initFunctionFilename)
})
