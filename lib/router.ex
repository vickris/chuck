defmodule Chuck.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/:name" do
    case Chuck.UserManagementServer.get_or_create_user(name) do
      {:ok, _pid} ->
        send_resp(conn, 200, "User with name #{name} created successfully")

      {:error, :could_not_start_joke_server} ->
        send_resp(conn, 500, "Could not start joke server")

      _pid ->
        send_resp(conn, 200, "User with name #{name} already exists")
    end
  end

  get "/hello/:name" do
    send_resp(conn, 200, "Hello, #{name}!")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
