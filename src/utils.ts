import * as fs from 'fs'

export const writeFile = (filePath: string, content: string) => {
  try {
    fs.unlinkSync(filePath)
  } catch (e) {}
  fs.writeFileSync(filePath, content)
}
