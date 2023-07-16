#!/usr/bin/env node
import { Effect } from 'effect'
import { match } from 'ts-pattern'

import { deployCommand } from './commands/deploy'
import { generateCommand } from './commands/generate'
import { versionCommand } from './commands/version'
import { ParseCLI } from './helpers/ParseCLI'

async function main() {
  const CLI = ParseCLI.getCommand()

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

const program = Effect.sync(() => {})

Effect.runSync(program)
