#!/usr/bin/env node

const esbuild = require('esbuild')
const fs = require('fs')

async function main() {
    esbuild.build({
        entryPoints: ['input.js'],
        bundle: true,
        platform: 'node',
        outfile: 'output.js',
    }).catch(() => process.exit(1))

    let bundledJs = fs.readFileSync('./output.js', 'utf8')
    bundledJs = bundledJs.replace('console.log(main());', 'return main()')
    const plv8FunctionShell = `
DROP FUNCTION plv8_test();
CREATE OR REPLACE FUNCTION plv8_test() RETURNS JSON AS $$
    ${bundledJs}
$$ LANGUAGE plv8 IMMUTABLE STRICT;
    `
    console.log(plv8FunctionShell)
}

main()