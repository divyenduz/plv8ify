import { test_type } from '../hello-custom-type/input'

export function hello(test: test_type[]): test_type {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age,
  }
}
