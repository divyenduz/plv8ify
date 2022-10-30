type Mode = 'inline' | 'start_proc'

interface BundleArgs {
  mode: Mode
  inputFile: string
  scopePrefix: string
}

interface Bundler {
  bundle: (options: BundleArgs) => Promise<string>
}
