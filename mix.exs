defmodule WeightedList.MixProject do
  use Mix.Project

  def project do
    [
      app: :weighted_list,
      version: "0.1.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp package do
    [
      files: files(),
      maintainers: ["Andrei Lepeshkin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/undr/weighted_list"}
    ]
  end

  def description do
    "Implementation of Walker's Alias Method (WAM). " <>
    "It's method for performing weighted random sampling. " <>
    "The core algorithm is written in Rust for speed optimization."
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
      {:rustler, "~> 0.36.2", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp files do
    {out, 0} = System.cmd("git", ["ls-files"])
    String.split(out, "\n", trim: true)
  end
end
