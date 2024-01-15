import { Effect } from 'effect'
import { createRequire } from 'module'

const require = createRequire(import.meta.url)

class VersionCmdError extends Error {
  readonly _tag = 'VersionCmdError'
}

export function versionCommand() {
  return Effect.try({
    try: () => {
      // TODO: require can fail, this effect is not pure
      const pkg = require('../../package.json')
      console.log(`Version: ${pkg.version}`)
    },
    catch: (e) => {
      return new VersionCmdError(`${e}`)
    },
  })
}
