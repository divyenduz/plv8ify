#!/usr/bin/env node
import 'reflect-metadata'
import { match } from 'ts-pattern'

import { generateCommand } from './commands/generate'
import { versionCommand } from './commands/version'
import { ParseCLI } from './impl/ParseCLI'

async function main() {
  const CLI = ParseCLI.getCommand()

  match(CLI.command)
    .with('version', () => {
      versionCommand()
    })
    .with('generate', async () => {
      await generateCommand(CLI)
    })
    .exhaustive()
}

main()
