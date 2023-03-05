import { atan2 as mathjsAtan2 } from 'mathjs'

export function atan2(one: number, two: number): number {
  const result = mathjsAtan2(one, two)
  return result
}
