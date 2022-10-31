interface BundleArgs {
  inputFile: string
  globalName: string
}

interface Bundler {
  bundle: (options: BundleArgs) => Promise<string>
}
