defmodule Commanded.Scheduler.EventStore do
  use EventStore, otp_app: :commanded_scheduler
end
