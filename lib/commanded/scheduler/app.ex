defmodule Commanded.Scheduler.App do
  use Commanded.Application,
    otp_app: :commanded_scheduler,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Commanded.Scheduler.EventStore
    ],
    pubsub: :local,
    registry: :local

  router(Commanded.Scheduler.Router)
end
