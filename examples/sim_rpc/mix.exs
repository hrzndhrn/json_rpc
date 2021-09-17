defmodule SimRPC.MixProject do
  use Mix.Project

  def project do
    [
      app: :sim_rpc,
      version: "0.1.0",
      elixir: "~> 1.11",
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
      # dev and test
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:prove, "~> 0.1", only: [:dev, :test]}
    ]
  end
end
