defmodule Spire.UploadCompiler.MixProject do
  use Mix.Project

  def project do
    [
      app: :upload_compiler,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Spire.UploadCompiler.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
      {:spire_db, in_umbrella: true},
      {:jason, "~> 1.0"},
      {:broadway_sqs, "~> 0.6.0"},
      {:httpoison, "~> 1.6.2"}
    ]
  end
end
