defmodule ChuckWeb.ActionController do
  alias Chuck.UserManagementServer
  alias Chuck.JokeServer

  def create(conn, %{"username" => username}) do
    case UserManagementServer.get_or_create_user(username) do
      {:ok, _pid} ->
        json_response(conn, 200, %{message: "User #{username} created successfully"})

      {:error, :could_not_start_joke_server} ->
        json_response(conn, 500, "Could not start joke server")

      _pid ->
        json_response(conn, 200, %{message: "User already exists"})
    end
  end

  def random_joke(conn, %{"username" => name}) do
    pid = String.to_atom(name)
    joke = JokeServer.get_random_joke(pid)
    json_response(conn, 200, %{joke: joke})
  end

  def all_jokes(conn, %{"username" => username}) do
    pid = String.to_atom(username)
    jokes = JokeServer.all_jokes(pid)
    json_response(conn, 200, %{jokes: jokes})
  end

  def favorite_joke(conn, %{"username" => name, "joke_id" => joke_id}) do
    pid = String.to_atom(name)
    :ok = JokeServer.favorite_joke(pid, joke_id)
    json_response(conn, 200, %{message: "Added joke #{joke_id} to favorites"})
  end

  def favorite_jokes(conn, %{"username" => username}) do
    pid = String.to_atom(username)
    jokes = JokeServer.favorite_jokes(pid)
    json_response(conn, 200, %{favorites: jokes})
  end

  def share_joke(conn, %{"origin" => name, "joke_id" => joke_id, "destination" => other_user}) do
    from_pid = String.to_atom(name)
    destination_pid = String.to_atom(other_user)
    JokeServer.share_joke(from_pid, joke_id, destination_pid)
    json_response(conn, 200, %{message: "Shared joke #{joke_id} with #{other_user}"})
  end

  # Helper to send JSON responses
  defp json_response(conn, status, data) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(data))
  end
end
