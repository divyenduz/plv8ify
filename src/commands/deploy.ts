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
  const { outputFolderPath, deployConcurrency } = CLI.config

  const checkOutputFolderTask = await task(
    `Checking output folder: ${outputFolderPath}`,
    async ({ setError }) => {
      if (!fs.statSync(outputFolderPath)) {
        const errorMessage = `Output folder '${outputFolderPath}' not found. Please run 'plv8ify generate' first to create SQL files.`
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
    'Checking DATABASE_URL environment variable',
    async ({ setError }) => {
      if (!databaseUrl) {
        const errorMessage = `DATABASE_URL environment variable is not set. Please set it to your PostgreSQL connection string (e.g., postgres://user:password@host:port/database)`
        setError(errorMessage)
      }
    }
  )
  if (databaseUrlIsSetTask.state === 'error') {
    ParseCLI.throwError()
  }

  const database = new Database(databaseUrl)
  const isDatabaseReachableTask = await task(
    'Connecting to PostgreSQL database',
    async ({ setError }) => {
      const isReachable = await database.isDatabaseReachable()
      if (!isReachable) {
        const errorMessage = `Failed to connect to database. Please check your DATABASE_URL and ensure the PostgreSQL server is running and accessible.`
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
    `Deploying SQL functions to PostgreSQL database`,
    ({ setWarning }) =>
      task.group((task) =>
        deployCommands.map((deployCommand) => {
          const name = getFunctionNameFromFilePath(deployCommand.filePath)
          return task(
            `Deploying function: ${name}`,
            async ({ setTitle: _setTitle, setError: _setError }) => {
              try {
                await deployCommand.sqlQueryPromise
                _setTitle(`✓ Deployed: ${name}`)
              } catch (e) {
                _setError(`✗ Failed: ${name} - ${e.message}`)
                setWarning(`Some functions failed to deploy (see errors above)`)
              }
            }
          )
        }),
        { concurrency: deployConcurrency }
      )
  )

  database.endConnection()
}
