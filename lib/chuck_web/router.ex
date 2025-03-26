defmodule ChuckWeb.Router do
  use Plug.Router

  import ChuckWeb.ActionController

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post("/users", do: create(conn, conn.body_params))
  get("/:username/random-joke", do: random_joke(conn, %{"username" => username}))
  get("/:username/all-jokes", do: all_jokes(conn, %{"username" => username}))
  post("/favorites", do: favorite_joke(conn, conn.body_params))
  get("/:username/favorites", do: favorite_jokes(conn, %{"username" => username}))
  post("/share", do: share_joke(conn, conn.body_params))

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
