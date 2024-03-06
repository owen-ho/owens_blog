defmodule OwensBlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OwensBlogWeb.Telemetry,
      OwensBlog.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:owens_blog, :ecto_repos),
       skip: System.get_env("SKIP_MIGRATIONS") == "true"},
      {DNSCluster, query: Application.get_env(:owens_blog, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OwensBlog.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: OwensBlog.Finch},
      # Store IPs to be throttled to prevent ddos
      {PlugAttack.Storage.Ets, name: OwensBlog.PlugAttack.Storage, clean_period: 60_000},
      # Start a worker by calling: OwensBlog.Worker.start_link(arg)
      # {OwensBlog.Worker, arg},
      OwensBlogWeb.Presence,
      # Start to serve requests, typically the last entry
      OwensBlogWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OwensBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OwensBlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
