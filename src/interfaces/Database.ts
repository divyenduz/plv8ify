import { Context, Effect, Scope } from 'effect'

import { Database } from '../helpers/Database.js'

export interface DatabaseLayer {
  databaseUrl: string
  database: Effect.Effect<Scope.Scope, never, Database>
}

export const DatabaseLayer = Context.Tag<DatabaseLayer>()
