type Row = {
  // Either JS or plv8 types can be used here
  id: number
  event_name: string
  event_date_time: Date
}

/** @plv8ify_trigger */
export function test(NEW: Row, OLD: Row): Row {
  plv8.elog(NOTICE, 'NEW = ', JSON.stringify(NEW))
  plv8.elog(NOTICE, 'OLD = ', JSON.stringify(OLD))
  plv8.elog(NOTICE, 'TG_OP = ', TG_OP)
  plv8.elog(NOTICE, 'TG_ARGV = ', TG_ARGV)
  if (TG_OP === 'UPDATE') {
    NEW.event_name = NEW.event_name ?? OLD.event_name
    return NEW
  }
  if (TG_OP === 'INSERT') {
    NEW.id = 102
    return NEW
  }
  return NEW
}
