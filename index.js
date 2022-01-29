#!/usr/bin/env node

const arg = require('arg')
const esbuild = require('esbuild')
const fs = require('fs')
const dedent = require('dedent')
const nodeExternals = require('webpack-node-externals');


const { Project } = require('ts-morph')

const typeMap = {
    'number': 'float8',
    'string': 'text',
    'boolean': 'boolean',
}

async function main() {
    const args = arg({
        '--write-esbuild-output': Boolean,
        '--input-file': String,
        '--output-folder': String,
        '--scope-prefix': String,
        '--fallback-type': String,
    })

    if (args._.length === 0) {
        throw new Error(`Please specify a command. Available commands: generate`)
    }

    const writeEsbuildOutput = args['--write-esbuild-output'] || false
    const inputFile = args['--input-file'] || 'input.ts'
    const outputFolder = args['--output-folder'] || 'plv8ify-dist'
    const scopePrefix = args['--scope-prefix'] || 'plv8ify'
    const fallbackType = args['--fallback-type'] || 'JSONB'

    fs.mkdirSync(outputFolder, { recursive: true })

    const esbuildResult = await esbuild.build({
        entryPoints: [inputFile],
        bundle: true,
        platform: 'browser',
        external: [nodeExternals()],
        write: false,
        outdir: outputFolder,
        target: 'es2015',
        globalName: scopePrefix,
    }).catch(() => process.exit(1))

    const esbuildFile = esbuildResult.outputFiles.find(_ => true)

    if (writeEsbuildOutput) {
        fs.writeFileSync(`${outputFolder}/output.js`, esbuildFile.text)
    }

    const project = new Project()
    const sourceFile = project.addSourceFileAtPath(inputFile);

    const fns = sourceFile.getFunctions()

    fns.forEach(fnAst => {

        if (!fnAst.isExported()) {
            return
        }

        const name = fnAst.getName()
        const scopedName = scopePrefix + '_' + fnAst.getName()
        const params = fnAst.getParameters()

        const paramsBind = params
            .map(p => {
                const name = p.getName()
                const type = p.getType().getText()
                const mappedType = typeMap[type] || fallbackType
                return `${name} ${mappedType}`
            }).join(',')

        const paramsCall = params
            .map(p => {
                const name = p.getName()
                return `${name}`
            }).join(',')

        const plv8FunctionShell = dedent(`DROP FUNCTION IF EXISTS ${scopedName}(${paramsBind});
CREATE OR REPLACE FUNCTION ${scopedName}(${paramsBind}) RETURNS ${fallbackType} AS $$
${esbuildFile.text}

return plv8ify.${name}(${paramsCall})

$$ LANGUAGE plv8 IMMUTABLE STRICT;`)

        const filename = `${outputFolder}/${scopedName}.plv8.sql`
        try {
            fs.unlinkSync(filename)
        } catch (e) { }
        fs.writeFileSync(filename, plv8FunctionShell)
    })


}

main()