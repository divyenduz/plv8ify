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
        isTrigger: true,
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
        customSchema: 'testschema',
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

  it('executes inline mode correctly when exported function collides with dependency (mathjs atan2)', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./examples/mathjs/input.ts')
    const bundledJs = await plv8ify.build({
      mode: 'inline',
      inputFile: './examples/mathjs/input.ts',
      scopePrefix: '',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'inline',
      scopePrefix: '',
      fallbackReturnType: 'float8',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })
    expect(fns.length).toEqual(1)
    expect(fns[0].filename).toEqual('plv8ify-dist/atan2.plv8.sql')

    // Behavioral test: extract the generated JS body between delimiters and execute it
    const jsBody = fns[0].sql.split('$plv8ify$')[1]
    const fn = new Function('one', 'two', jsBody)
    const result = fn(1, 1)
    expect(result).toBeCloseTo(Math.atan2(1, 1), 10)
  })

  it('executes bundle mode correctly when exported function collides with dependency (mathjs atan2)', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./examples/mathjs/input.ts')
    const bundledJs = await plv8ify.build({
      mode: 'bundle',
      inputFile: './examples/mathjs/input.ts',
      scopePrefix: 'myScope',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'bundle',
      scopePrefix: 'myScope',
      fallbackReturnType: 'float8',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })

    const initSql = fns.find((f) => f.filename.endsWith('_init.plv8.sql'))!.sql
    const funcSql = fns.find((f) => f.filename.endsWith('myScopeatan2.plv8.sql'))!.sql

    const initBody = initSql.split('$$')[1]
    const funcBody = funcSql.split('$plv8ify$')[1]

    const mockGlobal: Record<string, any> = { Symbol: globalThis.Symbol }
    const mockPlv8 = {
      execute: (cmd: string) => {
        if (cmd === 'SELECT myScope_init();') {
          new Function('globalThis', `with(globalThis) { ${initBody} }`)(mockGlobal)
        }
      },
    }

    const bundleFn = new Function('globalThis', 'plv8', 'one', 'two', `with(globalThis) { ${funcBody} }`)
    const result = bundleFn(mockGlobal, mockPlv8, 1, 1)
    expect(result).toBeCloseTo(Math.atan2(1, 1), 10)
  })

  it('executes start_proc mode correctly when exported function collides with dependency (mathjs atan2)', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./examples/mathjs/input.ts')
    const bundledJs = await plv8ify.build({
      mode: 'start_proc',
      inputFile: './examples/mathjs/input.ts',
      scopePrefix: 'myScope',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'start_proc',
      scopePrefix: 'myScope',
      fallbackReturnType: 'float8',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })

    const initSql = fns.find((f) => f.filename.endsWith('_init.plv8.sql'))!.sql
    const funcSql = fns.find((f) => f.filename.endsWith('myScopeatan2.plv8.sql'))!.sql

    const initBody = initSql.split('$$')[1]
    const funcBody = funcSql.split('$plv8ify$')[1]

    const mockGlobal: Record<string, any> = { Symbol: globalThis.Symbol }
    new Function('globalThis', `with(globalThis) { ${initBody} }`)(mockGlobal)

    const spFn = new Function('globalThis', 'one', 'two', `with(globalThis) { ${funcBody} }`)
    const result = spFn(mockGlobal, 1, 1)
    expect(result).toBeCloseTo(Math.atan2(1, 1), 10)
  })

  it('handles multiple exports with and without collisions', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./src/test-fixtures/collision.fixture.ts')
    const bundledJs = await plv8ify.build({
      mode: 'inline',
      inputFile: './src/test-fixtures/collision.fixture.ts',
      scopePrefix: '',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'inline',
      scopePrefix: '',
      fallbackReturnType: 'float8',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })

    expect(fns.length).toEqual(2)

    const atan2Sql = fns.find((f) => f.filename.endsWith('atan2.plv8.sql'))!.sql
    const addSql = fns.find((f) => f.filename.endsWith('add.plv8.sql'))!.sql

    const atan2Fn = new Function('one', 'two', atan2Sql.split('$plv8ify$')[1])
    expect(atan2Fn(1, 1)).toBeCloseTo(Math.atan2(1, 1), 10)

    const addFn = new Function('a', 'b', addSql.split('$plv8ify$')[1])
    expect(addFn(3, 7)).toEqual(10)
  })

  it('works with bun bundler when collision occurs', async () => {
    const plv8ify = new PLV8ifyCLI('bun')
    plv8ify.init('./examples/mathjs/input.ts')
    const bundledJs = await plv8ify.build({
      mode: 'inline',
      inputFile: './examples/mathjs/input.ts',
      scopePrefix: '',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'inline',
      scopePrefix: '',
      fallbackReturnType: 'float8',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })

    expect(fns.length).toEqual(1)
    const jsBody = fns[0].sql.split('$plv8ify$')[1]
    const fn = new Function('one', 'two', jsBody)
    expect(fn(1, 1)).toBeCloseTo(Math.atan2(1, 1), 10)
  })

  it('supports custom deterministic bundleId / build number', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild', 123456789)
    plv8ify.init('./src/test-fixtures/input.fixture.ts')
    const bundledJs = await plv8ify.build({
      mode: 'bundle',
      inputFile: './src/test-fixtures/input.fixture.ts',
      scopePrefix: 'myScope',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'bundle',
      scopePrefix: 'myScope',
      fallbackReturnType: 'text',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })

    const initSql = fns.find((f) => f.filename.endsWith('_init.plv8.sql'))!.sql
    const funcSql = fns.find((f) => f.filename.endsWith('myScopesayHello.plv8.sql'))!.sql

    expect(initSql).toContain("globalThis[Symbol.for('myScope_initialized')] = 123456789;")
    expect(funcSql).toContain("if (globalThis[Symbol.for('myScope_initialized')] !== 123456789)")
  })

  it('correctly parses JSDoc annotations from source files via TsMorph', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./examples/hello-custom-type/input.ts')
    const bundledJs = await plv8ify.build({
      mode: 'inline',
      inputFile: './examples/hello-custom-type/input.ts',
      scopePrefix: '',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'inline',
      scopePrefix: '',
      fallbackReturnType: 'text',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })

    const howdyFn = fns.find((f) => f.filename.endsWith('howdy.plv8.sql'))
    expect(howdyFn).toBeDefined()
    expect(howdyFn!.sql).toContain('howdy(first_name varchar(255),last_name text) RETURNS char(255)')
  })

  it('correctly parses parallel and volatility annotations from source files', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./examples/parallel-annotations/input.ts')
    const bundledJs = await plv8ify.build({
      mode: 'inline',
      inputFile: './examples/parallel-annotations/input.ts',
      scopePrefix: '',
    })
    const fns = plv8ify.getPLV8SQLFunctions({
      mode: 'inline',
      scopePrefix: '',
      fallbackReturnType: 'float8',
      defaultVolatility: 'IMMUTABLE',
      bundledJs,
      pgFunctionDelimiter: '$plv8ify$',
      outputFolder: 'plv8ify-dist',
    })

    const sumFn = fns.find((f) => f.filename.endsWith('calculateSum.plv8.sql'))
    const ageFn = fns.find((f) => f.filename.endsWith('getUserAge.plv8.sql'))
    const logFn = fns.find((f) => f.filename.endsWith('logMessage.plv8.sql'))
    const multFn = fns.find((f) => f.filename.endsWith('multiply.plv8.sql'))

    expect(sumFn!.sql).toContain('LANGUAGE plv8 IMMUTABLE PARALLEL SAFE')
    expect(ageFn!.sql).toContain('LANGUAGE plv8 STABLE PARALLEL RESTRICTED')
    expect(logFn!.sql).toContain('LANGUAGE plv8 VOLATILE PARALLEL UNSAFE')
    expect(multFn!.sql).toContain('LANGUAGE plv8 IMMUTABLE STRICT')
    expect(multFn!.sql).not.toContain('PARALLEL')
  })

  it('correctly parses trigger annotations from source files', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./examples/trigger/input.ts')
    const bundledJs = await plv8ify.build({
      mode: 'inline',
      inputFile: './examples/trigger/input.ts',
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

    const triggerFn = fns.find((f) => f.filename.endsWith('test.plv8.sql'))
    expect(triggerFn).toBeDefined()
    expect(triggerFn!.sql).toContain('CREATE OR REPLACE FUNCTION test() RETURNS TRIGGER')
  })
})
