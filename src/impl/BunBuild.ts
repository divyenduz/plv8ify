import { BundleArgs, Bundler } from 'src/interfaces/Bundler'
import nodeExternals from 'webpack-node-externals'

class BundlerError extends Error {}

export class BunBuild implements Bundler {
  async bundle({ inputFile }: BundleArgs) {
    const bunBuildResult = await Bun.build({
      entrypoints: [inputFile],
      external: [nodeExternals()],
      format: 'esm',
      target: 'browser',
      splitting: false,
    }).catch(() => new BundlerError('esbuild failed'))

    if (bunBuildResult instanceof Error) {
      throw bunBuildResult
    }

    const esbuildFile = bunBuildResult.outputs.find((_) => true)
    const bundlesJs = await esbuildFile.text()
    return bundlesJs
  }
}
