defmodule Dictio.Database do
  def child_spec(_) do
    folder = Application.fetch_env!(:dictio, :folder)

    db_folder = "#{folder}/"

    File.mkdir_p!(db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Dictio.DatabaseWorker,
        size: Application.fetch_env!(:dictio, :pool_size)
      ],
      [db_folder]
    )
  end

  def store(data) do
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [data],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  def store_local(data) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      Dictio.DatabaseWorker.store(worker_pid, data)
    end)
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid -> Dictio.DatabaseWorker.get(worker_pid, key) end)
  end

  def get_today_word() do
    :poolboy.transaction(__MODULE__, fn worker_pid -> Dictio.DatabaseWorker.get(worker_pid) end)
  end

  def store_word_of_the_day() do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      Dictio.DatabaseWorker.store(worker_pid, get_today_word())
    end)
  end
end
