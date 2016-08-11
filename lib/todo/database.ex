defmodule Todo.Database do
  use GenServer

  @number_of_workers 40

  def start(db_folder) do
    IO.puts "Starting Todo.Database"
    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    choose_worker(key)
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    choose_worker(key)
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end

  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end

  def handle_call({:choose_worker, key}, _, workers) do
    index = :erlang.phash2(key, @number_of_workers)
    {:reply, Map.get(workers, index), workers}
  end

  defp start_workers(db_folder) do
    for index <- 0..(@number_of_workers - 1), into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
      {index, pid}
    end
  end
end
