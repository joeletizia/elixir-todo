defmodule Todo.Server do
  use GenServer

  def start_link(list_name) do
    IO.puts "### Starting Todo.Server for #{list_name} ###"
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  def init(list_name) do
    list = Todo.Database.get(list_name) || Todo.List.new
    {:ok, {list_name, list}}
  end

  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(list_name, new_state)
    {:noreply, {list_name, new_state}}
  end

  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    { :reply, Todo.List.entries(todo_list, date), {list_name, todo_list} }
  end
end
