import postgres from 'postgres'

export class Database {
  private databaseUrl: string
  private db: ReturnType<typeof postgres>
  constructor(databaseUrl) {
    this.databaseUrl = databaseUrl
    this.db = postgres(databaseUrl)
  }

  getConnection() {
    return this.db
  }

  async isDatabaseReachable() {
    try {
      await this.db`SELECT 1`
      return true
    } catch (e) {
      return false
    }
  }
}
