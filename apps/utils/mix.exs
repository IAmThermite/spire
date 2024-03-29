defmodule Spire.Utils.MixProject do
  use Mix.Project

  def project do
    [
      app: :utils,
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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6.2"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_sqs, "~> 3.1.0"},
      {:configparser_ex, "~> 4.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:jason, "~> 1.0"},
      {:spire_logger, in_umbrella: true}
    ]
  end
end
