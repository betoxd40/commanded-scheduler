defmodule Commanded.Scheduler.ScheduledOnce do
  @moduledoc false
  alias Commanded.Scheduler.{Convert, ScheduledOnce}

  @type t :: %__MODULE__{
          schedule_uuid: String.t(),
          name: String.t(),
          command: struct(),
          command_type: String.t(),
          due_at: NaiveDateTime.t()
        }
  @derive Jason.Encoder
  defstruct [
    :schedule_uuid,
    :name,
    :command,
    :command_type,
    :due_at
  ]

  defimpl Commanded.Serialization.JsonDecoder do
    def decode(%ScheduledOnce{} = once) do
      IO.puts "IT SEEMS THAT I'M TRIGGERING THIS"
      once
    end
  end
end
