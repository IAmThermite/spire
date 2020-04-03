defmodule Spire.UploadCompiler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.info("Starting Upload Compiler")

    children = [
      {Spire.UploadCompiler, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spire.UploadCompiler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
