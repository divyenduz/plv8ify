import { Container } from 'inversify'
import { PLV8ifyCLI } from 'src/impl/PLV8ifyCLI'
import TYPES from 'src/interfaces/types'

import { EsBuild } from './impl/EsBuild'

var container = new Container()
container.bind<PLV8ify>(TYPES.PLV8ify).to(PLV8ifyCLI)
container.bind<Bundler>(TYPES.Bundler).to(EsBuild)

export default container
