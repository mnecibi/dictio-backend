import Config

config :dictio, Dictio.Scheduler,
jobs: [
  # Runs every midnight:
  {"* * * * *",  {Dictio.Database, :store_word_of_the_day, []}},
]
