import tap from 'tap'

import { EsBuild } from './EsBuild'

tap.test('getBundleJs - inline mode', async (t) => {
  const esbuild = new EsBuild()
  const js = await esbuild.bundle({
    inputFile: './src/test-fixtures/input.fixture.ts',
  })
  t.matchSnapshot(js)
})

tap.test('getBundleJs - bad syntax', async (t) => {
  const esbuild = new EsBuild()
  const js = esbuild.bundle({
    inputFile: './src/test-fixtures/bad.fixture.ts',
  })
  t.rejects(js)
})

tap.test('getBundleJs - newline template', async (t) => {
  const esbuild = new EsBuild()
  const js = await esbuild.bundle({
    inputFile: './src/test-fixtures/newline-template.fixture.ts',
  })
  t.matchSnapshot(js)
})

tap.test('getBundleJs - newline string', async (t) => {
  const esbuild = new EsBuild()
  const js = await esbuild.bundle({
    inputFile: './src/test-fixtures/newline-string.fixture.ts',
  })
  t.matchSnapshot(js)
})
