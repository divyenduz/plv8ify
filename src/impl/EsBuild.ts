import { build } from 'esbuild'
import assert from 'node:assert/strict'

import { Effect } from 'effect'

export class BundlerError extends Error {}

export class EsBuild implements Bundler {
  async bundle({ inputFile, globalName }: BundleArgs) {
    const ESBuildEffect = Effect.tryPromise({
      try: () => {
        return build({
          entryPoints: [inputFile],
          globalName,
          platform: 'browser',
          bundle: true,
          write: false,
          target: 'es2015',
        })
      },
      catch: (unknown) => new BundlerError(`Error state: ${unknown}`),
    })

    const esbuildResult = await Effect.runPromise(ESBuildEffect)

    const BundleJSEffect = Effect.try({
      try: () => {
        const outputFiles = esbuildResult.outputFiles || []
        const esbuildFile = outputFiles.find((_) => true)
        const bundlesJs = esbuildFile?.text
        assert(bundlesJs !== undefined, 'Failed to bundle JS')
        return bundlesJs
      },
      catch: (unknown) => new BundlerError(`Error state: ${unknown}`),
    })

    const bundleJs = Effect.runSync(BundleJSEffect)
    return bundleJs
  }
}
