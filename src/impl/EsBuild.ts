import { build } from 'esbuild'
import { BundleArgs, Bundler } from 'src/interfaces/Bundler.js'

class BundlerError extends Error {}

export class EsBuild implements Bundler {
  async bundle({ inputFile, define }: BundleArgs) {
    const hasDefines = define && Object.keys(define).length > 0
    const esbuildResult = await build({
      entryPoints: [inputFile],
      format: 'esm',
      platform: 'browser',
      bundle: true,
      write: false,
      ...(hasDefines && { define, minifySyntax: true }),
    }).catch(() => new BundlerError('esbuild failed'))

    if (esbuildResult instanceof Error) {
      throw esbuildResult
    }

    const esbuildFile = esbuildResult.outputFiles.find((_) => true)
    const bundlesJs = esbuildFile.text
    return bundlesJs
  }
}
