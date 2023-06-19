defmodule Delta.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Delta.Router, options: [port: 8081]}
      # Starts a worker by calling: Delta.Worker.start_link(arg)
      # {Delta.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Delta.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
