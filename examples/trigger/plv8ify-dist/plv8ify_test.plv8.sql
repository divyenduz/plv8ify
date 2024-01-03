DROP FUNCTION IF EXISTS plv8ify_test();
CREATE OR REPLACE FUNCTION plv8ify_test() RETURNS TRIGGER AS $plv8ify$
// input.ts
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
}


return test(NEW,OLD)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;