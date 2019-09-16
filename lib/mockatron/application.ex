defmodule Mockatron.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Mockatron.Repo,
      # Start the endpoint when the application starts
      MockatronWeb.Endpoint,
      # Starts a worker by calling: Mockatron.Worker.start_link(arg)
      # {Mockatron.Worker, arg},
      %{
        id: :agent,
        start: {Cachex, :start_link, [:agent, []]}
      },
      %{
        id: :responder,
        start: {Cachex, :start_link, [:responder, []]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mockatron.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MockatronWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
