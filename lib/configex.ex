defmodule Configex do
  @moduledoc """
  Configex helps you to deal with Elixir configuration.
  """

  def get_env(app, key, default \\ {:no_default}) do
    value = Application.get_env(app, key)
    process_config(app, key, value, default)
  end

  defp process_config(app, key, {:system, env, default}, _default),
    do: process_config(app, key, {:system, env}, default)

  defp process_config(_app, _key, {:system, env}, {:no_default}),
    do: System.get_env(env) || raise(ArgumentError, "Missing ENV variable: '#{env}'")

  defp process_config(_app, _key, {:system, env}, default), do: System.get_env(env) || default
  defp process_config(app, key, nil, default), do: validate_config(app, key, default)
  defp process_config(_app, _key, value, _default), do: value

  defp validate_config(app, key, default) do
    found =
      app
      |> Application.get_all_env()
      |> Keyword.keys()
      |> Enum.any?(&(&1 == key))

    case {found, default} do
      {false, {:no_default}} ->
        raise(ArgumentError, "Missing configuration for: 'config :#{app}, #{key}: <value>'")

      {false, default} ->
        default

      {true, _default} ->
        nil
    end
  end
end
