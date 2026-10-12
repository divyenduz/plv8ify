DROP FUNCTION IF EXISTS paginate(page float8,pageSize float8,descending boolean);
CREATE OR REPLACE FUNCTION paginate(page float8 DEFAULT 1,pageSize float8 DEFAULT 25,descending boolean DEFAULT false) RETURNS text AS $plv8ify$
// examples/parameter-defaults/input.ts
function resolveTermKeys(purchaseOption, termLength = null, paymentOption = null, spDescription = "%") {
  const terms = [
    { key: "on_demand", purchase: "on_demand", length: "", payment: "" },
    { key: "reserved_1yr_no_upfront", purchase: "reserved", length: "1yr", payment: "No Upfront" },
    { key: "reserved_3yr_all_upfront", purchase: "reserved", length: "3yr", payment: "All Upfront" },
    { key: "savings_plan_compute_1yr_no_upfront", purchase: "savings_plan", length: "1yr", payment: "No Upfront" }
  ];
  const like = (subject, pattern) => new RegExp(`^${pattern.replace(/[.*+?^${}()|[\]\\]/g, "\\$&").replace(/%/g, ".*")}$`).test(subject);
  return terms.filter((t) => t.purchase === purchaseOption).filter((t) => purchaseOption === "on_demand" || like(t.length, `${termLength ?? ""}%`)).filter((t) => purchaseOption === "on_demand" || like(t.payment, `${paymentOption ?? ""}%`)).filter((t) => purchaseOption !== "savings_plan" || like(t.key, spDescription)).map((t) => t.key).join(",");
}
function paginate(page = 1, pageSize = 25, descending = false) {
  return `${page}/${pageSize}/${descending ? "desc" : "asc"}`;
}
function stamp(label, at = (/* @__PURE__ */ new Date()).toISOString()) {
  return `${label}@${at}`;
}

return paginate(page,pageSize,descending)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;