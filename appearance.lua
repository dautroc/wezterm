local wezterm = require("wezterm")

local G = {}

-- Colorscheme
local file = io.open("~/config/wezterm/colorscheme", "r")
if file then
	G.color_scheme = file:read("*a")
	file:close()
else
	G.color_scheme = "Tokyo Night Day"
end

G.font = wezterm.font("JetBrains Mono")
G.font_size = 13

-- Tab bar
G.use_fancy_tab_bar = true
G.hide_tab_bar_if_only_one_tab = false

G.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono" }),
	font_size = 12.0,
	active_titlebar_bg = "#333333",
	inactive_titlebar_bg = "#333333",
}

G.colors = {
  tab_bar = {
    inactive_tab_edge = '#575757',
  },
}

G.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return G
