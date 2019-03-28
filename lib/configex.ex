defmodule Configex do
  @moduledoc """
  Configex helps you to deal with Elixir configuration.
  """

  def get_env(app, key, default \\ nil) do
    case Application.get_env(app, key, default) do
      {:system, varname} -> System.get_env(varname)
      value -> value
    end
  end
end
