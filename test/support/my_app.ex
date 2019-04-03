[
  {"MY_ENV", "some env value"},
  {"MY_PORT", "9999"}
]
|> Enum.each(fn {key, value} ->
  System.put_env(key, value)
end)

[
  hardcoded_nil: nil,
  hardcoded_value: "some hardcoded value",
  system_env: {:system, "MY_ENV"},
  system_missing: {:system, "MISSING_ENV"},
  system_default: {:system, "MISSING_ENV", "some system default"},
  recursive_map: %{port: {:system, "MY_PORT"}},
  recursive_list: [port: {:system, "MY_PORT"}]
]
|> Enum.each(fn {key, value} ->
  Application.put_env(:my_app, key, value)
end)

defmodule MyApp do
  @moduledoc false
  defmodule MyModule do
    @moduledoc false
    use Configex

    @hardcoded_nil get_config!(:my_app, :hardcoded_nil)
    @hardcoded_value get_config!(:my_app, :hardcoded_value)

    def hardcoded_nil(), do: @hardcoded_nil
    def hardcoded_value(), do: @hardcoded_value
    def missing_conf_default(), do: get_config!(:my_app, :missing_conf, "some default value")
    def missing_conf(), do: get_config!(:my_app, :missing_conf)

    def system_env(), do: get_config!(:my_app, :system_env)
    def system_missing_default(), do: get_config!(:my_app, :system_missing, "some default value")
    def system_default(), do: get_config!(:my_app, :system_default)
    def system_missing(), do: get_config!(:my_app, :system_missing)

    def recursive_map(), do: get_config!(:my_app, :recursive_map)
    def recursive_list(), do: get_config!(:my_app, :recursive_list)
  end
end
