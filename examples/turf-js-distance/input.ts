import turfDistance from '@turf/distance'

export function distance(lat: number[], long: number[]): number {
  const pt = turfDistance(lat, long, {
    units: 'kilometers',
  })
  return pt
}

console.log(distance([13.408976, 52.543672], [13.409018, 52.543605]))
