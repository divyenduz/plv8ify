import arg from 'arg'

type Command = 'version' | 'generate' | 'deploy'
type DeployMode = 'functions' | 'pg_tle'

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

      '--deploy-mode': String,
      '--pg-tle-extension-name': String,
      '--pg-tle-extension-version': String,
      '--pg-tle-extension-description': String,
    })

    if (args._.length === 0) {
      ParseCLI.throwError(`
Please specify a command. Available commands: generate, version, deploy
`)
      console.error()
      process.exit(1)
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
    const deployMode = (args['--deploy-mode'] || 'functions') as DeployMode
    const pgTLEExtensionName = (args['--pg-tle-extension-name'] ||
      'plv8ify_pg_tle') as string
    const pgTLEExtensionVersion = (args['--pg-tle-extension-version'] ||
      '0.1') as string
    const pgTLEExtensionDescription = (args['--pg-tle-extension-description'] ||
      'plv8ify_pg_tle extension is the default name of extensions deployed with plv8ify, please pass --pg-tle-extension-name as a CLI argument to override this') as string

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
        deployMode,
        pgTLEExtensionName,
        pgTLEExtensionVersion,
        pgTLEExtensionDescrption: pgTLEExtensionDescription,
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
