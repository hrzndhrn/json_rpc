defmodule HttpClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_client,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:json_rpc, path: "../.."},
      {:httpoison, "~> 1.8"},
      # dev and test
      {:prove, "~> 0.1", only: [:dev, :test]}
    ]
  end
end
