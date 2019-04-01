defmodule Configex.MixProject do
  use Mix.Project

  def project do
    [
      app: :configex,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [main: "readme", extras: ~w(README.md)],
      source_url: "https://github.com/vnegrisolo/configex",
      package: package(),
      name: "Configex"
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
      {:credo, "~> 1.0", only: :test},
      {:dialyxir, "~> 0.5.1", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package() do
    [
      description: """
      `Configex` helps you to deal with Elixir configuration.
      """,
      licenses: ~w(MIT),
      maintainers: ["Vinicius Ferreira Negrisolo"],
      links: %{
        github: "https://github.com/vnegrisolo/configex"
      }
    ]
  end
end
