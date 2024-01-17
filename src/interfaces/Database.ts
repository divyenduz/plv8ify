import { Context } from 'effect'

import { Database } from '../helpers/Database.js'

export interface DatabaseLayer {
  databaseUrl: string
  database: Database
}

export const DatabaseLayer = Context.Tag<DatabaseLayer>()
