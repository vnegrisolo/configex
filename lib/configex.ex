defmodule Configex do
  @moduledoc """
  Configex helps you to deal with Elixir configuration.
  """

  def get_env!(app, key, default \\ {:no_default}) do
    case get_env(app, key, default) do
      {:ok, result} -> result
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  def get_env(app, key, default \\ {:no_default}) do
    case Application.get_env(app, key) do
      {:system, env, default} -> get_system_env(env, default)
      {:system, env} -> get_system_env(env, default)
      nil -> get_application_env(app, key, default)
      value -> {:ok, value}
    end
  end

  defp get_system_env(env, default) do
    case {System.get_env(env), default} do
      {nil, {:no_default}} -> {:error, "Missing ENV variable: '#{env}'"}
      {nil, default} -> {:ok, default}
      {value, _default} -> {:ok, value}
    end
  end

  defp get_application_env(app, key, default) do
    found =
      app
      |> Application.get_all_env()
      |> Keyword.keys()
      |> Enum.any?(&(&1 == key))

    case {found, default} do
      {false, {:no_default}} ->
        {:error, "Missing configuration: 'config :#{app}, #{key}: <value>'"}

      {false, default} ->
        {:ok, default}

      {true, _default} ->
        {:ok, Application.get_env(app, key)}
    end
  end
end
