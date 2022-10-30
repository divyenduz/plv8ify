interface PLV8ify {
  build: (options: BuildArgs) => Promise<string>
  write: (path: string, string: string) => void
}
