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

  ## Examples

  **Successful** `get_config!/3` usage:

      iex> System.put_env("MY_ENV", "some env value")
      ...>
      ...> Application.put_env(:my_app, :hardcoded_nil, nil)
      ...> Application.put_env(:my_app, :hardcoded_value, "some hardcoded value")
      ...> Application.put_env(:my_app, :system_env, {:system, "MY_ENV"})
      ...> Application.put_env(:my_app, :system_missing, {:system, "MISSING_ENV"})
      ...> Application.put_env(:my_app, :system_default, {:system, "MISSING_ENV", "some system default"})
      ...>
      iex> defmodule MyModule do
      ...>   use Configex
      ...>
      ...>   @hardcoded_nil get_config!(:my_app, :hardcoded_nil)
      ...>   @hardcoded_value get_config!(:my_app, :hardcoded_value)
      ...>
      ...>   def hardcoded_nil(), do: @hardcoded_nil
      ...>   def hardcoded_value(), do: @hardcoded_value
      ...>   def missing_conf_default(), do: get_config!(:my_app, :missing_conf, "some default value")
      ...>
      ...>   def system_env(), do: get_config!(:my_app, :system_env)
      ...>   def system_missing_default(), do: get_config!(:my_app, :system_missing, "some default value")
      ...>   def system_default(), do: get_config!(:my_app, :system_default)
      ...> end
      ...>
      iex> MyModule.hardcoded_nil()
      nil
      ...>
      iex> MyModule.hardcoded_value()
      "some hardcoded value"
      ...>
      iex> MyModule.missing_conf_default()
      "some default value"
      ...>
      iex> MyModule.system_env()
      "some env value"
      ...>
      iex> MyModule.system_missing_default()
      "some default value"
      ...>
      iex> MyModule.system_default()
      "some system default"

  **Failed** to `get_config!/3`:

  When **ENV** is used on **compile time**:

      iex> Application.put_env(:my_app, :system_env, {:system, "MY_ENV"})
      ...>
      iex> defmodule MyModuleFailWhenEnvOnModuleAttr do
      ...>   use Configex
      ...>
      ...>   @system_env get_config!(:my_app, :system_env)
      ...>
      ...>   def system_env(), do: @system_env
      ...> end
      ** (Configex.ConfigError) ENV must not be used on compilation time: 'MY_ENV'

  When **missing config**:

      iex> defmodule MyModuleFailWhenMissingConf do
      ...>   use Configex
      ...>
      ...>   def missing_conf(), do: get_config!(:my_app, :missing_conf)
      ...> end
      ...>
      ...> MyModuleFailWhenMissingConf.missing_conf()
      ** (Configex.ConfigError) Missing configuration: 'config :my_app, missing_conf: <value>'

  When **missing ENV var**:

      iex> Application.put_env(:my_app, :system_missing, {:system, "MISSING_ENV"})
      ...>
      iex> defmodule MyModuleFailWhenMissingEnv do
      ...>   use Configex
      ...>
      ...>   def system_missing(), do: get_config!(:my_app, :system_missing)
      ...> end
      ...>
      ...> MyModuleFailWhenMissingEnv.system_missing()
      ** (Configex.ConfigError) Missing ENV variable: 'MISSING_ENV'
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
