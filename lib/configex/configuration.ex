defmodule Configex.Configuration do
  @moduledoc false

  alias Configex.ConfigError

  @no_default :no_default

  @type app :: atom
  @type key :: atom
  @type default :: any
  @type is_compiled :: (() -> boolean)
  @type result :: any
  @type tuple_result :: {:ok, result} | {:error, reason}
  @type reason :: String.t()

  @spec get_config(is_compiled, app, key, default) :: tuple_result
  def get_config(is_compiled, app, key, default \\ @no_default)
      when is_atom(app) and is_atom(key) and is_function(is_compiled) do
    case Application.get_env(app, key, default) do
      {:system, env, default} -> get_system_env(env, default, is_compiled)
      {:system, env} -> get_system_env(env, default, is_compiled)
      @no_default -> missing_config_error(app, key)
      value -> {:ok, value}
    end
  end

  @spec get_config!(is_compiled, app, key, default) :: result
  def get_config!(is_compiled, app, key, default \\ @no_default)
      when is_atom(app) and is_atom(key) and is_function(is_compiled) do
    case get_config(is_compiled, app, key, default) do
      {:ok, result} -> result
      {:error, reason} -> raise(ConfigError, reason)
    end
  end

  defp get_system_env(env, default, is_compiled) do
    case {is_compiled.(), System.get_env(env), default} do
      {false, _value, _default} -> env_compilation_error(env)
      {true, nil, @no_default} -> missing_env_var_error(env)
      {true, nil, default} -> {:ok, default}
      {true, value, _default} -> {:ok, value}
    end
  end

  defp missing_config_error(app, key) do
    {:error, "Missing configuration: 'config :#{app}, #{key}: <value>'"}
  end

  defp missing_env_var_error(env) do
    {:error, "Missing ENV variable: '#{env}'"}
  end

  defp env_compilation_error(env) do
    {:error, "ENV must not be used on compilation time: '#{env}'"}
  end
end
