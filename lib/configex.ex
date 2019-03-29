defmodule Configex do
  @moduledoc """
  Configex helps you to deal with Elixir configuration.
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

  defmacro get_config(app, key) when is_atom(app) and is_atom(key) do
    quote do
      Configex.get_config(unquote(app), unquote(key), :no_default)
    end
  end

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

  defmacro get_config!(app, key) when is_atom(app) and is_atom(key) do
    quote do
      Configex.get_config!(unquote(app), unquote(key), :no_default)
    end
  end

  defmacro get_config!(app, key, default) when is_atom(app) and is_atom(key) do
    quote do
      case Configex.get_config(unquote(app), unquote(key), unquote(default)) do
        {:ok, result} -> result
        {:error, reason} -> raise(ConfigError, reason)
      end
    end
  end

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

  def missing_config_error(app, key) do
    {:error, "Missing configuration: 'config :#{app}, #{key}: <value>'"}
  end

  def missing_env_var_error(env) do
    {:error, "Missing ENV variable: '#{env}'"}
  end

  def env_compilation_error(env) do
    {:error, "ENV must not be used on compilation time: '#{env}'"}
  end
end
