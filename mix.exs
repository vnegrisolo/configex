defmodule Configex.MixProject do
  use Mix.Project

  @app :configex
  @name "Configex"

  def project do
    [
      app: @app,
      deps: deps(),
      docs: [
        main: "readme",
        extras: ~w(README.md)
      ],
      elixir: "~> 1.7",
      name: @name,
      package: package(),
      source_url: "https://github.com/vnegrisolo/#{@app}",
      start_permanent: Mix.env() == :prod,
      version: "0.1.3"
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:credo, "~> 1.3.1", only: :test},
      {:dialyxir, "~> 1.0.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package() do
    [
      description: """
      `#{@name}` helps you to deal with Elixir configuration.
      """,
      licenses: ~w(MIT),
      links: %{
        github: "https://github.com/vnegrisolo/#{@app}"
      },
      maintainers: ["Vinicius Ferreira Negrisolo"]
    ]
  end
end
