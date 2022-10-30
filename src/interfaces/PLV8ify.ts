interface PLV8ify {
  build: (options: BundleArgs) => Promise<string>
  write: (path: string, string: string) => void
}
