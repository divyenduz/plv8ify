import { createRequire } from 'module'

const require = createRequire(import.meta.url)

export function versionCommand() {
  const pkg = require('../../package.json')
  console.log(`plv8ify v${pkg.version}`)
  console.log(`TypeScript/JavaScript to PostgreSQL PLV8 function bundler`)
  process.exit(0)
}
