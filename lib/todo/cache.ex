defmodule Todo.Cache do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, list_name) do
    GenServer.call(cache_pid, {:server_process, list_name})
  end

  # Callbacks

  def init(_) do
    Todo.Database.start("./persist/")
    {:ok, %{}}
  end

  def handle_call({:server_process, list_name}, _caller, server_state_map) do
    case Map.fetch(server_state_map, list_name) do
      {:ok, server_process} -> 
        {:reply, server_process, server_state_map}
      :error ->
        server = start_server(list_name)
        {:reply, server, Map.put(server_state_map, list_name, server)}
    end
  end

  defp start_server(list_name) do
    {:ok, server} = Todo.Server.start(list_name)
    server
  end
end
