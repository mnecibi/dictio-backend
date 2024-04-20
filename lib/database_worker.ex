defmodule Dictio.DatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(pid, data) do
    GenServer.call(pid, {:store, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_call({:store, data}, _, db_folder) do
    db_folder
    |> file_name
    |> File.write!(Jason.encode!(data))

    {:reply, :ok, db_folder}
  end

  def handle_call(:get, _, db_folder) do
    with word_of_the_day_response <- fetch_word_of_the_day() do
      case word_of_the_day_response do
        {:ok, word} ->
          {:reply, word, db_folder}

        {:error, _error} ->
          {:reply, fetch_new_word(), db_folder}
      end
    end
  end

  def fetch_word_of_the_day() do
    with {:ok, %Dictio.Notion.ListResponse{:results => results}} <-
           fetch_word_with_today_date_filter() do
      case results do
        [result] -> {:ok, Dictio.Notion.Word.build(result)}
        [result | _tail] -> {:ok, Dictio.Notion.Word.build(result)}
        _ -> {:error, "No word of the day found"}
      end
    end
  end

  def fetch_new_word() do
    with {:ok, %Dictio.Notion.ListResponse{:results => results}} <-
           fetch_word_with_empty_date_filter() do
      results
      |> Enum.random()
      |> Dictio.Notion.Word.build()
      |> update_word_of_the_day
    end
  end

  def empty_date_filters() do
    %{
      "filter" => %{
        "and" => [
          %{
            "property" => "state",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "definition1",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "wikitionnaire",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "word",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "date",
            "date" => %{
              "is_empty" => true
            }
          }
        ]
      }
    }
  end

  def today_date_request_body() do
    %{
      "properties" => %{
        "date" => %{
          "id" => "AN`<",
          "type" => "date",
          "date" => %{
            "start" => Calendar.strftime(DateTime.now!("Europe/Paris"), "%Y-%m-%d")
          }
        }
      }
    }
  end

  def today_date_filters() do
    %{
      "filter" => %{
        "and" => [
          %{
            "property" => "state",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "definition1",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "wikitionnaire",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "word",
            "rich_text" => %{
              "is_not_empty" => true
            }
          },
          %{
            "property" => "date",
            "date" => %{
              "equals" => Date.to_string(Date.utc_today())
            }
          }
        ]
      }
    }
  end

  def fetch_word_with_today_date_filter() do
    Dictio.Notion.Api.post_all(
      "/databases/" <> Application.get_env(:dictio, :word_database) <> "/query",
      today_date_filters(),
      []
    )
  end

  def fetch_word_with_empty_date_filter() do
    Dictio.Notion.Api.post_all(
      "/databases/" <> Application.get_env(:dictio, :word_database) <> "/query",
      empty_date_filters(),
      []
    )
  end

  def update_word_of_the_day(word) do
    with {:ok, %Dictio.Notion.Response{:body => body}} <-
           Dictio.Notion.Api.patch("/pages/" <> word["id"], today_date_request_body(), []) do
      body
      |> Dictio.Notion.Word.build()
    end
  end

  defp file_name(db_folder) do
    Path.join(db_folder, Application.get_env(:dictio, :file_name))
  end
end
