interface BuildArgs {
  mode: 'inline' | 'start_proc' // TODO: fixme, common type globally
  inputFile: string
  outputFolder: string
  scopePrefix: string
}

interface Bundler {
  build: (options: BuildArgs) => Promise<string>
}
