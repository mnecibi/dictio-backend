import Config

config :dictio, Dictio.Scheduler,
  jobs: [
    # Every minute
    {"* * * * *",  {Dictio.Database, :store_word_of_the_day, []}},
  ]
