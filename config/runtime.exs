import Config

env! = fn name -> System.get_env(name) || raise "Env var '#{name}' not defined." end

config :dictio,
  api_key: env!.("NOTION_API_KEY"),
  word_database: env!.("NOTION_DATABASE_ID")
