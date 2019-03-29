defmodule ConfigexTest do
  use ExUnit.Case
  doctest Configex

  setup_all do
    System.put_env("ENV_TEST_1", "value 1")
  end

  describe "get_env/3" do
    test "raise is configuration is missing" do
      assert_raise ArgumentError, fn ->
        Configex.get_env(:configex, :missing_conf)
      end
    end

    test "gets harcoded_nil" do
      assert Configex.get_env(:configex, :harcoded_nil) == nil
    end

    test "gets harcoded_value" do
      assert Configex.get_env(:configex, :harcoded_value) == "Some harcoded value"
    end

    test "raise is ENV var is missing" do
      assert_raise ArgumentError, fn ->
        Configex.get_env(:configex, :system_missing)
      end
    end

    test "gets system_env" do
      assert Configex.get_env(:configex, :system_env) == "value 1"
    end

    test "gets system_default" do
      assert Configex.get_env(:configex, :system_default) == "some system default"
    end
  end

  describe "get_env/3 with default" do
    test "gets default for missing_conf" do
      assert Configex.get_env(:configex, :missing_conf, "my-default") == "my-default"
    end

    test "gets harcoded_nil" do
      assert Configex.get_env(:configex, :harcoded_nil, "my-default") == nil
    end

    test "gets harcoded_value" do
      assert Configex.get_env(:configex, :harcoded_value, "my-default") == "Some harcoded value"
    end

    test "gets default for system_missing" do
      assert Configex.get_env(:configex, :system_missing, "my-default") == "my-default"
    end

    test "gets system_env" do
      assert Configex.get_env(:configex, :system_env, "my-default") == "value 1"
    end

    test "gets system_default" do
      assert Configex.get_env(:configex, :system_default, "my-default") == "some system default"
    end
  end
end
