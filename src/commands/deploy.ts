import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
import task from 'tasuku'

import { Database } from '../helpers/Database.js'
import { ParseCLI } from '../helpers/ParseCLI.js'

dotenv.config()

// File name/function name are configurable but with the same variable, so they will always match (so far)
function getFunctionNameFromFilePath(filePath: string) {
  const fileName = path.basename(filePath, '.plv8.sql')
  return fileName
}

export async function deployCommand(
  CLI: ReturnType<typeof ParseCLI.getCommand>
) {
  const outputFolderPath = CLI.config.outputFolderPath

  const checkOutputFolderTask = await task(
    `Check if the --output-folder (${outputFolderPath}) exists`,
    async ({ setError }) => {
      if (!fs.statSync(outputFolderPath)) {
        const errorMessage = `${outputFolderPath} doesn't exist`
        setError(errorMessage)
      }
    }
  )
  if (checkOutputFolderTask.state === 'error') {
    ParseCLI.throwError()
  }

  // TODO: move process/env stuff to a separate file
  const databaseUrl = process.env.DATABASE_URL

  const databaseUrlIsSetTask = await task(
    'Check if the DATABASE_URL env var is set',
    async ({ setError }) => {
      if (!databaseUrl) {
        const errorMessage = `DATABASE_URL not set in environment`
        setError(errorMessage)
      }
    }
  )
  if (databaseUrlIsSetTask.state === 'error') {
    ParseCLI.throwError()
  }

  const database = new Database(databaseUrl)
  const isDatabaseReachableTask = await task(
    'Check if the provided DATABASE_URL is reachable',
    async ({ setError }) => {
      const isReachable = await database.isDatabaseReachable()
      if (!isReachable) {
        const errorMessage = `Provided DATABASE_URL: ${databaseUrl} is not reachable`
        setError(errorMessage)
      }
    }
  )
  if (isDatabaseReachableTask.state === 'error') {
    ParseCLI.throwError()
  }

  const db = database.getConnection()
  let deployCommands = fs
    .readdirSync(outputFolderPath)
    // Only extract .plv8.sql files, this will need to change if we ever make the extension configurable
    .filter((file) => file.endsWith('.plv8.sql'))
    .map((file) => {
      const filePath = path.join(outputFolderPath, file)
      return {
        filePath,
        sqlQueryPromise: db.file(filePath),
      }
    })

  await task(
    `Deploying files from ${outputFolderPath} to the provided PostgreSQL database 🚧`.trim(),
    ({ setWarning }) =>
      task.group((task) =>
        deployCommands.map((deployCommand) => {
          const name = getFunctionNameFromFilePath(deployCommand.filePath)
          return task(
            `Deploying ${name}`,
            async ({ setTitle: _setTitle, setError: _setError }) => {
              try {
                await deployCommand.sqlQueryPromise
                _setTitle(`Deployed ${name}`)
              } catch (e) {
                _setError(`Failed to deploy ${name} (because of ${e.message})`)
                setWarning(`Failed to some functions (see below))`)
              }
            }
          )
        }),
        { concurrency: 2 }
      )
  )

  database.endConnection()
}
