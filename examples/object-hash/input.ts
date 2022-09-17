import objectHash from 'object-hash'

export function point(lat: number, long: number) {
  return objectHash([lat, long])
}

