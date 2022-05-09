defmodule Dictio.MixProject do
  use Mix.Project

  def project do
    [
      app: :dictio,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        dictio: [
          include_executables_for: [:unix],
          include_erts: true,
          strip_beams: true,
          quiet: false
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Dictio.Application, []}
    ]
  end

  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:quantum, "~> 3.0"},
      {:jason, "~> 1.3"},
      {:tesla, "~> 1.4"},
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4"},
      {:distillery, "~> 2.0"},
      {:tzdata, "~> 1.1.1"},
    ]
  end
end
