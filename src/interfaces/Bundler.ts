interface BuildArgs {
  mode: 'inline' | 'start_proc' // TODO: fixme, common type globally, bundler shouldn't care about inline/start_proc from plv8
  inputFile: string
  scopePrefix: string
}

interface Bundler {
  build: (options: BuildArgs) => Promise<string>
}
