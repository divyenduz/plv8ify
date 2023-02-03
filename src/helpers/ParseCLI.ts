import arg from 'arg'

type Command = 'version' | 'generate' | 'deploy'

export class ParseCLI {
  static getCommand() {
    // CLI Args
    // TODO: scope config options to commands
    const args = arg({
      '--input-file': String,
      '--output-folder': String,
      '--write-bundler-output': Boolean,
      '--scope-prefix': String,
      '--pg-function-delimiter': String,
      '--fallback-type': String,
      '--mode': String,
      '--volatility': String,
      '--debug': Boolean,
    })

    if (args._.length === 0) {
      throw new Error(
        `Please specify a command. Available commands: generate, version, deploy`
      )
    }

    const inputFilePath = args['--input-file'] || 'input.ts'
    const outputFolderPath = args['--output-folder'] || 'plv8ify-dist'
    const writeBundlerOutput = args['--write-bundler-output'] || false
    const scopePrefix = args['--scope-prefix'] || 'plv8ify'
    const pgFunctionDelimiter = args['--pg-function-delimiter'] || '$plv8ify$'
    const fallbackReturnType = args['--fallback-type'] || 'JSONB'
    const mode = (args['--mode'] || 'inline') as Mode
    const defaultVolatility = (args['--volatility'] ||
      'IMMUTABLE') as Volatility

    return {
      command: args._[0] as Command,
      config: {
        writeBundlerOutput,
        inputFilePath,
        outputFolderPath,
        scopePrefix,
        pgFunctionDelimiter,
        fallbackReturnType,
        mode,
        defaultVolatility,
      },
    }
  }
}
