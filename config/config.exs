import Config

config :dictio,
  pool_size: 2,
  folder: "files",
  file_name: "dictio.json"

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
