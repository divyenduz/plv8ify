import fs from 'fs'

import { ParseCLI, CLIConfig } from '../helpers/ParseCLI.js'
import { PLV8ifyCLI } from '../impl/PLV8ifyCLI.js'

export async function generateCommand(CLI: {
  command: string
  config: CLIConfig
}) {
  const {
    debug,
    bundler,
    writeBundlerOutput,
    inputFilePath,
    outputFolderPath,
    scopePrefix,
    pgFunctionDelimiter,
    fallbackReturnType,
    mode,
    defaultVolatility,
    typesFilePath,
  } = CLI.config

  // Runtime check
  const runtime = typeof Bun !== 'undefined' ? 'bun' : 'node'
  
  if (debug) {
    console.log(`DEBUG: Running in ${runtime} runtime`)
  }

  if (bundler === 'bun' && runtime === 'node') {
    throw new Error('Bun bundler is not supported in node runtime')
  }

  fs.mkdirSync(outputFolderPath, { recursive: true })

  const plv8ify = new PLV8ifyCLI(bundler)
  plv8ify.init(inputFilePath, typesFilePath)

  const bundledJs = await plv8ify.build({
    mode,
    inputFile: inputFilePath,
    scopePrefix,
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