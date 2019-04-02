defmodule Configex do
  @moduledoc """
  #{__MODULE__} is the public API for this library.
  """

  defmodule ConfigError do
    @moduledoc """
    #{__MODULE__} is an Error module.
    """
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
  Gets a config for the application by a key. Returns the value or raises an Configex.ConfigError.

    ## Examples

    When config **is NOT set**:

        iex> defmodule MyApp.MyModule13 do
        ...>   use Configex
        ...>
        ...>   def missing_conf(), do: get_config!(:my_app, :missing_conf)
        ...> end
        ...>
        iex> MyApp.MyModule13.missing_conf()
        ** (Configex.ConfigError) Missing configuration: 'config :my_app, missing_conf: <value>'

    When config **is set**:

        iex> Application.put_env(:my_app, :my_config, :foo_bar)
        ...>
        ...> defmodule MyApp.MyModule14 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config)
        ...> end
        ...>
        iex> MyApp.MyModule14.my_conf()
        :foo_bar

    When config **is set** to `nil`:

        iex> Application.put_env(:my_app, :my_config, nil)
        ...>
        ...> defmodule MyApp.MyModule15 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config)
        ...> end
        ...>
        iex> MyApp.MyModule15.my_conf()
        nil

    When config is a **missing ENV var**:

        iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV"})
        ...>
        ...> defmodule MyApp.MyModule16 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config)
        ...> end
        ...>
        iex> MyApp.MyModule16.my_conf()
        ** (Configex.ConfigError) Missing ENV variable: 'MISSING_ENV'

    When config is a **missing ENV var** but set with a default:

        iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV", "sys default"})
        ...>
        ...> defmodule MyApp.MyModule17 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config)
        ...> end
        ...>
        iex> MyApp.MyModule17.my_conf()
        "sys default"

    When config is a **ENV var**:

        iex> System.put_env("MY_ENV", "foo bar")
        ...> Application.put_env(:my_app, :my_config, {:system, "MY_ENV"})
        ...>
        ...> defmodule MyApp.MyModule18 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config)
        ...> end
        ...>
        iex> MyApp.MyModule18.my_conf()
        "foo bar"
  """
  defmacro get_config!(app, key) when is_atom(app) and is_atom(key) do
    quote do
      Configex.get_config!(unquote(app), unquote(key), :no_default)
    end
  end

  @doc """
  Gets a config for the application by a key or returns the default. Returns the value or raises an Configex.ConfigError.

    ## Examples

    When config **is NOT set**:

        iex> defmodule MyApp.MyModule19 do
        ...>   use Configex
        ...>
        ...>   def missing_conf(), do: get_config!(:my_app, :missing_conf, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule19.missing_conf()
        "my default"

    When config **is set**:

        iex> Application.put_env(:my_app, :my_config, :foo_bar)
        ...>
        ...> defmodule MyApp.MyModule20 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule20.my_conf()
        :foo_bar

    When config **is set** to `nil`:

        iex> Application.put_env(:my_app, :my_config, nil)
        ...>
        ...> defmodule MyApp.MyModule21 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule21.my_conf()
        nil

    When config is a **missing ENV var**:

        iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV"})
        ...>
        ...> defmodule MyApp.MyModule22 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule22.my_conf()
        "my default"

    When config is a **missing ENV var** but set with a default:

        iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV", "sys default"})
        ...>
        ...> defmodule MyApp.MyModule23 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule23.my_conf()
        "sys default"

    When config is a **ENV var**:

        iex> System.put_env("MY_ENV", "foo bar")
        ...> Application.put_env(:my_app, :my_config, {:system, "MY_ENV"})
        ...>
        ...> defmodule MyApp.MyModule24 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config!(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule24.my_conf()
        "foo bar"
  """
  defmacro get_config!(app, key, default) when is_atom(app) and is_atom(key) do
    quote do
      case Configex.get_config(unquote(app), unquote(key), unquote(default)) do
        {:ok, result} -> result
        {:error, reason} -> raise(ConfigError, reason)
      end
    end
  end

  @doc """
  Gets a config for the application by a key. Returns a {:ok, value} or {:error, message} tuples.

  ## Examples

  When config **is NOT set**:

      iex> defmodule MyApp.MyModule1 do
      ...>   use Configex
      ...>
      ...>   def missing_conf(), do: get_config(:my_app, :missing_conf)
      ...> end
      ...>
      iex> MyApp.MyModule1.missing_conf()
      {:error, "Missing configuration: 'config :my_app, missing_conf: <value>'"}

  When config **is set**:

      iex> Application.put_env(:my_app, :my_config, :foo_bar)
      ...>
      ...> defmodule MyApp.MyModule2 do
      ...>   use Configex
      ...>
      ...>   def my_conf(), do: get_config(:my_app, :my_config)
      ...> end
      ...>
      iex> MyApp.MyModule2.my_conf()
      {:ok, :foo_bar}

  When config **is set** to `nil`:

      iex> Application.put_env(:my_app, :my_config, nil)
      ...>
      ...> defmodule MyApp.MyModule3 do
      ...>   use Configex
      ...>
      ...>   def my_conf(), do: get_config(:my_app, :my_config)
      ...> end
      ...>
      iex> MyApp.MyModule3.my_conf()
      {:ok, nil}

  When config is a **missing ENV var**:

      iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV"})
      ...>
      ...> defmodule MyApp.MyModule4 do
      ...>   use Configex
      ...>
      ...>   def my_conf(), do: get_config(:my_app, :my_config)
      ...> end
      ...>
      iex> MyApp.MyModule4.my_conf()
      {:error, "Missing ENV variable: 'MISSING_ENV'"}

  When config is a **missing ENV var** but set with a default:

      iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV", "sys default"})
      ...>
      ...> defmodule MyApp.MyModule5 do
      ...>   use Configex
      ...>
      ...>   def my_conf(), do: get_config(:my_app, :my_config)
      ...> end
      ...>
      iex> MyApp.MyModule5.my_conf()
      {:ok, "sys default"}

  When config is a **ENV var**:

      iex> System.put_env("MY_ENV", "foo bar")
      ...> Application.put_env(:my_app, :my_config, {:system, "MY_ENV"})
      ...>
      ...> defmodule MyApp.MyModule6 do
      ...>   use Configex
      ...>
      ...>   def my_conf(), do: get_config(:my_app, :my_config)
      ...> end
      ...>
      iex> MyApp.MyModule6.my_conf()
      {:ok, "foo bar"}
  """
  defmacro get_config(app, key) when is_atom(app) and is_atom(key) do
    quote do
      Configex.get_config(unquote(app), unquote(key), :no_default)
    end
  end

  @doc """
  Gets a config for the application by a key or returns the default. Returns a {:ok, value} or {:error, message} tuples.

    ## Examples

    When config **is NOT set**:

        iex> defmodule MyApp.MyModule7 do
        ...>   use Configex
        ...>
        ...>   def missing_conf(), do: get_config(:my_app, :missing_conf, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule7.missing_conf()
        {:ok, "my default"}

    When config **is set**:

        iex> Application.put_env(:my_app, :my_config, :foo_bar)
        ...>
        ...> defmodule MyApp.MyModule8 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule8.my_conf()
        {:ok, :foo_bar}

    When config **is set** to `nil`:

        iex> Application.put_env(:my_app, :my_config, nil)
        ...>
        ...> defmodule MyApp.MyModule9 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule9.my_conf()
        {:ok, nil}

    When config is a **missing ENV var**:

        iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV"})
        ...>
        ...> defmodule MyApp.MyModule10 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule10.my_conf()
        {:ok, "my default"}

    When config is a **missing ENV var** but set with a default:

        iex> Application.put_env(:my_app, :my_config, {:system, "MISSING_ENV", "sys default"})
        ...>
        ...> defmodule MyApp.MyModule11 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule11.my_conf()
        {:ok, "sys default"}

    When config is a **ENV var**:

        iex> System.put_env("MY_ENV", "foo bar")
        ...> Application.put_env(:my_app, :my_config, {:system, "MY_ENV"})
        ...>
        ...> defmodule MyApp.MyModule12 do
        ...>   use Configex
        ...>
        ...>   def my_conf(), do: get_config(:my_app, :my_config, "my default")
        ...> end
        ...>
        iex> MyApp.MyModule12.my_conf()
        {:ok, "foo bar"}
  """
  defmacro get_config(app, key, default) when is_atom(app) and is_atom(key) do
    quote bind_quoted: [app: app, key: key, default: default] do
      case Application.get_env(app, key, default) do
        {:system, env, default} -> Configex.get_system_env(env, default)
        {:system, env} -> Configex.get_system_env(env, default)
        :no_default -> Configex.missing_config_error(app, key)
        value -> {:ok, value}
      end
    end
  end

  @doc false
  defmacro get_system_env(env, default) do
    quote bind_quoted: [env: env, default: default] do
      unless function_exported?(__MODULE__, :__info__, 1) do
        Configex.env_compilation_error(env)
      end

      case System.get_env(env) do
        nil ->
          case default do
            :no_default -> Configex.missing_env_var_error(env)
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
