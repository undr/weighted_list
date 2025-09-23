defmodule WeightedList.MixProject do
  use Mix.Project

  # git ls-files
  @files ~w[
    .formatter.exs
    .gitignore
    .tool-versions
    Cargo.lock
    Cargo.toml
    README.md
    lib/weighted_list.ex
    lib/weighted_list/native.ex
    mix.exs
    mix.lock
    native/weighted_list/Cargo.toml
    native/weighted_list/README.md
    native/weighted_list/src/lib.rs
    native/weighted_list/src/table.rs
    test/test_helper.exs
    test/weighted_list_test.exs
  ]

  def project do
    [
      app: :weighted_list,
      version: "0.1.2",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp package do
    [
      files: @files,
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
end
