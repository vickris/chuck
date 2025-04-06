defmodule Chuck.Application do
  use Application

  def start(_type, _args) do
    children = [
      Chuck.UserManagementServer,
      {Plug.Cowboy, scheme: :http, plug: ChuckWeb.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: Chuck.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
