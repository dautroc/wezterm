---@diagnostic disable: unused-local

local wezterm = require("wezterm")
local keybind = require("keybind")

require("callbacks")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Appearance
config.color_scheme = "Gruvbox dark, soft (base16)"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 13

-- Tab bar
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

config.window_padding = {
	left = 2,
	right = 2,
	top = 0,
	bottom = 0,
}

-- Key binding
config.leader = keybind.leader
config.keys = keybind.keys
config.key_tables = keybind.key_tables

return config
