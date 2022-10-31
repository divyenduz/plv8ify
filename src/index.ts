#!/usr/bin/env node
import arg from 'arg'
import fs from 'fs'
import 'reflect-metadata'

import {
  getClientInitFileName,
  getClientInitSQL,
} from './fns/plv8/startProc/client'
import {
  getInitFunction,
  getInitFunctionFilename,
  getInitFunctionName,
} from './fns/plv8/startProc/init'
import TYPES from './interfaces/types'
import container from './inversify.config'

async function main() {
  // CLI Args
  const args = arg({
    '--write-esbuild-output': Boolean,
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

  const writeEsbuildOutput = args['--write-esbuild-output'] || false
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
  if (writeEsbuildOutput) {
    plv8ify.write(`${outputFolderPath}/output.js`, bundledJs)
  }

  // TS-Morph to parse the input Typescript file

  if (mode === 'start_proc') {
    // -- PLV8 + Server
    const initFunctionName = getInitFunctionName(scopePrefix)
    const initFunction = getInitFunction({
      fnName: initFunctionName,
      source: bundledJs,
      volatility: defaultVolatility,
    })
    const initFileName = getInitFunctionFilename(
      outputFolderPath,
      initFunctionName
    )
    plv8ify.write(initFileName, initFunction)

    // -- PLV8 + Client Initialization
    const clientInitSQL = getClientInitSQL()
    const startProcFileName = getClientInitFileName(outputFolderPath)
    plv8ify.write(startProcFileName, clientInitSQL)
  }

  const fns = plv8ify.getFunctions().filter((fn) => fn.isExported)
  // Emit SQL files for each exported function
  const sqlFiles = plv8ify.getPLV8SQLFunctions({
    fns,
    scopePrefix,
    mode,
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
