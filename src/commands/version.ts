export function versionCommand() {
  const pkg = require('../../package.json')
  console.log(`Version: ${pkg.version}`)
  process.exit(0)
}
