defmodule Todo.Database do
  @number_of_workers 40

  def start_link(db_folder) do
    IO.puts "Starting Todo.Database"
    Todo.PoolSupervisor.start_link(db_folder, @number_of_workers)
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
    :erlang.phash2(key, @number_of_workers)
  end
end
