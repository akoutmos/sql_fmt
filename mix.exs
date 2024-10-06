defmodule SqlFmt.MixProject do
  use Mix.Project

  def project do
    [
      app: :sql_fmt,
      name: "SqlFmt",
      version: project_version(),
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/akoutmos/sql_fmt",
      homepage_url: "https://hex.pm/packages/sql_fmt",
      description: "Pretty print SQL queries",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.github": :test
      ],
      dialyzer: [
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      package: package(),
      deps: deps(),
      docs: docs(),
      aliases: aliases()
    ]
  end

  defp project_version do
    "VERSION"
    |> File.read!()
    |> String.trim()
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Production deps
      {:rustler_precompiled, "~> 0.4"},
      {:rustler, ">= 0.0.0", optional: true},

      # Dev deps
      {:doctor, "~> 0.21", only: :dev},
      {:ex_doc, "~> 0.34", only: :dev},
      {:credo, "~> 1.7", only: :dev},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},

      # Test deps
      {:excoveralls, "~> 0.18", only: :test, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "master",
      logo: "guides/images/logo.png",
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      name: "sql_fmt",
      files:
        ~w(lib mix.exs README.md LICENSE CHANGELOG.md native/sql_fmt_nif/.cargo native/sql_fmt_nif/src native/sql_fmt_nif/Cargo.* VERSION checksum-*.exs),
      licenses: ["MIT"],
      maintainers: ["Alex Koutmos"],
      links: %{
        "GitHub" => "https://github.com/akoutmos/sql_fmt",
        "Sponsor" => "https://github.com/sponsors/akoutmos"
      }
    ]
  end

  defp aliases do
    [
      docs: ["docs", &copy_files/1]
    ]
  end

  defp copy_files(_) do
    # Set up directory structure
    File.mkdir_p!("./doc/guides/images")

    # Copy over image files
    "./guides/images/"
    |> File.ls!()
    |> Enum.each(fn image_file ->
      File.cp!("./guides/images/#{image_file}", "./doc/guides/images/#{image_file}")
    end)
  end
end
