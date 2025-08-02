import { buildApplication, buildCommand, buildRouteMap, booleanParser, numberParser, buildChoiceParser, type TypedFlagParameter } from '@stricli/core'
import { Mode, Volatility } from 'src/interfaces/PLV8ify.js'

export type BundlerType = 'esbuild' | 'bun'

export interface CLIConfig {
  debug: boolean
  bundler: BundlerType
  writeBundlerOutput: boolean
  inputFilePath: string
  outputFolderPath: string
  scopePrefix: string
  pgFunctionDelimiter: string
  fallbackReturnType: string
  mode: Mode
  defaultVolatility: Volatility
  typesFilePath: string
  deployConcurrency: number
}

export class ParseCLI {
  static throwError(message?: string) {
    if (message) {
      console.error(message)
    }
    process.exit(1)
  }

  static buildCLI() {
    const generateCommand = buildCommand({
      loader: async () => import('../commands/generate.js'),
      parameters: {
        flags: {
          'input-file': {
            kind: 'parsed',
            parse: (input) => input,
            brief: 'Input TypeScript file',
            default: 'input.ts',
          },
          'output-folder': {
            kind: 'parsed',
            parse: (input) => input,
            brief: 'Output folder for generated files',
            default: 'plv8ify-dist',
          },
          'bundler': {
            kind: 'parsed',
            parse: (value) => {
              if (value !== 'esbuild' && value !== 'bun') {
                throw new Error(`Invalid bundler: ${value}. Must be 'esbuild' or 'bun'`)
              }
              return value as BundlerType
            },
            brief: 'Bundler to use',
            default: 'esbuild' as BundlerType,
          },
          'debug': {
            kind: 'boolean',
            brief: 'Enable debug mode',
            default: false,
          },
          'types-config-file': {
            kind: 'parsed',
            parse: (input) => input,
            brief: 'Types configuration file',
            default: 'types.ts',
          },
          'write-bundler-output': {
            kind: 'boolean',
            brief: 'Write bundler output to file',
            default: false,
          },
          'scope-prefix': {
            kind: 'parsed',
            parse: (input) => input,
            brief: 'Scope prefix for generated functions',
            default: '',
          },
          'pg-function-delimiter': {
            kind: 'parsed',
            parse: (input) => input,
            brief: 'PostgreSQL function delimiter',
            default: '$plv8ify$',
          },
          'fallback-type': {
            kind: 'parsed',
            parse: (input) => input,
            brief: 'Fallback return type',
            default: 'JSONB',
          },
          'mode': {
            kind: 'parsed',
            parse: (value) => {
              if (value !== 'inline' && value !== 'bundle' && value !== 'start_proc') {
                throw new Error(`Invalid mode: ${value}. Must be 'inline', 'bundle', or 'start_proc'`)
              }
              return value as Mode
            },
            brief: 'PLV8ify mode',
            default: 'inline' as Mode,
          },
          'volatility': {
            kind: 'parsed',
            parse: (value) => {
              if (value !== 'IMMUTABLE' && value !== 'STABLE' && value !== 'VOLATILE') {
                throw new Error(`Invalid volatility: ${value}. Must be 'IMMUTABLE', 'STABLE', or 'VOLATILE'`)
              }
              return value as Volatility
            },
            brief: 'Default function volatility',
            default: 'IMMUTABLE' as Volatility,
          },
        },
      },
      docs: {
        brief: 'Generate PLV8 SQL functions from TypeScript',
      },
      func: async (flags) => {
        const mod = await import('../commands/generate.js')
        const config: CLIConfig = {
          debug: flags['debug'],
          bundler: flags['bundler'],
          writeBundlerOutput: flags['write-bundler-output'],
          inputFilePath: flags['input-file'],
          outputFolderPath: flags['output-folder'],
          scopePrefix: flags['scope-prefix'],
          pgFunctionDelimiter: flags['pg-function-delimiter'],
          fallbackReturnType: flags['fallback-type'],
          mode: flags['mode'],
          defaultVolatility: flags['volatility'],
          typesFilePath: flags['types-config-file'],
          deployConcurrency: 10, // Not used in generate command
        }
        await mod.generateCommand({
          command: 'generate',
          config,
        })
      },
    })

    const deployCommand = buildCommand({
      loader: async () => import('../commands/deploy.js'),
      parameters: {
        flags: {
          'output-folder': {
            kind: 'parsed',
            parse: (input) => input,
            brief: 'Output folder for generated files',
            default: 'plv8ify-dist',
          },
          'debug': {
            kind: 'boolean',
            brief: 'Enable debug mode',
            default: false,
          },
          'deploy-concurrency': {
            kind: 'parsed',
            parse: numberParser,
            brief: 'Deploy concurrency limit',
            default: 10,
          },
        },
      },
      docs: {
        brief: 'Deploy PLV8 functions to PostgreSQL database',
      },
      func: async (flags) => {
        const mod = await import('../commands/deploy.js')
        const config: CLIConfig = {
          debug: flags['debug'],
          bundler: 'esbuild' as BundlerType, // Not used in deploy
          writeBundlerOutput: false,
          inputFilePath: '',
          outputFolderPath: flags['output-folder'],
          scopePrefix: '',
          pgFunctionDelimiter: '',
          fallbackReturnType: '',
          mode: 'inline' as Mode,
          defaultVolatility: 'IMMUTABLE' as Volatility,
          typesFilePath: '',
          deployConcurrency: flags['deploy-concurrency'],
        }
        await mod.deployCommand({
          command: 'deploy',
          config,
        })
      },
    })

    const versionCommand = buildCommand({
      loader: async () => import('../commands/version.js'),
      parameters: {},
      docs: {
        brief: 'Show version information',
      },
      func: async () => {
        const mod = await import('../commands/version.js')
        mod.versionCommand()
      },
    })

    const routeMap = buildRouteMap({
      routes: {
        generate: generateCommand,
        deploy: deployCommand,
        version: versionCommand,
      },
      docs: {
        brief: 'PLV8ify - TypeScript to PostgreSQL PLV8 compiler',
      },
    })

    return buildApplication(routeMap, {
      name: 'plv8ify',
      scanner: {
        caseStyle: 'original',
      },
    })
  }
}