import { describe, expect, it } from 'bun:test'

import { EsBuild } from './EsBuild'

describe('EsBuild tests', () => {
  it('getBundleJs - inline mode', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/input.fixture.ts',
    })

    expect(js).toMatchSnapshot()
  })

  it('getBundleJs - bad syntax', async () => {
    const esbuild = new EsBuild()
    expect(
      esbuild.bundle({
        inputFile: './src/test-fixtures/bad.fixture.ts',
      })
    ).rejects.toMatchSnapshot()
  })

  it('getBundleJs - newline template', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/newline-template.fixture.ts',
    })
    expect(js).toMatchSnapshot()
  })

  it('getBundleJs - newline string', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/newline-string.fixture.ts',
    })
    expect(js).toMatchSnapshot()
  })
})
