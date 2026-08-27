type Config = {
  endpoint: string
  retries: number
}

const config = {
  endpoint: 'https://api.example.com',
  retries: 3,
} satisfies Config

export function getEndpoint() {
  return config.endpoint
}
