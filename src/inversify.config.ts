import { Container } from 'inversify'
import { PLV8ifyCLI } from 'src/impl/PLV8ifyCLI'
import TYPES from 'src/interfaces/types'

import { EsBuild } from './impl/EsBuild'
import { TsMorph } from './impl/TsMorph'

var container = new Container()
container.bind<PLV8ify>(TYPES.PLV8ify).to(PLV8ifyCLI)
container.bind<Bundler>(TYPES.Bundler).to(EsBuild)
container.bind<TSCompiler>(TYPES.TSCompiler).to(TsMorph)

export default container
