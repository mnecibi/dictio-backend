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
    {:ok, %Dictio.Notion.ListResponse{:results => [result] }} = fetch_word_with_date_filter()
    word =
      result
      |> Dictio.Notion.Word.build()

    {:reply, word, db_folder}
  end


  def build_filters() do
    %{
      "filter" => %{
          "property"=> "date",
          "date"=> %{
              "equals" => Date.to_string(Date.utc_today)
          }
      }
    }
  end

  def fetch_word_with_date_filter() do
    Dictio.Notion.Api.post_all("/databases/" <> Application.get_env(:dictio, :word_database) <> "/query", build_filters(), [])
  end

  defp file_name(db_folder) do
    Path.join(db_folder, Application.get_env(:dictio, :file_name))
  end
end
