defmodule WsClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :ws_client,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {WsClient.Application, []}
    ]
  end

  defp deps do
    [
      {:elixir_uuid, "~> 1.6", hex: :uuid_utils},
      {:jason, "~> 1.2"},
      {:json_rpc, path: "../.."},
      {:websockex, "~> 0.4.2"},
      # dev and test
      {:prove, "~> 0.1", only: [:dev, :test]}
    ]
  end
end
