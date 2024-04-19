---@diagnostic disable: unused-local

local wezterm = require("wezterm")
local keybind = require("keybind")
local appearance = require("appearance")

-- This table will hold the configuration.
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Merge all the configuration sources into the config table
local config_sources = {
  appearance,
  keybind,
}

for _, source in ipairs(config_sources) do
  for key, value in pairs(source) do
    config[key] = value
  end
end

require("callbacks")
return config
