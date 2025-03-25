defmodule Chuck.UserManagementServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  def get_or_create_user(name) do
    GenServer.call(__MODULE__, {:get_or_create_user, name})
  end

  def all_users() do
    GenServer.call(__MODULE__, :users)
  end

  def handle_call(:users, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:get_or_create_user, name}, _from, state) do
    case Map.get(state, name) do
      nil ->
        case Chuck.JokeServer.start_link(name) do
          {:ok, pid} ->
            state = Map.put(state, name, pid)
            {:reply, {:ok, pid}, state}

          {:error, _} ->
            {:reply, {:error, :could_not_start_joke_server}, state}
        end

      pid ->
        {:reply, pid, state}
    end
  end
end
