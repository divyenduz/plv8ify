#!/usr/bin/env node
import { run } from '@stricli/core'
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
  const app = ParseCLI.buildCLI()
  
  // Parse process.argv and run the appropriate command
  await run(app, process.argv.slice(2), {
    process: {
      stdout: { write: (str: string) => process.stdout.write(str) },
      stderr: { write: (str: string) => process.stderr.write(str) },
    },
  })
}

main().catch((error) => {
  console.error('Fatal error:', error)
  process.exit(1)
})