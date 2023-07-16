import { TSFunction } from 'src/interfaces/TSCompiler'
import { describe, it, expect } from 'vitest'

import { PLV8ifyCLI } from './PLV8ifyCLI'
import { EsBuild } from './EsBuild'
import { TsMorph } from './TsMorph'

describe('PLV8ifyCLI', () => {
  it('getSQLFunction with parameters', async () => {
    const compiler = new TsMorph()
    const bundler = new EsBuild()
    const plv8ify = new PLV8ifyCLI(bundler, compiler)
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        parameters: [],
        comments: [],
        isExported: true,
        returnType: 'JSONB',
      } as TSFunction,
      scopePrefix: 'plv8ify',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `console.log('hello')`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toMatchSnapshot()
  })

  it('getSQLFunction with delimiter', async () => {
    const compiler = new TsMorph()
    const bundler = new EsBuild()
    const plv8ify = new PLV8ifyCLI(bundler, compiler)
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        parameters: [],
        comments: [],
        isExported: true,
        returnType: 'JSONB',
      } as TSFunction,
      scopePrefix: 'plv8ify',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `console.log('hello')`,
      pgFunctionDelimiter: '$function$',
      fallbackReturnType: 'JSONB',
    })

    expect(sql).toMatchSnapshot()
  })
})
