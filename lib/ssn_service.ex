defmodule SsnService do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(SsnService.Repo, []),
      # Start the endpoint when the application starts
      supervisor(SsnService.Endpoint, []),
      # Start your own worker by calling: SsnService.Worker.start_link(arg1, arg2, arg3)
      # worker(SsnService.Worker, [arg1, arg2, arg3]),
    ]

    :ets.new(:users, [:ordered_set, :named_table, :public])
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SsnService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SsnService.Endpoint.config_change(changed, removed)
    :ok
  end
end
