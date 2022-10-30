import fs from 'fs'
import { inject, injectable } from 'inversify'
import "reflect-metadata";

import TYPES from 'src/interfaces/types'

@injectable()
export class PLV8ifyCLI implements PLV8ify {
  @inject(TYPES.Bundler) private _bundler: Bundler;
  build(options: BuildArgs) {
    return this._bundler.build(options)
  }

  private writeFile(filePath: string, content: string) {
    try {
      fs.unlinkSync(filePath)
    } catch (e) {}
    fs.writeFileSync(filePath, content)
  }

  write(path: string, string: string) {
    this.writeFile(path, string)
  }
}
