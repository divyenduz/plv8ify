import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
import { Database } from 'src/helpers/Database'
import { ParseCLI } from 'src/helpers/ParseCLI'
import task from 'tasuku'

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

  await task(
    `Check if the --output-folder (${outputFolderPath}) exists`,
    async () => {
      if (!fs.statSync(outputFolderPath)) {
        throw new Error(`${outputFolderPath} doesn't exist`)
      }
    }
  )

  // TODO: move process/env stuff to a separate file
  const databaseUrl = process.env.DATABASE_URL

  await task('Check if the DATABASE_URL env var is set', async () => {
    if (!databaseUrl) {
      throw new Error('DATABASE_URL not set in environment')
    }
  })

  const database = new Database(databaseUrl)
  task('Check if the provided DATABASE_URL is reachable', async () => {
    const isReachable = await database.isDatabaseReachable()
    if (!isReachable) {
      throw new Error(`${databaseUrl} not reachable`)
    }
  })

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

  try {
    await task(
      `Deploying files from ${outputFolderPath} to the provided PostgreSQL database 🚧`.trim(),
      async ({ setTitle }) => {
        const taskGroup = await task.group((task) =>
          deployCommands.map((deployCommand) => {
            const name = getFunctionNameFromFilePath(deployCommand.filePath)
            return task(`Deploying ${name}`, async ({ setTitle }) => {
              return deployCommand.sqlQueryPromise
                .then(() => {
                  setTitle(`Deployed ${name} ✅`)
                })
                .catch((e) => {
                  setTitle(`Failed to deploy ${name} ❌`)
                  console.log(e)
                })
            })
          })
        )
        // TODO: add some batching here
        await Promise.allSettled(taskGroup)
        setTitle(
          `Deployed files from ${outputFolderPath} to the provided PostgreSQL database ✅`.trim()
        )
      }
    )
  } catch (e) {
    console.error(`Failed to deploy`)
    console.error(`Failed with error ${e}`)
  } finally {
    db.end()
  }
}
