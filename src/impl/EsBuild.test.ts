import tap from 'tap'

import { EsBuild } from './EsBuild'

tap.test('getBundleJs - inline mode', async (t) => {
  const esbuild = new EsBuild()
  const js = await esbuild.bundle({
    inputFile: './src/test-fixtures/input.fixture.ts',
    mode: 'inline',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.matchSnapshot(js)
})

tap.test('getBundleJs - inline start_proc', async (t) => {
  const esbuild = new EsBuild()
  const js = await esbuild.bundle({
    inputFile: './src/test-fixtures/input.fixture.ts',
    mode: 'start_proc',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.matchSnapshot(js)
})

tap.test('getBundleJs - bad syntax', async (t) => {
  const esbuild = new EsBuild()
  const js = esbuild.bundle({
    inputFile: './src/test-fixtures/bad.fixture.ts',
    mode: 'start_proc',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.rejects(js)
})

tap.test('getBundleJs - newline template', async (t) => {
  const esbuild = new EsBuild()
  const js = await esbuild.bundle({
    inputFile: './src/test-fixtures/newline-template.fixture.ts',
    mode: 'start_proc',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.matchSnapshot(js)
})

tap.test('getBundleJs - newline string', async (t) => {
  const esbuild = new EsBuild()
  const js = await esbuild.bundle({
    inputFile: './src/test-fixtures/newline-string.fixture.ts',
    mode: 'start_proc',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.matchSnapshot(js)
})
