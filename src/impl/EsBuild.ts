import { build } from 'esbuild'
import { BundleArgs, Bundler } from 'src/interfaces/Bundler'
import nodeExternals from 'webpack-node-externals'

class BundlerError extends Error {}

export class EsBuild implements Bundler {
  async bundle({ inputFile }: BundleArgs) {
    const esbuildResult = await build({
      entryPoints: [inputFile],
      external: [nodeExternals()],
      format: 'esm',
      platform: 'browser',
      bundle: true,
      write: false,
    }).catch(() => new BundlerError('esbuild failed'))

    if (esbuildResult instanceof Error) {
      throw esbuildResult
    }

    const esbuildFile = esbuildResult.outputFiles.find((_) => true)
    const bundlesJs = esbuildFile.text
    return bundlesJs
  }
}
