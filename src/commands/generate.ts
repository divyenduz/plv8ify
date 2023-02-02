import fs from 'fs'
import { ParseCLI } from 'src/impl/ParseCLI'
import TYPES from 'src/interfaces/types'

import container from '../inversify.config'

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
