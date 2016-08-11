defmodule Todo.ProcessRegistry do
  use GenServer
  import Kernel, except: [send: 2]

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> 
        {:badarg, {key, message}}
      pid -> 
        Kernel.send(pid, message)
        pid
    end
  end

  def whereis_name(key) do
    GenServer.call(:process_registry, {:whereis_name, key})
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:register_name, key, pid}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        #process has not been registered, register it
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}
      _ ->
        #process has already been registered
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _, process_registry) do
    {:reply, Map.get(process_registry, key, :undefined), process_registry}
  end

  def handle_call({:unregister_name, key}, _, process_registry) do
    pid = whereis_name(key)
    {:reply, :ok, deregister_pid(process_registry, pid)}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  defp deregister_pid(registry, pid) do
    Enum.filter(registry, fn({_, value}) -> value == pid end)
    |> Enum.reduce(registry, fn({registry_name, _}, acc) -> Map.delete(acc, registry_name) end)
  end
end
