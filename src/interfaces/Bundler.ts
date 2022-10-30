interface BundleArgs {
  mode: 'inline' | 'start_proc' // TODO: fixme, common type globally, bundler shouldn't care about inline/start_proc from plv8
  inputFile: string
  scopePrefix: string
}

interface Bundler {
  bundle: (options: BundleArgs) => Promise<string>
}
