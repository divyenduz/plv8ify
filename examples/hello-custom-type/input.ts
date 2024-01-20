export interface test_type {
  name: string
  age: number
}

export function hello(test: test_type[]): test_type {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age,
  }
}
