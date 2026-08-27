import { atan2 as mathjsAtan2 } from 'mathjs'

export function atan2(one: number, two: number): number {
  return mathjsAtan2(one, two)
}

export function add(a: number, b: number): number {
  return a + b
}
