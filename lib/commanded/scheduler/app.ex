defmodule Commanded.Scheduler.App do
  use Commanded.Application,
    otp_app: :commanded_scheduler

  router(Commanded.Scheduler.Router)
end
