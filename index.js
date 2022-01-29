#!/usr/bin/env node

const esbuild = require('esbuild')
const fs = require('fs')
const dedent = require('dedent')

const { Project } = require('ts-morph')

const typeMap = {
    'number': 'float8'
}

async function main() {
    const distFolder = 'plv8ify-dist'
    const esbuildResult = await esbuild.build({
        entryPoints: ['input.ts'],
        bundle: true,
        platform: 'node',
        write: false,
        outdir: distFolder
    }).catch(() => process.exit(1))

    const esbuildFile = esbuildResult.outputFiles.find(_ => true)

    const project = new Project()
    const sourceFile = project.addSourceFileAtPath("input.ts");

    const fns = sourceFile.getFunctions()

    fns.forEach(fnAst => {
        const name = fnAst.getName()
        const scopedName = 'plv8ify_' + fnAst.getName()
        const params = fnAst.getParameters()

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

        const plv8FunctionShell = dedent(`DROP FUNCTION IF EXISTS ${scopedName}(${paramsBind});
CREATE OR REPLACE FUNCTION ${scopedName}(${paramsBind}) RETURNS JSON AS $$
${esbuildFile.text}

return ${name}(${paramsCall})

$$ LANGUAGE plv8 IMMUTABLE STRICT;`)

        const filename = `${distFolder}/${scopedName}.plv8.sql`
        try {
            fs.unlinkSync(filename)
        } catch (e) { }
        fs.writeFileSync(filename, plv8FunctionShell)
    })


}

main()