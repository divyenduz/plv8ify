import { describe, expect, it } from 'bun:test'
import { TSFunction } from 'src/interfaces/TSCompiler'

import { PLV8ifyCLI } from './PLV8ifyCLI'

describe('PLV8ifyCLI tests', () => {
  it('getSQLFunction with parameters', async () => {
    const plv8ify = new PLV8ifyCLI()
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [],
        returnType: 'void',
        jsdocTags: []
      },
      scopePrefix: 'plv8ify_',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `console.log('hello')`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toMatchSnapshot()
  })

  it('getSQLFunction with custom delimiter', async () => {
    const plv8ify = new PLV8ifyCLI()
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [],
        returnType: 'void',
        jsdocTags: [],
      },
      scopePrefix: 'plv8ify_',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `console.log('hello')`,
      pgFunctionDelimiter: '$function$',
      fallbackReturnType: 'JSONB',
    })

    expect(sql).toMatchSnapshot()
  })

  it('getSQLFunction with parameters-trigger', async () => {
    const plv8ify = new PLV8ifyCLI()
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [
          { name: 'NEW', type: 'testRow' },
          { name: 'OLD', type: 'testRow' },
        ],
        returnType: 'object',
        jsdocTags: [
          { name: 'plv8ify_trigger', commentText: '' },
        ]
      },
      scopePrefix: 'plv8ify_',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `
function test(NEW, OLD) {
  if (TG_OP === "UPDATE") {
    NEW.event_name = NEW.event_name ?? OLD.event_name;
    return NEW;
  }
  if (TG_OP === "INSERT") {
    NEW.id = 102;
    return NEW;
  }
}      
      `,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toMatchSnapshot()
  })

  it('getSQLFunction with custom-schema', async () => {
    const plv8ify = new PLV8ifyCLI()
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [],
        returnType: 'string',
        jsdocTags: [
          { name: 'plv8ify_schema_name', commentText: 'testschema' },
        ]
      },
      scopePrefix: 'plv8ify_',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `
function test() {
  return "hello";
}      
      `,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toMatchSnapshot()
  })

  it('getSQLFunction with custom type', async () => {
    const plv8ify = new PLV8ifyCLI()
    plv8ify.init('', './src/test-fixtures/types-custom.fixture.js')

    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [{ name: 'test', type: 'test_type[]' }],
        returnType: 'object',
        jsdocTags: []
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `
      export function hello(test: test_type[]) {
        return {
          name: "Hello" + test[0].name,
          age: test[0].age,
        }
      }      
      `,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toMatchSnapshot()
  })

  it('build and getPLV8SQLFunctions with satisfies keyword fixture', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./src/test-fixtures/satisfies.fixture.ts')
    const bundledJs = await plv8ify.build({
      mode: 'inline',
      inputFile: './src/test-fixtures/satisfies.fixture.ts',
      scopePrefix: '',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'inline',
      scopePrefix: '',
      fallbackReturnType: 'JSONB',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })
    expect(fns.length).toEqual(1)
    expect(fns[0].filename).toEqual('plv8ify-dist/getEndpoint.plv8.sql')
    expect(fns[0].sql).toMatchSnapshot()
  })
})
