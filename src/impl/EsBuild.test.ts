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

  it('getBundleJs - esbuild-define with ENABLE_FEATURE=false eliminates feature branch', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/define.fixture.ts',
      define: { ENABLE_FEATURE: 'false' },
    })
    // Branch guarded by !ENABLE_FEATURE (i.e. !false = true) should be kept as early return
    // The "feature active:" string should be eliminated
    expect(js).not.toContain('feature active')
    expect(js).toMatchSnapshot()
  })

  it('getBundleJs - esbuild-define with ENABLE_FEATURE=true eliminates early return', async () => {
    const esbuild = new EsBuild()
    const js = await esbuild.bundle({
      inputFile: './src/test-fixtures/define.fixture.ts',
      define: { ENABLE_FEATURE: 'true' },
    })
    // Early return guarded by !ENABLE_FEATURE (i.e. !true = false) should be eliminated
    // The "feature active:" string should be present
    expect(js).toContain('feature active')
    expect(js).toMatchSnapshot()
  })

  it('getBundleJs - no define produces same output as before (backward compat)', async () => {
    const esbuild = new EsBuild()
    const withoutDefine = await esbuild.bundle({
      inputFile: './src/test-fixtures/input.fixture.ts',
    })
    const withEmptyDefine = await esbuild.bundle({
      inputFile: './src/test-fixtures/input.fixture.ts',
      define: {},
    })
    expect(withoutDefine).toEqual(withEmptyDefine)
  })
})
