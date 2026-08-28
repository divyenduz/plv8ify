import { describe, expect, it } from 'bun:test'
import fs from 'fs'
import path from 'path'
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

  it('getSQLFunction with custom type from named export', async () => {
    const plv8ify = new PLV8ifyCLI()
    plv8ify.init('', './src/test-fixtures/types-named-export.fixture.ts')

    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [{ name: 'point', type: 'CustomGeo' }],
        returnType: 'CustomGeo',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `function test(point) { return point; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toContain('CREATE OR REPLACE FUNCTION test(point geometry(Point, 4326)) RETURNS geometry(Point, 4326) AS $plv8ify$')
  })

  it('getSQLFunction with custom type from default export', async () => {
    const plv8ify = new PLV8ifyCLI()
    plv8ify.init('', './src/test-fixtures/types-default-export.fixture.ts')

    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [{ name: 'ids', type: 'UserId[]' }],
        returnType: 'UserId',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `function test(ids) { return ids[0]; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toContain('CREATE OR REPLACE FUNCTION test(ids uuid[]) RETURNS uuid AS $plv8ify$')
  })

  it('getSQLFunction with custom type from JSON config', async () => {
    const plv8ify = new PLV8ifyCLI()
    plv8ify.init('', './src/test-fixtures/types-json.fixture.json')

    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [{ name: 'data', type: 'JsonType' }],
        returnType: 'JsonType',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `function test(data) { return data; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toContain('CREATE OR REPLACE FUNCTION test(data jsonb) RETURNS jsonb AS $plv8ify$')
  })

  it('custom type mapping parses AST without evaluating executable code (no eval)', async () => {
    delete (globalThis as any).__MALICIOUS_SIDE_EFFECT_EXECUTED__
    const plv8ify = new PLV8ifyCLI()
    plv8ify.init('', './src/test-fixtures/types-security.fixture.ts')

    expect((globalThis as any).__MALICIOUS_SIDE_EFFECT_EXECUTED__).toBeUndefined()

    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'test',
        isExported: true,
        parameters: [{ name: 'val', type: 'SecuredType' }],
        returnType: 'SecuredType',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `function test(val) { return val; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })
    expect(sql).toContain('CREATE OR REPLACE FUNCTION test(val varchar(64)) RETURNS varchar(64) AS $plv8ify$')
  })

  it('build and getPLV8SQLFunctions with satisfies keyword fixture', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./src/test-fixtures/satisfies.fixture.ts')
    const bundledJs = await plv8ify.build({
      inputFile: './src/test-fixtures/satisfies.fixture.ts',
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
      inputFile: './examples/mathjs/input.ts',
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
      inputFile: './examples/mathjs/input.ts',
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
      inputFile: './examples/mathjs/input.ts',
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
      inputFile: './src/test-fixtures/collision.fixture.ts',
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
      inputFile: './examples/mathjs/input.ts',
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
      inputFile: './src/test-fixtures/input.fixture.ts',
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
      inputFile: './examples/hello-custom-type/input.ts',
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
      inputFile: './examples/parallel-annotations/input.ts',
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
      inputFile: './examples/trigger/input.ts',
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

  it('resolves types with custom type mappings and ts-morph AST', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init(
      './src/test-fixtures/types-resolution.fixture.ts',
      './src/test-fixtures/types-resolution-map.fixture.js'
    )
    const bundledJs = await plv8ify.build({
      inputFile: './src/test-fixtures/types-resolution.fixture.ts',
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

    const basicSql = fns.find((f) => f.filename.endsWith('testBasic.plv8.sql'))!.sql
    expect(basicSql).toContain('CREATE OR REPLACE FUNCTION testBasic(a float8,b text,c boolean) RETURNS JSONB')

    const customSql = fns.find((f) => f.filename.endsWith('testCustomTypes.plv8.sql'))!.sql
    expect(customSql).toContain('CREATE OR REPLACE FUNCTION testCustomTypes(p point,points point[],pointsGeneric point[]) RETURNS point')

    const namespacesSql = fns.find((f) => f.filename.endsWith('testNamespaces.plv8.sql'))!.sql
    expect(namespacesSql).toContain('CREATE OR REPLACE FUNCTION testNamespaces(c coord,coords coord[],coordsGeneric coord[]) RETURNS coord')

    const unionsSql = fns.find((f) => f.filename.endsWith('testUnions.plv8.sql'))!.sql
    expect(unionsSql).toContain('CREATE OR REPLACE FUNCTION testUnions(u jsonb) RETURNS jsonb')
  })

  it('build returns bundled js directly without dead mode-based string replacements', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    plv8ify.init('./examples/hello-start_proc/input.ts')

    const bundledJs = await plv8ify.build({
      inputFile: './examples/hello-start_proc/input.ts',
    })

    expect(bundledJs).toContain('function hello()')
    expect(bundledJs).toContain('function world()')
    expect(bundledJs).not.toContain('var plv8ify =')
    expect(bundledJs).not.toContain('this.plv8ify =')
  })

  it('generates REVOKE and GRANT statements when configured on function', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'secureOp',
        isExported: true,
        parameters: [{ name: 'val', type: 'text' }],
        returnType: 'text',
        revokes: ['PUBLIC', 'anon'],
        grants: ['authenticated', 'service_role'],
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `function secureOp(val) { return val; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'text',
    })

    expect(sql).toContain('REVOKE EXECUTE ON FUNCTION secureOp(val text) FROM PUBLIC, anon;')
    expect(sql).toContain('GRANT EXECUTE ON FUNCTION secureOp(val text) TO authenticated, service_role;')
  })

  it('correctly generates REVOKE and GRANT from JSDoc annotations in source file', async () => {
    const fixturePath = path.resolve('src/test-fixtures/grants-sql.fixture.ts')
    fs.writeFileSync(
      fixturePath,
      `
/**
 * @plv8ify_revoke PUBLIC
 * @plv8ify_grant authenticated
 * @plv8ify_grant service_role
 */
export function processPayment(amount: number): number {
  return amount
}
`
    )

    try {
      const plv8ify = new PLV8ifyCLI('esbuild')
      plv8ify.init(fixturePath)
      const bundledJs = await plv8ify.build({
        inputFile: fixturePath,
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

      const paymentFn = fns.find((f) => f.filename.endsWith('processPayment.plv8.sql'))
      expect(paymentFn).toBeDefined()
      expect(paymentFn!.sql).toContain('REVOKE EXECUTE ON FUNCTION processPayment(amount float8) FROM PUBLIC;')
      expect(paymentFn!.sql).toContain('GRANT EXECUTE ON FUNCTION processPayment(amount float8) TO authenticated, service_role;')
    } finally {
      if (fs.existsSync(fixturePath)) {
        fs.unlinkSync(fixturePath)
      }
    }
  })

  it('generates REVOKE and GRANT statements for triggers and custom schema', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    const sql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'onUserUpdate',
        isExported: true,
        parameters: [],
        returnType: 'trigger',
        isTrigger: true,
        customSchema: 'auth',
        revokes: ['PUBLIC'],
        grants: ['supabase_admin'],
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'VOLATILE',
      bundledJs: `function onUserUpdate() { return NEW; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'JSONB',
    })

    expect(sql).toContain('DROP FUNCTION IF EXISTS auth.onUserUpdate();')
    expect(sql).toContain('CREATE OR REPLACE FUNCTION auth.onUserUpdate() RETURNS TRIGGER AS $plv8ify$')
    expect(sql).toContain('REVOKE EXECUTE ON FUNCTION auth.onUserUpdate() FROM PUBLIC;')
    expect(sql).toContain('GRANT EXECUTE ON FUNCTION auth.onUserUpdate() TO supabase_admin;')
  })

  it('generates SECURITY DEFINER and SECURITY INVOKER statements when configured', async () => {
    const plv8ify = new PLV8ifyCLI('esbuild')
    const definerSql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'adminAction',
        isExported: true,
        parameters: [],
        returnType: 'boolean',
        security: 'DEFINER',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'VOLATILE',
      bundledJs: `function adminAction() { return true; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'boolean',
    })

    expect(definerSql).toContain('LANGUAGE plv8 VOLATILE STRICT SECURITY DEFINER;')

    const invokerSql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'userAction',
        isExported: true,
        parameters: [],
        returnType: 'boolean',
        security: 'INVOKER',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'STABLE',
      bundledJs: `function userAction() { return true; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'boolean',
    })

    expect(invokerSql).toContain('LANGUAGE plv8 STABLE STRICT SECURITY INVOKER;')
  })

  it('correctly generates SECURITY DEFINER from JSDoc annotations in source file', async () => {
    const fixturePath = path.resolve('src/test-fixtures/security-sql.fixture.ts')
    fs.writeFileSync(
      fixturePath,
      `
/**
 * @plv8ify_security_definer
 * @plv8ify_volatility VOLATILE
 * @plv8ify_parallel RESTRICTED
 * @plv8ify_revoke PUBLIC
 * @plv8ify_grant authenticated
 */
export function elevatePrivileges(role: string): boolean {
  return true;
}

/**
 * @plv8ify_security INVOKER
 * @plv8ify_volatility IMMUTABLE
 */
export function normalOperation(x: number): number {
  return x * 2;
}

export function defaultSecurityOp(y: number): number {
  return y + 1;
}
`
    )

    try {
      const plv8ify = new PLV8ifyCLI('esbuild')
      plv8ify.init(fixturePath)
      const bundledJs = await plv8ify.build({
        inputFile: fixturePath,
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

      const elevateFn = fns.find((f) => f.filename.endsWith('elevatePrivileges.plv8.sql'))
      expect(elevateFn).toBeDefined()
      expect(elevateFn!.sql).toContain('LANGUAGE plv8 VOLATILE PARALLEL RESTRICTED STRICT SECURITY DEFINER;')
      expect(elevateFn!.sql).toContain('REVOKE EXECUTE ON FUNCTION elevatePrivileges(role text) FROM PUBLIC;')
      expect(elevateFn!.sql).toContain('GRANT EXECUTE ON FUNCTION elevatePrivileges(role text) TO authenticated;')

      const normalFn = fns.find((f) => f.filename.endsWith('normalOperation.plv8.sql'))
      expect(normalFn).toBeDefined()
      expect(normalFn!.sql).toContain('LANGUAGE plv8 IMMUTABLE STRICT SECURITY INVOKER;')

      const defaultFn = fns.find((f) => f.filename.endsWith('defaultSecurityOp.plv8.sql'))
      expect(defaultFn).toBeDefined()
      expect(defaultFn!.sql).toContain('LANGUAGE plv8 IMMUTABLE STRICT;')
      expect(defaultFn!.sql).not.toContain('SECURITY')
    } finally {
      if (fs.existsSync(fixturePath)) {
        fs.unlinkSync(fixturePath)
      }
    }
  })

  it('generates SET search_path statements when configured on function', () => {
    const plv8ify = new PLV8ifyCLI()
    const emptyPathSql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'secureFunc',
        isExported: true,
        parameters: [],
        returnType: 'boolean',
        security: 'DEFINER',
        searchPath: "''",
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'VOLATILE',
      bundledJs: `function secureFunc() { return true; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'boolean',
    })

    expect(emptyPathSql).toContain('LANGUAGE plv8 VOLATILE STRICT SECURITY DEFINER SET search_path = \'\';')

    const customPathSql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'customPathFunc',
        isExported: true,
        parameters: [],
        returnType: 'boolean',
        searchPath: 'public, pg_temp',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `function customPathFunc() { return true; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'boolean',
    })

    expect(customPathSql).toContain('LANGUAGE plv8 IMMUTABLE STRICT SET search_path = public, pg_temp;')

    const noPathSql = plv8ify.getPLV8SQLFunction({
      fn: {
        name: 'normalFunc',
        isExported: true,
        parameters: [],
        returnType: 'boolean',
      },
      scopePrefix: '',
      mode: 'inline',
      defaultVolatility: 'IMMUTABLE',
      bundledJs: `function normalFunc() { return true; }`,
      pgFunctionDelimiter: '$plv8ify$',
      fallbackReturnType: 'boolean',
    })

    expect(noPathSql).toContain('LANGUAGE plv8 IMMUTABLE STRICT;')
    expect(noPathSql).not.toContain('search_path')
  })

  it('correctly generates SET search_path from JSDoc annotations in source file', async () => {
    const fixturePath = path.resolve('src/test-fixtures/search-path-sql.fixture.ts')
    fs.writeFileSync(
      fixturePath,
      `
/**
 * @plv8ify_security_definer
 * @plv8ify_search_path
 * @plv8ify_volatility VOLATILE
 * @plv8ify_revoke PUBLIC
 * @plv8ify_grant authenticated
 */
export function secureAdminAction(userId: string): boolean {
  return true;
}

/**
 * @plv8ify_search_path public, extensions
 * @plv8ify_volatility STABLE
 */
export function customSearchPathAction(x: number): number {
  return x * 2;
}

export function defaultSearchPathAction(y: number): number {
  return y + 1;
}
`
    )

    try {
      const plv8ify = new PLV8ifyCLI('esbuild')
      plv8ify.init(fixturePath)
      const bundledJs = await plv8ify.build({
        inputFile: fixturePath,
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

      const secureFn = fns.find((f) => f.filename.endsWith('secureAdminAction.plv8.sql'))
      expect(secureFn).toBeDefined()
      expect(secureFn!.sql).toContain('LANGUAGE plv8 VOLATILE STRICT SECURITY DEFINER SET search_path = \'\';')
      expect(secureFn!.sql).toContain('REVOKE EXECUTE ON FUNCTION secureAdminAction(userId text) FROM PUBLIC;')
      expect(secureFn!.sql).toContain('GRANT EXECUTE ON FUNCTION secureAdminAction(userId text) TO authenticated;')

      const customPathFn = fns.find((f) => f.filename.endsWith('customSearchPathAction.plv8.sql'))
      expect(customPathFn).toBeDefined()
      expect(customPathFn!.sql).toContain('LANGUAGE plv8 STABLE STRICT SET search_path = public, extensions;')

      const defaultFn = fns.find((f) => f.filename.endsWith('defaultSearchPathAction.plv8.sql'))
      expect(defaultFn).toBeDefined()
      expect(defaultFn!.sql).toContain('LANGUAGE plv8 IMMUTABLE STRICT;')
      expect(defaultFn!.sql).not.toContain('search_path')
    } finally {
      if (fs.existsSync(fixturePath)) {
        fs.unlinkSync(fixturePath)
      }
    }
  })
})



