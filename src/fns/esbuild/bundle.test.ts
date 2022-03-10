import tap from 'tap'

import { getBundledJs } from './bundle'

tap.test('getBundleJs - inline mode', async (t) => {
  const js = await getBundledJs({
    inputFile: './src/fns/esbuild/test-fixtures/input.fixture.ts',
    mode: 'inline',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.matchSnapshot(js)
})

tap.test('getBundleJs - inline start_proc', async (t) => {
  const js = await getBundledJs({
    inputFile: './src/fns/esbuild/test-fixtures/input.fixture.ts',
    mode: 'start_proc',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.matchSnapshot(js)
})

tap.test('getBundleJs - bad syntax', async (t) => {
  const js = getBundledJs({
    inputFile: './src/fns/esbuild/test-fixtures/bad.fixture.ts',
    mode: 'start_proc',
    outputFolder: 'plv8ify-dist',
    scopePrefix: 'plv8ify',
  })
  t.rejects(js)
})
