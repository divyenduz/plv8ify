import { match } from 'ts-pattern'

import { Mode } from '../..'

import esbuild = require('esbuild')
import nodeExternals = require('webpack-node-externals')

interface GetBundledJsArgs {
  mode: Mode
  inputFile: string
  outputFolder: string
  scopePrefix: string
}

export const getBundledJs = async ({
  mode,
  inputFile,
  outputFolder,
  scopePrefix,
}: GetBundledJsArgs) => {
  const esbuildResult = await esbuild
    .build({
      entryPoints: [inputFile],
      outdir: outputFolder,
      globalName: scopePrefix,
      platform: 'browser',
      external: [nodeExternals()],
      bundle: true,
      write: false,
      target: 'es2015',
    })
    .catch(() => new Error('esbuild failed'))

  if (esbuildResult instanceof Error) {
    throw esbuildResult
  }

  const esbuildFile = esbuildResult.outputFiles.find((_) => true)
  const bundlesJs = match(mode)
    .with('inline', () => esbuildFile.text)
    .with('start_proc', () =>
      // Remove var from var plv8ify to make it attach to the global scope in start_proc mode
      esbuildFile.text.replace(`var ${scopePrefix} =`, `${scopePrefix} =`)
    )
    .exhaustive()
  return bundlesJs
}
