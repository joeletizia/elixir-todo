defmodule Todo.Server do
  use GenServer

  def start(list_name) do
    GenServer.start(__MODULE__, list_name)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def init(list_name) do
    list = Todo.Database.get(list_name) || Todo.List.new
    {:ok, {list_name, list}}
  end

  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    IO.puts "### Storing #{list_name} ###"
    Todo.Database.store(list_name, new_state)
    {:noreply, {list_name, new_state}}
  end

  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    { :reply, Todo.List.entries(todo_list, date), {list_name, todo_list} }
  end
end