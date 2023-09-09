export interface BundleArgs {
  inputFile: string
}

export interface Bundler {
  bundle: (options: BundleArgs) => Promise<string>
}
