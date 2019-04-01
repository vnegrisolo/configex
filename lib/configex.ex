defmodule Configex do
  @moduledoc """
  `Configex` helps you to deal with Elixir configuration.

  Here is the **reason** why I have created this library:

  Elixir is a compiled language and getting environment variables on compilation time is wrong in most of times.
  On compiled language projects there's usually a CI machine(s) that compiles the code and package it.
  The compiled code package is usually deployed to another machine(s) to run.
  Very frequently CI and production machines are even on different networks.
  Ideally CI machines should not know ENV vars like production secrets, etc.
  In addition to that if an ENV var has to change, let's say to have a new secret due to a new service provision then you cannot
  just restart the app, but you'll have to run CI again to **re-compile** and **re-deploy** the same code base, but with a new ENV var.
  This is not desirable at all in terms of maintainability of the app you are building.

  ## How to use `Configex`

  The easiest way to use `Configex` is by calling `get_config!/2`:

  ```elixir
  defmodule MyModule do
    use Configex

    def my_config(), do: get_config!(:my_app, :my_config)
  end
  ```

  Cool, so far `Configex.get_config!/2` will do the same work as `Application.get_env/2`. The same for `Configex.get_config!/3` will do the same work as `Application.get_env/3`.

  Now let's see what `Configex` brings to us.

  ## The benefits of using `Configex`:

  1. It raises an error if a configuration is missing if no `default` is provided.

  2. You can configure ENV vars like `config :my_app, my_config: {:system, "MY_ENV"}`

  3. You can configure ENV vars with a default value like `config :my_app, my_config: {:system, "MY_ENV", "<some default>"}`

  4. It raises an error if an ENV var is missing if no `default` is provided.

  5. It raises an error if an ENV var is used **on compilation time**.

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
    defmodule MyApp.MyModule1 do
      use Configex

      # this is a valid assignment as this is a hardcoded configuration
      @harcoded_1 get_config!(:my_app, :harcoded_1)

      # this raises an error as this config is an ENV var and
      # ENV vars are not suppose to be used on compilation time
      @env_1 get_config!(:my_app, :env_1)

      def harcoded_1(), do: @harcoded_1
      def harcoded_2(), do: get_config!(:my_app, :harcoded_2)
      def env_1(), do: @env_1
      def env_2(), do: get_config!(:my_app, :env_2)
    end
  ```
  """

  defmodule ConfigError do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      import Configex,
        only: [
          get_config: 2,
          get_config: 3,
          get_config!: 2,
          get_config!: 3
        ]
    end
  end

  @doc """
  Gets a config for the application by a key. Returns a {:ok, value} or {:error, message} tuples.
  """
  defmacro get_config(app, key) when is_atom(app) and is_atom(key) do
    quote do
      Configex.get_config(unquote(app), unquote(key), :no_default)
    end
  end

  @doc """
  Gets a config for the application by a key or returns the default. Returns a {:ok, value} or {:error, message} tuples.
  """
  defmacro get_config(app, key, default) when is_atom(app) and is_atom(key) do
    quote do
      case Application.get_env(unquote(app), unquote(key), unquote(default)) do
        {:system, env, default} -> Configex.get_system_env(env, default)
        {:system, env} -> Configex.get_system_env(env, unquote(default))
        :no_default -> Configex.missing_config_error(unquote(app), unquote(key))
        value -> {:ok, value}
      end
    end
  end

  @doc """
  Gets a config for the application by a key. Returns the value or raises an Configex.ConfigError.
  """
  defmacro get_config!(app, key) when is_atom(app) and is_atom(key) do
    quote do
      Configex.get_config!(unquote(app), unquote(key), :no_default)
    end
  end

  @doc """
  Gets a config for the application by a key or returns the default. Returns the value or raises an Configex.ConfigError.
  """
  defmacro get_config!(app, key, default) when is_atom(app) and is_atom(key) do
    quote do
      case Configex.get_config(unquote(app), unquote(key), unquote(default)) do
        {:ok, result} -> result
        {:error, reason} -> raise(ConfigError, reason)
      end
    end
  end

  @doc false
  defmacro get_system_env(env, default) do
    quote do
      unless function_exported?(__MODULE__, :__info__, 1) do
        Configex.env_compilation_error(unquote(env))
      end

      case System.get_env(unquote(env)) do
        nil ->
          case unquote(default) do
            :no_default -> Configex.missing_env_var_error(unquote(env))
            default -> {:ok, default}
          end

        value ->
          {:ok, value}
      end
    end
  end

  @doc false
  def missing_config_error(app, key) do
    {:error, "Missing configuration: 'config :#{app}, #{key}: <value>'"}
  end

  @doc false
  def missing_env_var_error(env) do
    {:error, "Missing ENV variable: '#{env}'"}
  end

  @doc false
  def env_compilation_error(env) do
    {:error, "ENV must not be used on compilation time: '#{env}'"}
  end
end
