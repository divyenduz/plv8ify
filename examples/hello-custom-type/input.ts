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

//@plv8ify-return char(255)
export function howdy(first_name: string, last_name: string): string {
  return `Howdy ${first_name} ${last_name}`
}
