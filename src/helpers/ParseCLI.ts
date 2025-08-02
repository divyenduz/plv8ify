import arg from 'arg'
import { Mode, Volatility } from 'src/interfaces/PLV8ify.js'

type Command = 'version' | 'generate' | 'deploy'
export type BundlerType = 'esbuild' | 'bun'

export class ParseCLI {
  static getCommand() {
    // CLI Args
    // TODO: scope config options to commands
    const args = arg({
      '--input-file': String,
      '--output-folder': String,
      '--types-config-file': String,
      '--bundler': String, // 'esbuild' or 'bun'
      '--write-bundler-output': Boolean,
      '--scope-prefix': String,
      '--pg-function-delimiter': String,
      '--fallback-type': String,
      '--mode': String,
      '--volatility': String,
      '--debug': Boolean,
      '--deploy-concurrency': Number,
    })

    if (args._.length === 0) {
      ParseCLI.throwError(`
plv8ify - Bundle TypeScript/JavaScript and generate PostgreSQL PLV8 functions

Usage: plv8ify <command> [options]

Commands:
  generate    Bundle input file and generate SQL functions
  deploy      Deploy generated SQL functions to PostgreSQL database
  version     Show version information

Run 'plv8ify <command>' for more information on a specific command.
`)
      console.error()
      process.exit(1)
    }

    const debug = args['--debug'] || false
    const inputFilePath = args['--input-file'] || 'input.ts'
    const outputFolderPath = args['--output-folder'] || 'plv8ify-dist'
    const bundler = args['--bundler'] || 'esbuild'
    const writeBundlerOutput = args['--write-bundler-output'] || false
    const scopePrefix = args['--scope-prefix'] || ''
    const pgFunctionDelimiter = args['--pg-function-delimiter'] || '$plv8ify$'
    const fallbackReturnType = args['--fallback-type'] || 'JSONB'
    const mode = (args['--mode'] || 'inline') as Mode
    const defaultVolatility = (args['--volatility'] ||
      'IMMUTABLE') as Volatility
    const typesFilePath = args['--types-config-file'] || 'types.ts'
    const deployConcurrency = args['--deploy-concurrency'] || 10

    return {
      command: args._[0] as Command,
      config: {
        debug,
        bundler: bundler as BundlerType,
        writeBundlerOutput,
        inputFilePath,
        outputFolderPath,
        scopePrefix,
        pgFunctionDelimiter,
        fallbackReturnType,
        mode,
        defaultVolatility,
        typesFilePath,
        deployConcurrency,
      },
    }
  }

  static throwError(message?: string) {
    if (message) {
      console.error(message)
    }
    process.exit(1)
  }
}
