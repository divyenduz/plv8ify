import dotenv from 'dotenv'
import { Effect } from 'effect'
import fs from 'fs'
import path from 'path'
import { Database } from 'src/helpers/Database.js'
import { DatabaseLayer } from 'src/interfaces/Database.js'
import { tasukuTask } from 'src/lib/tasukuEffect.js'

import { Config } from '../helpers/ParseCLI.js'

dotenv.config()

// File name/function name are configurable but with the same variable, so they will always match (so far)
function getFunctionNameFromFilePath(filePath: string) {
  const fileName = path.basename(filePath, '.plv8.sql')
  return fileName
}

function checkOutputFolderTaskEffectFn() {
  return Config.pipe(
    Effect.map((config) => {
      const commandConfig = config.getCommand()
      const { outputFolderPath } = commandConfig.config
      return outputFolderPath
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
    Effect.mapError((e) => {
      class OutputFolderDoesNotExistError extends Error {
        readonly _tag = 'OutputFolderDoesNotExistError'
      }
      return new OutputFolderDoesNotExistError(`${e}`)
    })
  )
}

class DatabaseUrlNotSetError extends Error {
  readonly _tag = 'DatabaseUrlNotSetError'
  readonly message = `DATABASE_URL not set in environment`

  public static getMessage() {
    return new DatabaseUrlNotSetError().message
  }
}
function checkDatabaseUrlIsSetTaskEffectFn() {
  return DatabaseLayer.pipe(
    Effect.flatMap((databaseLayer) => {
      const databaseUrlIsSetTask = tasukuTask(
        'Check if the DATABASE_URL env var is set',
        async ({ setError }) => {
          if (!databaseLayer.databaseUrl) {
            setError(DatabaseUrlNotSetError.getMessage())
          }
        }
      )
      return databaseUrlIsSetTask
    }),
    Effect.mapError((e) => {
      return new DatabaseUrlNotSetError()
    })
  )
}

class DatabaseNotReachableError extends Error {
  readonly _tag = 'DatabaseNotReachableError'
  readonly message = `Provided DATABASE_URL (${process.env.DATABASE_URL}) is not reachable`
  public static getMessage() {
    return new DatabaseNotReachableError().message
  }
}
function checkDatabaseIsReachableTaskEffectFn() {
  return DatabaseLayer.pipe(
    Effect.flatMap((databaseLayer) => {
      return databaseLayer.database
    }),
    Effect.flatMap((database) => {
      const isDatabaseReachableTask = tasukuTask(
        'Check if the provided DATABASE_URL is reachable',
        async ({ setError }) => {
          const isReachable = await database.isDatabaseReachable()
          if (!isReachable) {
            const errorMessage = DatabaseNotReachableError.getMessage()
            setError(errorMessage)
          }
        }
      )
      return isDatabaseReachableTask
    }),
    Effect.mapError(() => {
      return new DatabaseNotReachableError()
    })
  )
}

class DeployCommandFailedError extends Error {
  readonly _tag = 'DeployCommandFailedError'
  readonly message = `Failed to deploy command`
  public static getMessage() {
    return new DeployCommandFailedError().message
  }
}
function deployCommandsTaskEffectFn() {
  const filePathsEffect = Config.pipe(
    Effect.map((config) => {
      const commandConfig = config.getCommand()
      const { outputFolderPath } = commandConfig.config
      return outputFolderPath
    }),
    Effect.map((outputFolderPath) => {
      const filePaths = fs
        .readdirSync(outputFolderPath)
        // Only extract .plv8.sql files, this will need to change if we ever make the extension configurable
        .filter((file) => file.endsWith('.plv8.sql'))
        .map((file) => {
          const filePath = path.join(outputFolderPath, file)
          return filePath
        })
      return filePaths
    })
  )

  const deployCommandsEffect = DatabaseLayer.pipe(
    Effect.flatMap((databaseLayer) => {
      return databaseLayer.database
    }),
    Effect.flatMap((database) => {
      return filePathsEffect.pipe(
        Effect.flatMap((filePaths) => {
          const db = database.getConnection()
          const deployCommands = filePaths.map((filePath) => {
            const name = getFunctionNameFromFilePath(filePath)
            const deployCommandTasukuTaskEffect = tasukuTask(
              `Deploying ${name}`,
              async ({ setTitle, setError }) => {
                try {
                  const r = await db.file(filePath)
                  setTitle(`Deployed ${name}`)
                } catch (e) {
                  setError(`Failed to deploy ${name} (because of ${e.message})`)
                }
              }
            )

            return deployCommandTasukuTaskEffect
          })
          return Effect.all(deployCommands)
        })
      )
    }),
    Effect.mapError(() => {
      return new DeployCommandFailedError()
    })
  )

  return deployCommandsEffect
}

export function deployCommand() {
  const checkOutputFolderTaskEffect = checkOutputFolderTaskEffectFn()
  const checkDatabaseUrlIsSetTaskEffect = checkDatabaseUrlIsSetTaskEffectFn()

  const checkDatabaseIsReachableTaskEffect =
    checkDatabaseIsReachableTaskEffectFn()

  const deployCommandsTaskEffect = deployCommandsTaskEffectFn()

  return Effect.all([
    checkOutputFolderTaskEffect,
    checkDatabaseUrlIsSetTaskEffect,
    checkDatabaseIsReachableTaskEffect,
    deployCommandsTaskEffect,
  ]).pipe(
    Effect.catchAll((e) => {
      // This is a hack to make sure the tasuku tasks have time to print their output
      setTimeout(() => {
        // TODO: collect errors for actual deploy commands
        // If 3 out of 4 functions can be deployed, they should be deployed
        process.exit(1)
      }, 100)
      class ApplicationWillTerminateError {
        readonly _tag = 'ApplicationWillTerminateError'
      }
      return Effect.fail(new ApplicationWillTerminateError())
    })
  )
}
