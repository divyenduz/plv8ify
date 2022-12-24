import { Container } from 'inversify'

import { EsBuild } from './impl/EsBuild'
import { PLV8ifyCLI } from './impl/PLV8ifyCLI'
import { TsMorph } from './impl/TsMorph'
import TYPES from './interfaces/types'

var container = new Container()
container.bind<PLV8ify>(TYPES.PLV8ify).to(PLV8ifyCLI)
container.bind<Bundler>(TYPES.Bundler).to(EsBuild)
container.bind<TSCompiler>(TYPES.TSCompiler).to(TsMorph)

export default container
