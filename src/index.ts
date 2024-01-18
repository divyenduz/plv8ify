#!/usr/bin/env node
import { Effect, Layer } from 'effect'
import fs from 'fs'
import { match } from 'ts-pattern'

import { deployCommand } from './commands/deploy.js'
import { generateCommand } from './commands/generate.js'
import { versionCommand } from './commands/version.js'
import { DatabaseLive } from './helpers/Database.js'
import { ConfigLive, ParseCLI } from './helpers/ParseCLI.js'
import { getRuntime, writeFile } from './helpers/Utils.js'
import { PLV8ifyCLILive } from './impl/PLV8ifyCLI.js'

async function main() {
  const runtime = getRuntime()
  const CLI = ParseCLI.getCommand()

  if (CLI.config.debug) {
    console.log(`DEBUG: Running in ${runtime} runtime`)
  }

  if (CLI.config.bundler === 'bun' && runtime === 'node') {
    throw new Error('Bun bundler is not supported in node runtime')
  }

  match(CLI.command)
    .with('version', () => {
      const program = versionCommand()
      Effect.runSync(program)
    })
    .with('generate', async () => {
      const program = await generateCommand()
      const runnable = await Effect.provide(
        program,
        Layer.merge(ConfigLive, PLV8ifyCLILive)
      )
      runnable.pipe(
        Effect.tap(
          ({ outputFolderPath, writeBundlerOutput, sqlFiles, bundledJs }) => {
            fs.mkdirSync(outputFolderPath, { recursive: true })

            if (writeBundlerOutput) {
              writeFile(`${outputFolderPath}/output.js`, bundledJs)
            }
            sqlFiles.forEach((sqlFile) => {
              writeFile(sqlFile.filename, sqlFile.sql)
            })
            process.exit(0)
          }
        ),
        Effect.catchAll((e) => {
          console.error(e)
          process.exit(1)
        }),
        Effect.runPromise
      )
    })
    .with('deploy', async () => {
      const program = Effect.scoped(deployCommand())
      const runnable = Effect.provide(
        program,
        Layer.merge(ConfigLive, DatabaseLive)
      )
      Effect.runPromise(runnable)
    })
    .exhaustive()
}

main()
