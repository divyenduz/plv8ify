import { injectable } from "inversify";
import "reflect-metadata";

import { build } from 'esbuild'
import nodeExternals from 'webpack-node-externals'
import { match } from "ts-pattern";

class BundlerError extends Error {}

// TODO: this is exported only for tests, is that needed?
@injectable()
export class EsBuild implements Bundler {
  async bundle({
    mode,
    inputFile,
    scopePrefix
  }: BundleArgs) {
    const esbuildResult = await build({
      entryPoints: [inputFile],
      globalName: scopePrefix,
      platform: 'browser',
      external: [nodeExternals()],
      bundle: true,
      write: false,
      target: 'es2015',
    })
    .catch(() => new BundlerError('esbuild failed'))

  if (esbuildResult instanceof Error) {
    throw esbuildResult
  }

  const esbuildFile = esbuildResult.outputFiles.find((_) => true)
  const bundlesJs = match(mode)
    .with('inline', () => esbuildFile.text)
    .with('start_proc', () =>
      // Remove var from var plv8ify to make it attach to the global scope in start_proc mode
      esbuildFile.text.replace(`var ${scopePrefix} =`, `this.${scopePrefix} =`)
    )
    .exhaustive()
  return bundlesJs
  }
}
