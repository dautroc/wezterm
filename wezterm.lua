---@diagnostic disable: unused-local

local wezterm = require("wezterm")
local keybind = require("keybind")
local appearance = require("appearance")

require("callbacks")

-- This table will hold the configuration.
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Merge all the configuration sources into the config table
config_sources = {
  appearance,
  keybind,
  callbacks,
}

for _, source in ipairs(config_sources) do
  for key, value in pairs(source) do
    config[key] = value
  end
end

return config
