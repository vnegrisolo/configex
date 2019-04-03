defmodule Configex do
  @moduledoc """
  `Configex` helps you to deal with Elixir configuration.

  See `get_config!/3` for more information.
  """

  alias Configex.Configuration

  defmacro __using__(_opts) do
    quote do
      import Configex,
        only: [
          _compiled?: 0,
          get_config: 2,
          get_config: 3,
          get_config!: 2,
          get_config!: 3
        ]
    end
  end

  @doc """
  Gets a config for the app and key and it returns an :ok tuple like `{:ok, <value>}` or `{:error, "reason"}`

  See `get_config!/3` for more information.
  """
  defmacro get_config(app, key) when is_atom(app) and is_atom(key) do
    quote bind_quoted: [app: app, key: key] do
      Configuration.get_config(&_compiled?/0, app, key)
    end
  end

  @doc """
  Gets a config for the app, key and a default and it returns an :ok tuple like `{:ok, <value>}` or `{:error, "reason"}`

  See `get_config!/3` for more information.
  """
  defmacro get_config(app, key, default) when is_atom(app) and is_atom(key) do
    quote bind_quoted: [app: app, key: key, default: default] do
      Configuration.get_config(&_compiled?/0, app, key, default)
    end
  end

  @doc """
  Gets a config for the app and key and it returns the `<value>`.

  It can raise `Configex.ConfigError` if the application is miss configured.

  See `get_config!/3` for more information.
  """
  defmacro get_config!(app, key) when is_atom(app) and is_atom(key) do
    quote bind_quoted: [app: app, key: key] do
      Configuration.get_config!(&_compiled?/0, app, key)
    end
  end

  @doc """
  Gets a config for the app, key and a default and it returns the `<value>`.

  It can raise `Configex.ConfigError` if the application is miss configured.

  ## Examples setup:

  ```elixir
  #{File.read!("test/support/my_app.ex")}
  ```

  ## Examples

  **Successful** `get_config!/3` usage:

      iex> MyApp.MyModule.hardcoded_nil()
      nil

      iex> MyApp.MyModule.hardcoded_value()
      "some hardcoded value"

      iex> MyApp.MyModule.missing_conf_default()
      "some default value"

      iex> MyApp.MyModule.missing_conf()
      ** (Configex.ConfigError) Missing configuration: 'config :my_app, missing_conf: <value>'

      iex> MyApp.MyModule.system_env()
      "some env value"

      iex> MyApp.MyModule.system_missing_default()
      "some default value"

      iex> MyApp.MyModule.system_default()
      "some system default"

      iex> MyApp.MyModule.system_missing()
      ** (Configex.ConfigError) Missing ENV variable: 'MISSING_ENV'

      iex> MyApp.MyModule.recursive_map()
      %{port: "9999"}

      iex> MyApp.MyModule.recursive_list()
      [port: "9999"]

  When **ENV** is used on **compile time**:

      iex> defmodule MyModuleFailWhenEnvOnModuleAttr do
      ...>   use Configex
      ...>
      ...>   @system_env get_config!(:my_app, :system_env)
      ...>
      ...>   def system_env(), do: @system_env
      ...> end
      ** (Configex.ConfigError) ENV must not be used on compilation time: 'MY_ENV'
  """
  defmacro get_config!(app, key, default) when is_atom(app) and is_atom(key) do
    quote bind_quoted: [app: app, key: key, default: default] do
      Configuration.get_config!(&_compiled?/0, app, key, default)
    end
  end

  @doc false
  defmacro _compiled?() do
    quote do
      function_exported?(__MODULE__, :__info__, 1)
    end
  end
end
