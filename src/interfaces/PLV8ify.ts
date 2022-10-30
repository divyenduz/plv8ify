interface BuildArgs {
  mode: 'inline' | 'start_proc' // TODO: fixme, common type globally
  inputFile: string
  outputFolder: string
  scopePrefix: string
}

interface PLV8ify {
  build: (options: BuildArgs) => Promise<string>
  write: (path: string, string: string) => void
}
