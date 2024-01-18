// Special values for trigger functions.
// Included from @types/pg
declare var TG_NAME: string
declare var TG_WHEN: string
declare var TG_LEVEL: string
declare var TG_OP: string
declare var TG_RELID: number
declare var TG_TABLE_NAME: string
declare var TG_TABLE_SCHEMA: string
declare var TG_ARGV: string[]

type testRow = {
  // Either JS or plv8 types can be used here
  id: number
  event_name: string
  event_date_time: Date
}

// plv8_trigger
export function test(NEW: testRow, OLD: testRow): testRow {
  if (TG_OP === 'UPDATE') {
    NEW.event_name = NEW.event_name ?? OLD.event_name
    return NEW
  }
  if (TG_OP === 'INSERT') {
    NEW.id = 102
    return NEW
  }
}
