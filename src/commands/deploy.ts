import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
import { Database } from 'src/helpers/Database'
import { ParseCLI } from 'src/helpers/ParseCLI'

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

  if (!fs.statSync(outputFolderPath)) {
    throw new Error(`${outputFolderPath} doesn't exist`)
  }

  // TODO: move process/env stuff to a separate file
  const databaseUrl = process.env.DATABASE_URL
  if (!databaseUrl) {
    throw new Error('DATABASE_URL not set in environment')
  }

  console.log(
    `Deploying files from ${outputFolderPath} to the provided PostgreSQL database`
  )

  const database = new Database(databaseUrl)
  const isReachable = await database.isDatabaseReachable()
  if (!isReachable) {
    throw new Error(`${databaseUrl} not reachable`)
  }
  const db = database.getConnection()

  try {
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

    await Promise.allSettled(
      deployCommands.map((deployCommand) => {
        const name = getFunctionNameFromFilePath(deployCommand.filePath)
        return deployCommand.sqlQueryPromise
          .then(() => {
            console.log(`Deployed ${name} ✅`)
          })
          .catch((e) => {
            console.log(`Failed to deploy ${name} ❌`)
            console.log(e)
          })
      })
    )
  } catch (e) {
    console.error(`Failed to deploy, rolling back`)
    console.error(`Failed with error ${e}`)
  } finally {
    db.end()
  }
}
