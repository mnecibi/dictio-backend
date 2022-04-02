defmodule Dictio.System do
  def start_link do
    Supervisor.start_link(
      [
        Dictio.Database,
        Dictio.Scheduler
      ],
      strategy: :one_for_one
    )
  end
end
