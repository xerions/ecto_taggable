defmodule EctoTaggable.Mixfile do
  use Mix.Project

  def project do
    [app: :ecto_taggable,
     elixir: ">= 1.0.5",
     version: "0.0.1",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:postgrex, ">= 0.0.0", optional: true},
     {:mariaex, ">= 0.0.0", optional: true},
     {:ecto, "~> 1.0.0"},
     {:ecto_migrate, "~> 0.6.2"},
     {:ecto_it, "~> 0.2.0", optional: true}]
  end
end
