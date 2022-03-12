const { point: turfPoint } = require('@turf/helpers')

export function point(lat: number, long: number) {
  const pt = turfPoint([lat, long])
  return pt
}
