import Config

config :dictio, Dictio.Scheduler,
jobs: [
  # Runs every midnight:
  {"@daily",  {Dictio.Database, :store_word_of_the_day, []}},
]
