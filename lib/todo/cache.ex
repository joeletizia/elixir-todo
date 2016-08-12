defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting Todo.Cache"
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def server_process(list_name) do
    case Todo.ProcessRegistry.whereis_name({:todo_server, list_name}) do
      :undefined -> GenServer.call(:todo_cache, {:server_process, list_name})
      pid -> pid
    end
  end

  # Callbacks

  def init(_) do
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
    {:ok, server} = Todo.ServerSupervisor.start_child(list_name)
    server
  end
end
