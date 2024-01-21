import { Effect } from 'effect'
import task, { TaskFunction } from 'tasuku'

class TasukuTaskFailed extends Error {
  readonly _tag = 'TasukuTaskFailed'
}

export function tasukuTask<T>(title: string, taskFunction: TaskFunction<T>) {
  return Effect.tryPromise({
    try: async () => task(title, taskFunction),
    catch: (e) => {
      return new TasukuTaskFailed(`${e}`)
    },
  }).pipe(
    Effect.flatMap((tasukuTask) => {
      if (tasukuTask.state === 'error') {
        return Effect.fail(new TasukuTaskFailed())
      }
      return Effect.succeed(tasukuTask.result)
    })
  )
}
