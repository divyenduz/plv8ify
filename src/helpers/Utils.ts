import fs from 'fs'

export function writeFile(filePath: string, content: string) {
  try {
    fs.unlinkSync(filePath)
  } catch (e) {}
  fs.writeFileSync(filePath, content)
}

type Runtime = 'node' | 'bun'

export function getRuntime(): Runtime {
  if (typeof Bun !== 'undefined') {
    return 'bun'
  }
  if (typeof process !== 'undefined') {
    return 'node'
  }
  throw new Error('Unknown runtime')
}
