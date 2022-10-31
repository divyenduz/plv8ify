interface BundleArgs {
  inputFile: string
  scopePrefix: string
}

interface Bundler {
  bundle: (options: BundleArgs) => Promise<string>
}
