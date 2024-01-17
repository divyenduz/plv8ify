import dotenv from 'dotenv'
import { Effect } from 'effect'
import fs from 'fs'
import path from 'path'
import task, { TaskFunction } from 'tasuku'

import { Database } from '../helpers/Database.js'
import { Config } from '../helpers/ParseCLI.js'

dotenv.config()

class DatabaseQueryFailedError extends Error {
  readonly _tag = 'DatabaseQueryFailedError'
}

// File name/function name are configurable but with the same variable, so they will always match (so far)
function getFunctionNameFromFilePath(filePath: string) {
  const fileName = path.basename(filePath, '.plv8.sql')
  return fileName
}

function tasukuTask(title: string, taskFunction: TaskFunction<void>) {
  return Effect.tryPromise({
    try: () => task(title, taskFunction),
    catch: (e) => {
      return new Error(`${e}`)
    },
  })
}

function checkOutputFolderTaskEffectFn() {
  return Config.pipe(
    Effect.flatMap((config) => {
      const commandConfig = config.getCommand()
      const { outputFolderPath } = commandConfig.config
      return Effect.succeed(outputFolderPath)
    }),
    Effect.flatMap((outputFolderPath) => {
      const outputFolderExistsTask = tasukuTask(
        `Check if the --output-folder (${outputFolderPath}) exists`,
        async ({ setError }) => {
          if (!fs.statSync(outputFolderPath)) {
            const errorMessage = `${outputFolderPath} doesn't exist`
            setError(errorMessage)
          }
        }
      )
      return outputFolderExistsTask
    }),
    Effect.flatMap((outputFolderExistsTask) => {
      if (outputFolderExistsTask.state === 'error') {
        throw new Error('Output folder does not exist')
      }
      return Effect.succeed(outputFolderExistsTask)
    })
  )
}

function checkDatabaseUrlIsSetTaskEffectFn() {
  // TODO: move process/env stuff to a separate file
  const databaseUrl = process.env.DATABASE_URL
  const databaseUrlIsSetTask = tasukuTask(
    'Check if the DATABASE_URL env var is set',

    async ({ setError }) => {
      if (!databaseUrl) {
        const errorMessage = `DATABASE_URL not set in environment`
        setError(errorMessage)
      }
    }
  )
  return databaseUrlIsSetTask.pipe(
    Effect.flatMap((databaseUrlIsSetTask) => {
      if (databaseUrlIsSetTask.state === 'error') {
        throw new Error('DATABASE_URL not set in environment')
      }
      return Effect.succeed(databaseUrlIsSetTask)
    })
  )
}

function checkDatabaseIsReachableTaskEffectFn(database: Database) {
  // TODO: this should happen once!
  const databaseUrl = process.env.DATABASE_URL
  const isDatabaseReachableTask = tasukuTask(
    'Check if the provided DATABASE_URL is reachable',
    async ({ setError }) => {
      const isReachable = await database.isDatabaseReachable()
      if (!isReachable) {
        const errorMessage = `Provided DATABASE_URL: ${databaseUrl} is not reachable`
        setError(errorMessage)
      }
    }
  )
  return isDatabaseReachableTask.pipe(
    Effect.flatMap((isDatabaseReachableTask) => {
      if (isDatabaseReachableTask.state === 'error') {
        throw new Error('Provided DATABASE_URL is not reachable')
      }
      return Effect.succeed(isDatabaseReachableTask)
    })
  )
}

function deployCommandsTaskEffectFn(database: Database) {
  const filePathsEffect = Config.pipe(
    Effect.flatMap((config) => {
      const commandConfig = config.getCommand()
      const { outputFolderPath } = commandConfig.config
      const filePaths = fs
        .readdirSync(outputFolderPath)
        // Only extract .plv8.sql files, this will need to change if we ever make the extension configurable
        .filter((file) => file.endsWith('.plv8.sql'))
        .map((file) => {
          const filePath = path.join(outputFolderPath, file)
          return filePath
        })
      return Effect.succeed(filePaths)
    })
  )

  const deployCommandsEffect = filePathsEffect.pipe(
    Effect.flatMap((filePaths) => {
      const db = database.getConnection()
      const deployCommands = filePaths.map((filePath) => {
        const name = getFunctionNameFromFilePath(filePath)
        const deployCommandTasukuTaskEffect = tasukuTask(
          `Deploying ${name}`,
          async ({ setTitle, setError }) => {
            Effect.tryPromise({
              try: () => {
                const r = db.file(filePath)
                setTitle(`Deployed ${name}`)
                return r
              },
              catch: (e) => {
                if (e instanceof Error) {
                  setError(`Failed to deploy ${name} (because of ${e.message})`)
                  return new DatabaseQueryFailedError(`${e}`)
                }
              },
            })
            try {
              await db.file(filePath)
              setTitle(`Deployed ${name}`)
            } catch (e) {
              setError(`Failed to deploy ${name} (because of ${e.message})`)
              throw new DatabaseQueryFailedError(`${e}`)
            }
          }
        )

        return deployCommandTasukuTaskEffect
      })
      return Effect.all(deployCommands)
    })
  )
  return deployCommandsEffect
}

export function deployCommand() {
  const checkOutputFolderTaskEffect = checkOutputFolderTaskEffectFn()
  const checkDatabaseUrlIsSetTaskEffect = checkDatabaseUrlIsSetTaskEffectFn()

  // TODO: move process/env stuff to a separate file
  // TODO: unify so this is accessed in one place
  const databaseUrl = process.env.DATABASE_URL
  // TODO: turn into a Layer or Resource
  const database = new Database(databaseUrl)
  const checkDatabaseIsReachableTaskEffect =
    checkDatabaseIsReachableTaskEffectFn(database)

  const deployCommandsTaskEffect = deployCommandsTaskEffectFn(database)

  // TODO: somehow terminate database connection
  return Effect.all([
    checkOutputFolderTaskEffect,
    checkDatabaseUrlIsSetTaskEffect,
    checkDatabaseIsReachableTaskEffect,
    deployCommandsTaskEffect,
  ])
}
