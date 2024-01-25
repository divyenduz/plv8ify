DROP FUNCTION IF EXISTS test();
CREATE OR REPLACE FUNCTION test() RETURNS TRIGGER AS $plv8ify$
// examples/trigger/input.ts
function test(NEW, OLD) {
  plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
  plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
  plv8.elog(NOTICE, "TG_OP = ", TG_OP);
  plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);
  if (TG_OP === "UPDATE") {
    NEW.event_name = NEW.event_name ?? OLD.event_name;
    return NEW;
  }
  if (TG_OP === "INSERT") {
    NEW.id = 102;
    return NEW;
  }
  return NEW;
}


return test(NEW,OLD)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;