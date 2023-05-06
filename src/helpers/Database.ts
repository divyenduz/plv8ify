import postgres from 'postgres'

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
