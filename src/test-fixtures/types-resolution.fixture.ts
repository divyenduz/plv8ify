export interface Point {
  x: number
  y: number
}

export namespace Geo {
  export interface Coord {
    lat: number
    lng: number
  }
}

export function testBasic(a: number, b: string, c: boolean): void {}

export function testArrays(a: number[], b: string[], c: Array<boolean>): number[] {
  return a
}

export function testCustomTypes(p: Point, points: Point[], pointsGeneric: Array<Point>): Point {
  return p
}

export function testNamespaces(c: Geo.Coord, coords: Geo.Coord[], coordsGeneric: Array<Geo.Coord>): Geo.Coord {
  return c
}

export function testUnions(u: string | number): string | number {
  return u
}
