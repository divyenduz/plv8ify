#!/usr/bin/env node

const arg = require('arg')
const esbuild = require('esbuild')
const fs = require('fs')
const dedent = require('dedent')

const { Project } = require('ts-morph')

const typeMap = {
    'number': 'float8'
}

async function main() {
    const args = arg({
        '--write-esbuild-output': Boolean,
    })

    const writeEsbuildOutput = args['--write-esbuild-output'] || false

    const distFolder = 'plv8ify-dist'
    const esbuildResult = await esbuild.build({
        entryPoints: ['input.ts'],
        bundle: true,
        platform: 'browser',
        external: ['fs'],
        write: false,
        outdir: distFolder,
        target: 'es2015',
        globalName: 'plv8ify',
    }).catch(() => process.exit(1))

    const esbuildFile = esbuildResult.outputFiles.find(_ => true)

    if (writeEsbuildOutput) {
        fs.writeFileSync(`${distFolder}/output.js`, esbuildFile.text)
    }

    const project = new Project()
    const sourceFile = project.addSourceFileAtPath("input.ts");

    const fns = sourceFile.getFunctions()

    fns.forEach(fnAst => {

        if (!fnAst.isExported()) {
            return
        }

        const name = fnAst.getName()
        const scopedName = 'plv8ify_' + fnAst.getName()
        const params = fnAst.getParameters()

        const paramsBind = params
            .map(p => {
                const name = p.getName()
                const type = p.getType().getText()
                const mappedType = typeMap[type] || 'JSONB'
                return `${name} ${mappedType}`
            }).join(',')

        const paramsCall = params
            .map(p => {
                const name = p.getName()
                return `${name}`
            }).join(',')

        const plv8FunctionShell = dedent(`DROP FUNCTION IF EXISTS ${scopedName}(${paramsBind});
CREATE OR REPLACE FUNCTION ${scopedName}(${paramsBind}) RETURNS JSONB AS $$
${esbuildFile.text}

return plv8ify.${name}(${paramsCall})

$$ LANGUAGE plv8 IMMUTABLE STRICT;`)

        const filename = `${distFolder}/${scopedName}.plv8.sql`
        try {
            fs.unlinkSync(filename)
        } catch (e) { }
        fs.writeFileSync(filename, plv8FunctionShell)
    })


}

main()