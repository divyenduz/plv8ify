import { build } from 'esbuild'
import assert from 'node:assert/strict'

class BundlerError extends Error {}

export class EsBuild implements Bundler {
  async bundle({ inputFile, globalName }: BundleArgs) {
    const esbuildResult = await build({
      entryPoints: [inputFile],
      globalName,
      platform: 'browser',
      bundle: true,
      write: false,
      target: 'es2015',
    }).catch(() => new BundlerError('esbuild failed'))

    if (esbuildResult instanceof Error) {
      throw esbuildResult
    }

    const outputFiles= esbuildResult.outputFiles || []
    const esbuildFile = outputFiles.find((_) => true)
    const bundlesJs = esbuildFile?.text
    assert(bundlesJs !== undefined, 'Failed to bundle JS')
    return bundlesJs
  }
}
