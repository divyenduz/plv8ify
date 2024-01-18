import { Effect } from 'effect'
import { PLV8ify } from 'src/interfaces/PLV8ify.js'

import { Config } from '../helpers/ParseCLI.js'

export function generateCommand() {
  const bundledJs = Effect.all([Config, PLV8ify]).pipe(
    Effect.tap(([config, plv8ify]) => {
      const commandConfig = config.getCommand()
      const { inputFilePath } = commandConfig.config
      plv8ify.init(inputFilePath)
    }),
    Effect.flatMap(([config, plv8ify]) => {
      const commandConfig = config.getCommand()
      const { mode, inputFilePath, scopePrefix } = commandConfig.config
      const bundledJs = Effect.promise(() =>
        plv8ify.build({
          mode,
          inputFile: inputFilePath,
          scopePrefix,
        })
      )
      return bundledJs
    })
  )

  return bundledJs.pipe(
    Effect.flatMap((bundledJs) => {
      return Effect.all([Config, PLV8ify]).pipe(
        Effect.flatMap(([config, plv8ify]) => {
          const commandConfig = config.getCommand()
          const {
            mode,
            scopePrefix,
            defaultVolatility,
            pgFunctionDelimiter,
            fallbackReturnType,
            outputFolderPath,
            writeBundlerOutput,
          } = commandConfig.config
          const sqlFiles = plv8ify.getPLV8SQLFunctions({
            mode,
            scopePrefix,
            defaultVolatility,
            bundledJs,
            pgFunctionDelimiter,
            fallbackReturnType,
            outputFolder: outputFolderPath,
          })

          return Effect.succeed({
            writeBundlerOutput,
            outputFolderPath,
            sqlFiles,
            bundledJs,
          })
        })
      )
    })
  )
}
