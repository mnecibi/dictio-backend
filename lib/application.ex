defmodule Dictio.Application do
  use Application

  def start(_, _) do
    Dictio.System.start_link()
  end
end
