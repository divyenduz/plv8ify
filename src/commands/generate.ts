import fs from 'fs'

import { ParseCLI } from '../helpers/ParseCLI'
import { PLV8ifyCLI } from 'src/impl/PLV8ifyCLI'

export async function generateCommand(
  CLI: ReturnType<typeof ParseCLI.getCommand>
) {
  const {
    writeBundlerOutput,
    inputFilePath,
    outputFolderPath,
    scopePrefix,
    pgFunctionDelimiter,
    fallbackReturnType,
    mode,
    defaultVolatility,
  } = CLI.config

  fs.mkdirSync(outputFolderPath, { recursive: true })

  const plv8ify = new PLV8ifyCLI(bundler)
  plv8ify.init(inputFilePath)

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
