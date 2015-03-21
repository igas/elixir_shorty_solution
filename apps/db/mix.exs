defmodule Db.Mixfile do
  use Mix.Project

  def project do
    [app: :db,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Db, []}]
  end

  def deps do
    [{:postgrex, "~> 0.6"},
     {:poolboy, "~> 1.4.0"},
     {:base62, "~> 1.1.0"},
     {:faker, "~> 0.5.0", only: :test}]
  end
end
