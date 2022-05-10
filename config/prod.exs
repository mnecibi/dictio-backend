import Config

config :dictio, Dictio.Scheduler,
jobs: [
  # Runs every midnight:
  {"0 * * * *",  {Dictio.Database, :store_word_of_the_day, []}},
]
