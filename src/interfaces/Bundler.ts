export interface BundleArgs {
  inputFile: string
  define?: Record<string, string>
}

export interface Bundler {
  bundle: (options: BundleArgs) => Promise<string>
}
