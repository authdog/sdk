defmodule Authdog.MixProject do
  use Mix.Project

  def project do
    [
      app: :authdog,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.4.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:castore, "~> 1.0", only: :test}
    ]
  end

  defp description do
    "Official Elixir SDK for Authdog authentication and user management platform"
  end

  defp package do
    [
      name: "authdog",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/authdog/sdk"}
    ]
  end

  defp docs do
    [
      main: "Authdog",
      extras: ["README.md"]
    ]
  end
end
