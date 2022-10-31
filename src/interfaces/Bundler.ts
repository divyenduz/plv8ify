interface BundleArgs {
  inputFile: string
  globalName: string // TODO: fixme, this is a part of esbuild config, ideally this shouldn't be a part of the common interface (unless all bundlers use this)
}

interface Bundler {
  bundle: (options: BundleArgs) => Promise<string>
}
