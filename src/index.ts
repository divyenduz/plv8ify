#!/usr/bin/env node
import { match } from 'ts-pattern'

import { deployCommand } from './commands/deploy.js'
import { generateCommand } from './commands/generate.js'
import { versionCommand } from './commands/version.js'
import { ParseCLI } from './helpers/ParseCLI.js'

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
  const CLI = ParseCLI.getCommand()

  if (CLI.config.debug) {
    console.log(`DEBUG: Running in ${runtime} runtime`)
  }

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
