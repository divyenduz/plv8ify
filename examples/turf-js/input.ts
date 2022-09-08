const { point: turfPoint } = require('@turf/helpers')

export function point(lat: number, long: number) {
  const pt = turfPoint([lat, long])
  return pt
}

//@plv8ify-volatility-STABLE
export function stablePoint(lat: number, long: number) {
  const pt = turfPoint([lat, long])
  return pt
}
