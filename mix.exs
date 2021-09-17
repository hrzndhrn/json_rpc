defmodule JsonRPC.MixProject do
  use Mix.Project

  @github "https://github.com/hrzndhrn/json_rpc"

  def project do
    [
      app: :json_rpc,
      version: "0.1.0",
      elixir: "~> 1.11",
      name: "JsonRPC",
      description: "A JSON-RPC 2.0 library.",
      source_url: @github,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: preferred_cli_env(),
      dialyzer: dialyzer(),
      aliases: aliases(),
      docs: docs(),
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {JsonRPC.Application, []},
      env: [parser: Jason]
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  def preferred_cli_env do
    [
      carp: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "test/support/plts/dialyzer.plt"},
      plt_add_apps: [:jason, :poison, :elixir_uuid],
      flags: [:unmatched_returns]
    ]
  end

  defp docs do
    [
      groups_for_modules: [
        Behaviours: [
          JsonRPC.ID,
          JsonRPC.Parser,
          JsonRPC.Transport
        ],
        "ID Implementations": [
          JsonRPC.UID,
          JsonRPC.UUID
        ]
      ]
    ]
  end

  def package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end

  defp aliases do
    [
      carp: ["test --seed 0 --max-failures 1"]
    ]
  end

  defp deps do
    [
      {:elixir_uuid, "~> 1.6", hex: :uuid_utils, optional: true},
      {:jason, "~> 1.2", optional: true},
      {:poison, "~> 5.0", optional: true},
      {:xema, "~> 0.14"},
      # dev and test
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
