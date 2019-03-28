defmodule ConfigexTest do
  use ExUnit.Case
  doctest Configex

  describe "get_env/3" do
    test "gets harcoded_value" do
      assert Configex.get_env(:configex, :harcoded_value) == "Some harcoded value"
    end

    test "gets system_env" do
      assert Configex.get_env(:configex, :system_env) == System.get_env("HOME")
    end
  end
end
