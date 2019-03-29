use Mix.Config

config :configex,
  harcoded_nil: nil,
  harcoded_value: "Some harcoded value",
  system_env: {:system, "ENV_TEST_1"},
  system_missing: {:system, "MISSING_ENV"},
  system_default: {:system, "MISSING_ENV", "some system default"}
