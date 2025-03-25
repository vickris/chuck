defmodule Chuck.JokeServer do
  use GenServer
  require Logger

  def start_link(name) do
    name = String.to_atom(name)
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl GenServer
  def init(_init_arg) do
    {:ok,
     %{
       "all_jokes" => [],
       "favorite_jokes" => [],
       "shared_with_me" => []
     }}
  end

  def get_random_joke(pid) do
    GenServer.call(pid, :get_random_joke)
  end

  def share_joke(pid, joke_id, other_user) do
    GenServer.cast(pid, {:share_joke, joke_id, other_user})
  end

  def favorite_joke(pid, joke_id) do
    GenServer.cast(pid, {:favorite_joke, joke_id})
  end

  def favorite_jokes(pid) do
    GenServer.call(pid, :favorite_jokes)
  end

  def all_jokes(pid) do
    GenServer.call(pid, :all_jokes)
  end

  @impl GenServer
  def handle_cast({:share_joke, joke_id, other_user}, state) do
    case joke_by_id(state["all_jokes"], joke_id) do
      nil ->
        {:noreply, state}

      joke ->
        GenServer.cast(other_user, {:receive_joke, joke})
        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_cast({:receive_joke, joke}, state) do
    state = %{state | "shared_with_me" => [joke | state["shared_with_me"]]}
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:favorite_joke, id}, state) do
    case joke_by_id(state["all_jokes"], id) do
      nil ->
        Logger.log(:error, "Could not find joke with id #{id}")
        {:noreply, state}

      joke ->
        state = %{state | "favorite_jokes" => [joke | state["favorite_jokes"]]}
        {:noreply, joke, state}
    end
  end

  @impl GenServer
  def handle_call(:get_random_joke, _from, state) do
    case Chuck.ChuckService.get_joke() do
      {:ok, body} ->
        joke = body["value"]
        state = %{state | "all_jokes" => [body | state["all_jokes"]]}

        {:reply, joke, state}

      {:error, reason} ->
        Logger.log(:error, "Encountered error retrieving joke: #{inspect(reason)}")
        {:reply, "Encountered error retrieving joke", state}

      other_error ->
        Logger.log(:error, "Other error: #{inspect(other_error)}")
        {:reply, "Encountered error retrieving joke", state}
    end
  end

  @impl GenServer
  def handle_call(:all_jokes, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:favorite_jokes, _from, state) do
    {:reply, state["favorite_jokes"], state}
  end

  defp joke_by_id(jokes, id) do
    Enum.find(jokes, fn %{"id" => joke_id} ->
      joke_id == "#{id}"
    end)
  end
end
