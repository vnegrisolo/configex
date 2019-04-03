defmodule Configex.Configuration do
  @moduledoc false

  alias Configex.ConfigError

  @no_default :configex_no_default

  @type app :: atom
  @type key :: atom
  @type default :: any
  @type is_compiled :: (() -> boolean)
  @type result :: any
  @type tuple_result :: {:ok, result} | {:error, reason}
  @type reason :: String.t()

  @spec get_config(is_compiled, app, key, default) :: tuple_result
  def get_config(is_compiled, app, key, default \\ @no_default)
      when is_atom(app) and is_atom(key) and is_function(is_compiled, 0) do
    app
    |> Application.get_env(key, default)
    |> parse_value(app, key, default, is_compiled)
  end

  @spec get_config!(is_compiled, app, key, default) :: result
  def get_config!(is_compiled, app, key, default \\ @no_default)
      when is_atom(app) and is_atom(key) and is_function(is_compiled, 0) do
    case get_config(is_compiled, app, key, default) do
      {:ok, result} -> result
      {:error, reason} -> raise(ConfigError, reason)
    end
  end

  defp parse_value({:system, env, default}, app, key, _default, is_compiled) do
    parse_value({:system, env}, app, key, default, is_compiled)
  end

  defp parse_value({:system, env}, _app, _key, default, is_compiled) do
    case {is_compiled.(), System.get_env(env), default} do
      {false, _value, _default} -> env_compilation_error(env)
      {true, nil, @no_default} -> missing_env_var_error(env)
      {true, nil, default} -> {:ok, default}
      {true, value, _default} -> {:ok, value}
    end
  end

  defp parse_value(@no_default, app, key, _default, _is_compiled) do
    missing_config_error(app, key)
  end

  defp parse_value(list, app, key, default, is_compiled) when is_list(list) do
    parse_recursive_enum(list, app, key, default, is_compiled)
  end

  defp parse_value(map, app, key, default, is_compiled) when is_map(map) do
    case parse_recursive_enum(map, app, key, default, is_compiled) do
      {:ok, list} when is_list(list) -> {:ok, Enum.into(list, %{})}
      error -> error
    end
  end

  defp parse_value(value, _app, _key, _default, _is_compiled) do
    {:ok, value}
  end

  defp parse_recursive_enum(enum, app, key, default, is_compiled) do
    Enum.reduce_while(enum, {:ok, []}, fn {k, v}, {:ok, list} ->
      case parse_value(v, app, key, default, is_compiled) do
        {:ok, new_value} -> {:cont, {:ok, [{k, new_value} | list]}}
        error -> {:halt, error}
      end
    end)
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
