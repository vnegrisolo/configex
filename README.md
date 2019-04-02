# Configex

[![CircleCI](https://circleci.com/gh/vnegrisolo/configex.svg?style=svg)](https://circleci.com/gh/vnegrisolo/configex)

`Configex` helps you to deal with Elixir configuration.

Here are the **reasons** why I have created this library:

Elixir is a **compiled** language and getting environment variables on compilation time is **wrong in most of times**.

On compiled language projects there's usually a CI machine(s) that compiles the code and package it. The compiled code package is usually deployed to another machine(s) to run. Very frequently CI and production machines are even on different networks. Ideally CI machines should not know ENV vars like production secrets, etc.

In addition to that if an ENV var has to change, let's say that you have a new secret due to a new service provision then you **cannot
just restart** the app, but you'll have to run CI again to **re-compile** and **re-deploy** the same code base, but with the new ENV var. This is not desirable at all in terms of maintainability of the app you are building.

## How to use `Configex`

The easiest way to use `Configex` is by calling `get_config!/2`:

```elixir
defmodule MyModule do
  use Configex

  def my_config(), do: get_config!(:my_app, :my_config)
end
```

Cool, so far `Configex.get_config!/2` will do the same work as `Application.get_env/2`. The same for `Configex.get_config!/3` will do the same work as `Application.get_env/3`.

Now let's see how `Configex` can benefit us.

## The benefits of using `Configex`:

1.  💥  It raises an error if a configuration is missing and if no `default` is provided.

2.  ⚙️  You can configure ENV vars like `config :my_app, my_config: {:system, "MY_ENV"}`

3.  ⚙️  You can configure ENV vars with a default value like `config :my_app, my_config: {:system, "MY_ENV", "<some default>"}`

4.  💥  It raises an error if an ENV var is missing and if no `default` is provided.

5.  💥  It raises an error if an ENV var is used **on compilation time**.

## Configuration Example:

```elixir
use Mix.Config

config :my_app,
  harcoded_1: nil,
  harcoded_2: "Some harcoded value",
  env_1: {:system, "ENV_1"},
  env_2: {:system, "ENV_2", "some system default"}
```

## Usage Example:

```elixir
  defmodule MyApp.MyModule do
    use Configex

    # ✅  this is a valid assignment as this is a hardcoded configuration
    @harcoded_1 get_config!(:my_app, :harcoded_1)

    # 💥  this raises an error as this config is an ENV var and
    # ENV vars are not suppose to be used on compilation time
    @env_1 get_config!(:my_app, :env_1)

    def harcoded_1(), do: @harcoded_1
    def harcoded_2(), do: get_config!(:my_app, :harcoded_2)
    def env_1(), do: @env_1
    def env_2(), do: get_config!(:my_app, :env_2)
  end
```

## Installation

Check out `configex` dependency version on [hex.pm/configex][hex-pm-configex]. The package can be installed by adding `configex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:configex, "~> 0.1.0"}
  ]
end
```

## Documentation

The `Configex` documentation is hosted on [hexdocs/configex][hexdocs-configex].

## Development

Check out the `Makefile` for useful development tasks.

<!-- Links & Images -->
[hex-pm-configex]: https://hex.pm/packages/configex 'Configex on Hex'
[hexdocs-configex]: https://hexdocs.pm/configex/ 'Configex on HexDocs'
