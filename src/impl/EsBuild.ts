import { build } from 'esbuild'
import { injectable } from 'inversify'
import nodeExternals from 'webpack-node-externals'
import "reflect-metadata"

class BundlerError extends Error {}

// TODO: fixme, this is exported only for tests, is that needed?
@injectable()
export class EsBuild implements Bundler {
  async bundle({ inputFile, globalName }: BundleArgs) {
    const esbuildResult = await build({
      entryPoints: [inputFile],
      globalName,
      platform: 'browser',
      external: [nodeExternals()],
      bundle: true,
      write: false,
      target: 'es2015',
    }).catch(() => new BundlerError('esbuild failed'))

    if (esbuildResult instanceof Error) {
      throw esbuildResult
    }

    const esbuildFile = esbuildResult.outputFiles.find((_) => true)
    const bundlesJs = esbuildFile.text
    return bundlesJs
  }
}
