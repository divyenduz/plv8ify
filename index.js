#!/usr/bin/env node

const esbuild = require('esbuild')
const fs = require('fs')

const { Project } = require('ts-morph')

const typeMap = {
    'number': 'float8'
}

async function main() {
    esbuild.build({
        entryPoints: ['input.ts'],
        bundle: true,
        platform: 'node',
        outfile: 'output.js',
    }).catch(() => process.exit(1))

    let bundledJs = fs.readFileSync('./output.js', 'utf8')
    bundledJs = bundledJs.replace('console.log(main());', 'return main()')

    const project = new Project()
    const sourceFile = project.addSourceFileAtPath("input.ts");

    const ast = sourceFile.getFunction('main')
    const name = ast.getName()
    const params = ast.getParameters()

    const paramsBind = params
        .map(p => {
            const name = p.getName()
            const type = p.getType().getText()
            const mappedType = typeMap[type]
            return `${name} ${mappedType}`
        }).join(',')

    const paramsCall = params
        .map(p => {
            const name = p.getName()
            return `${name}`
        }).join(',')

    const plv8FunctionShell = `
DROP FUNCTION IF EXISTS ${name}(${paramsBind});
CREATE OR REPLACE FUNCTION ${name}(${paramsBind}) RETURNS JSON AS $$
    ${bundledJs}

    return ${name}(${paramsCall})

$$ LANGUAGE plv8 IMMUTABLE STRICT;
    `
    console.log(plv8FunctionShell)
}

main()