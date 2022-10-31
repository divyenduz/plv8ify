#!/usr/bin/env node
import arg from 'arg'
import fs from 'fs'
import 'reflect-metadata'

import TYPES from './interfaces/types'
import container from './inversify.config'

async function main() {
  // CLI Args
  const args = arg({
    '--write-bundler-output': Boolean,
    '--input-file': String,
    '--output-folder': String,
    '--scope-prefix': String,
    '--pg-function-delimiter': String,
    '--fallback-type': String,
    '--mode': String,
    '--volatility': String,
    '--debug': Boolean,
  })

  if (args._.length === 0) {
    throw new Error(
      `Please specify a command. Available commands: generate, version`
    )
  }

  if (args._[0] === 'version') {
    const pkg = require('../package.json')
    console.log(`Version: ${pkg.version}`)
    process.exit(0)
  }

  const writeBundlerOutput = args['--write-bundler-output'] || false
  const inputFilePath = args['--input-file'] || 'input.ts'
  const outputFolderPath = args['--output-folder'] || 'plv8ify-dist'
  const scopePrefix = args['--scope-prefix'] || 'plv8ify'
  const pgFunctionDelimiter = args['--pg-function-delimiter'] || '$plv8ify$'
  const fallbackReturnType = args['--fallback-type'] || 'JSONB'
  const mode = (args['--mode'] || 'inline') as Mode
  const defaultVolatility = (args['--volatility'] || 'IMMUTABLE') as Volatility

  fs.mkdirSync(outputFolderPath, { recursive: true })

  const plv8ify = container.get<PLV8ify>(TYPES.PLV8ify)
  plv8ify.init(inputFilePath)

  const bundledJs = await plv8ify.build({
    mode,
    inputFile: inputFilePath,
    scopePrefix: 'plv8ify',
  })

  // Optionally, write ESBuild output file
  if (writeBundlerOutput) {
    plv8ify.write(`${outputFolderPath}/output.js`, bundledJs)
  }

  // Emit SQL files for each exported function in the input TS file
  const sqlFiles = plv8ify.getPLV8SQLFunctions({
    mode,
    scopePrefix,
    defaultVolatility,
    bundledJs,
    pgFunctionDelimiter,
    fallbackReturnType,
    outputFolder: outputFolderPath,
  })

  sqlFiles.forEach((sqlFile) => {
    plv8ify.write(sqlFile.filename, sqlFile.sql)
  })
}

main()
