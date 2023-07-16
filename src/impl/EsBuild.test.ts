import { describe, it, expect } from 'vitest'

import { BundlerError, EsBuild } from './EsBuild'

describe('EsBuild', () => {
  it('getBundleJs - inline mode', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/input.fixture.ts',
      globalName: 'plv8ify',
    })
    expect(js).toMatchSnapshot()
  })

  it('getBundleJs - bad syntax', async () => {
    const esbuild = new EsBuild()
    const js = esbuild.bundle({
      inputFile: './src/test-fixtures/bad.fixture.ts',
      globalName: 'plv8ify',
    })
    expect(js).rejects.toThrow(BundlerError)
  })

  it('getBundleJs - newline template', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/newline-template.fixture.ts',
      globalName: 'plv8ify',
    })
    expect(js).toMatchSnapshot()
  })

  it('getBundleJs - newline string', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/newline-string.fixture.ts',
      globalName: 'plv8ify',
    })
    expect(js).toMatchSnapshot()
  })
})
