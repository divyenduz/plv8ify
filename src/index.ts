#!/usr/bin/env node
import { match } from 'ts-pattern'

import { deployCommand } from './commands/deploy'
import { generateCommand } from './commands/generate'
import { versionCommand } from './commands/version'
import { ParseCLI } from './helpers/ParseCLI'

type Runtime = 'node' | 'bun'

function getRuntime(): Runtime {
  if (typeof Bun !== 'undefined') {
    return 'bun'
  }
  if (typeof process !== 'undefined') {
    return 'node'
  }
  throw new Error('Unknown runtime')
}

async function main() {
  const runtime = getRuntime()
  if (process.env.DEBUG) {
    console.log(`DEBUG: Running in ${runtime} runtime`)
  }

  const CLI = ParseCLI.getCommand()

  if (CLI.config.bundler === 'bun' && runtime === 'node') {
    throw new Error('Bun bundler is not supported in node runtime')
  }

  match(CLI.command)
    .with('version', () => {
      versionCommand()
    })
    .with('generate', async () => {
      await generateCommand(CLI)
    })
    .with('deploy', async () => {
      await deployCommand(CLI)
    })
    .exhaustive()
}

main()
