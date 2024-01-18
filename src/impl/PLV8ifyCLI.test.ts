import { describe, expect, it } from 'bun:test'
import { TSFunction } from 'src/interfaces/TSCompiler'

import { PLV8ifyCLI } from './PLV8ifyCLI'

describe('PLV8ifyCLI tests', () => {
  it('getSQLFunction with parameters', async () => {
    const plv8ify = new PLV8ifyCLI()
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        parameters: [],
        comments: [],
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
    const plv8ify = new PLV8ifyCLI()
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        parameters: [],
        comments: [],
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

  it('getSQLFunction with parameters-trigger', async () => {
    const plv8ify = new PLV8ifyCLI()
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        parameters: [
          { name: 'NEW', type: 'testRow' },
          { name: 'OLD', type: 'testRow' },
        ],
        comments: ['//@plv8ify-trigger'],
      } as TSFunction,
      scopePrefix: 'plv8ify',
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
        parameters: [],
        comments: ['//@plv8ify-schema-name testschema'],
      } as TSFunction,
      scopePrefix: 'plv8ify',
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
        parameters: [{ name: 'test', type: 'test_type[]' }],
        comments: [],
      } as TSFunction,
      scopePrefix: 'plv8ify',
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
})
