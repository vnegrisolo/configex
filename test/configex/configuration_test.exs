defmodule Configex.ConfigurationTest do
  use ExUnit.Case, async: true
  alias Configex.Configuration
  alias Configex.ConfigError
  doctest Configuration

  def not_to_be_called, do: raise("func is not called")
  def compiled, do: true
  def not_compiled, do: false

  setup_all do
    System.put_env("MY_ENV", "some env value")

    Application.put_env(:configuration, :hardcoded_nil, nil)
    Application.put_env(:configuration, :hardcoded_value, "some hardcoded value")
    Application.put_env(:configuration, :system_env, {:system, "MY_ENV"})
    Application.put_env(:configuration, :system_missing, {:system, "MISSING_ENV"})
    Application.put_env(:configuration, :system_default, {:system, "MISSING_ENV", "some system default"})

    :ok
  end

  describe "get_config/3" do
    test "errors out when config is missing" do
      assert Configuration.get_config(&not_to_be_called/0, :configuration, :missing_conf) ==
               {:error, "Missing configuration: 'config :configuration, missing_conf: <value>'"}
    end

    test "gets a hardcoded config nil" do
      assert Configuration.get_config(&not_to_be_called/0, :configuration, :hardcoded_nil) == {:ok, nil}
    end

    test "gets a hardcoded config value" do
      assert Configuration.get_config(&not_to_be_called/0, :configuration, :hardcoded_value) ==
               {:ok, "some hardcoded value"}
    end

    test "errors out when ENV is used on compilation time" do
      assert Configuration.get_config(&not_compiled/0, :configuration, :system_env) ==
               {:error, "ENV must not be used on compilation time: 'MY_ENV'"}
    end

    test "errors out when ENV is missing" do
      assert Configuration.get_config(&compiled/0, :configuration, :system_missing) ==
               {:error, "Missing ENV variable: 'MISSING_ENV'"}
    end

    test "gets an ENV value" do
      assert Configuration.get_config(&compiled/0, :configuration, :system_env) ==
               {:ok, "some env value"}
    end

    test "gets an system default when ENV is missing" do
      assert Configuration.get_config(&compiled/0, :configuration, :system_default) ==
               {:ok, "some system default"}
    end
  end

  describe "get_config/4" do
    test "errors out when config is missing" do
      assert Configuration.get_config(&not_to_be_called/0, :configuration, :missing_conf, "some default") ==
               {:ok, "some default"}
    end

    test "gets a hardcoded config nil" do
      assert Configuration.get_config(&not_to_be_called/0, :configuration, :hardcoded_nil, "some default") ==
               {:ok, nil}
    end

    test "gets a hardcoded config value" do
      assert Configuration.get_config(
               &not_to_be_called/0,
               :configuration,
               :hardcoded_value,
               "some default"
             ) == {:ok, "some hardcoded value"}
    end

    test "errors out when ENV is used on compilation time" do
      assert Configuration.get_config(&not_compiled/0, :configuration, :system_env, "some default") ==
               {:error, "ENV must not be used on compilation time: 'MY_ENV'"}
    end

    test "errors out when ENV is missing" do
      assert Configuration.get_config(&compiled/0, :configuration, :system_missing, "some default") ==
               {:ok, "some default"}
    end

    test "gets an ENV value" do
      assert Configuration.get_config(&compiled/0, :configuration, :system_env, "some default") ==
               {:ok, "some env value"}
    end

    test "gets an system default when ENV is missing" do
      assert Configuration.get_config(&compiled/0, :configuration, :system_default, "some default") ==
               {:ok, "some system default"}
    end
  end

  describe "get_config!/3" do
    test "errors out when config is missing" do
      assert_raise(ConfigError, fn ->
        assert Configuration.get_config!(&not_to_be_called/0, :configuration, :missing_conf)
      end)
    end

    test "gets a hardcoded config nil" do
      assert Configuration.get_config!(&not_to_be_called/0, :configuration, :hardcoded_nil) == nil
    end

    test "gets a hardcoded config value" do
      assert Configuration.get_config!(&not_to_be_called/0, :configuration, :hardcoded_value) ==
               "some hardcoded value"
    end

    test "errors out when ENV is used on compilation time" do
      assert_raise(ConfigError, fn ->
        assert Configuration.get_config!(&not_compiled/0, :configuration, :system_env)
      end)
    end

    test "errors out when ENV is missing" do
      assert_raise(ConfigError, fn ->
        assert Configuration.get_config!(&compiled/0, :configuration, :system_missing)
      end)
    end

    test "gets an ENV value" do
      assert Configuration.get_config!(&compiled/0, :configuration, :system_env) == "some env value"
    end

    test "gets an system default when ENV is missing" do
      assert Configuration.get_config!(&compiled/0, :configuration, :system_default) ==
               "some system default"
    end
  end

  describe "get_config!/4" do
    test "errors out when config is missing" do
      assert Configuration.get_config!(
               &not_to_be_called/0,
               :configuration,
               :missing_conf,
               "some default"
             ) == "some default"
    end

    test "gets a hardcoded config nil" do
      assert Configuration.get_config!(
               &not_to_be_called/0,
               :configuration,
               :hardcoded_nil,
               "some default"
             ) == nil
    end

    test "gets a hardcoded config value" do
      assert Configuration.get_config!(
               &not_to_be_called/0,
               :configuration,
               :hardcoded_value,
               "some default"
             ) == "some hardcoded value"
    end

    test "errors out when ENV is used on compilation time" do
      assert_raise(ConfigError, fn ->
        assert Configuration.get_config!(&not_compiled/0, :configuration, :system_env, "some default")
      end)
    end

    test "errors out when ENV is missing" do
      assert Configuration.get_config!(&compiled/0, :configuration, :system_missing, "some default") ==
               "some default"
    end

    test "gets an ENV value" do
      assert Configuration.get_config!(&compiled/0, :configuration, :system_env, "some default") ==
               "some env value"
    end

    test "gets an system default when ENV is missing" do
      assert Configuration.get_config!(&compiled/0, :configuration, :system_default, "some default") ==
               "some system default"
    end
  end
end
