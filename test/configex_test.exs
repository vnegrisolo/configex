defmodule ConfigexTest do
  use ExUnit.Case
  doctest Configex

  use Configex

  setup_all do
    System.put_env("ENV_TEST_1", "value 1")
  end

  describe "get_config!/2" do
    test "raise is configuration is missing" do
      assert_raise Configex.ConfigError, fn ->
        get_config!(:configex, :missing_conf)
      end
    end

    test "gets harcoded_nil" do
      assert get_config!(:configex, :harcoded_nil) == nil
    end

    test "gets harcoded_value" do
      assert get_config!(:configex, :harcoded_value) == "Some harcoded value"
    end

    test "raise is ENV var is missing" do
      assert_raise Configex.ConfigError, fn ->
        get_config!(:configex, :system_missing)
      end
    end

    test "gets system_env" do
      assert get_config!(:configex, :system_env) == "value 1"
    end

    test "gets system_default" do
      assert get_config!(:configex, :system_default) == "some system default"
    end
  end

  describe "get_config!/3 with default" do
    test "gets default for missing_conf" do
      assert get_config!(:configex, :missing_conf, "my-default") == "my-default"
    end

    test "gets harcoded_nil" do
      assert get_config!(:configex, :harcoded_nil, "my-default") == nil
    end

    test "gets harcoded_value" do
      assert get_config!(:configex, :harcoded_value, "my-default") == "Some harcoded value"
    end

    test "gets default for system_missing" do
      assert get_config!(:configex, :system_missing, "my-default") == "my-default"
    end

    test "gets system_env" do
      assert get_config!(:configex, :system_env, "my-default") == "value 1"
    end

    test "gets system_default" do
      assert get_config!(:configex, :system_default, "my-default") == "some system default"
    end
  end

  describe "get_config/2" do
    test "errors out when is configuration is missing" do
      assert get_config(:configex, :missing_conf) ==
               {:error, "Missing configuration: 'config :configex, missing_conf: <value>'"}
    end

    test "gets harcoded_nil" do
      assert get_config(:configex, :harcoded_nil) == {:ok, nil}
    end

    test "gets harcoded_value" do
      assert get_config(:configex, :harcoded_value) == {:ok, "Some harcoded value"}
    end

    test "errors out when is ENV var is missing" do
      assert get_config(:configex, :system_missing) ==
               {:error, "Missing ENV variable: 'MISSING_ENV'"}
    end

    test "gets system_env" do
      assert get_config(:configex, :system_env) == {:ok, "value 1"}
    end

    test "gets system_default" do
      assert get_config(:configex, :system_default) == {:ok, "some system default"}
    end
  end

  describe "get_config/3 with default" do
    test "gets default for missing_conf" do
      assert get_config(:configex, :missing_conf, "my-default") == {:ok, "my-default"}
    end

    test "gets harcoded_nil" do
      assert get_config(:configex, :harcoded_nil, "my-default") == {:ok, nil}
    end

    test "gets harcoded_value" do
      assert get_config(:configex, :harcoded_value, "my-default") ==
               {:ok, "Some harcoded value"}
    end

    test "gets default for system_missing" do
      assert get_config(:configex, :system_missing, "my-default") == {:ok, "my-default"}
    end

    test "gets system_env" do
      assert get_config(:configex, :system_env, "my-default") == {:ok, "value 1"}
    end

    test "gets system_default" do
      assert get_config(:configex, :system_default, "my-default") ==
               {:ok, "some system default"}
    end
  end
end
