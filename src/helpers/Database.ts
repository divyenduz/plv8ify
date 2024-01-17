import { Layer } from 'effect'
import postgres from 'postgres'
import { DatabaseLayer } from 'src/interfaces/Database'

export class Database {
  private databaseUrl: string
  private db: ReturnType<typeof postgres>
  constructor(databaseUrl) {
    this.databaseUrl = databaseUrl
  }

  getConnection() {
    if (this.db) {
      return this.db
    }
    this.db = postgres(this.databaseUrl)
    return this.db
  }

  endConnection() {
    this.db.end()
  }

  async isDatabaseReachable() {
    if (!this.db) {
      this.getConnection()
    }
    try {
      await this.db`SELECT 1`
      return true
    } catch (e) {
      return false
    }
  }
}

export const DatabaseLive = Layer.succeed(
  DatabaseLayer,
  DatabaseLayer.of({
    databaseUrl: process.env.DATABASE_URL,
    database: new Database(process.env.DATABASE_URL),
  })
)
