local wezterm = require("wezterm")

local G = {}

-- Colorscheme
local file = io.open(wezterm.config_dir .. "/colorscheme", "r")
if file then
	G.color_scheme = file:read("*a")
	file:close()
else
	G.color_scheme = "Tokyo Night Day"
end

G.font = wezterm.font("JetBrains Mono")
-- G.font = wezterm.font("JetBrains Mono", { italic = true })
-- G.font = wezterm.font("Fira Code")
-- G.font = wezterm.font("Maple Mono")
-- G.font = wezterm.font("Monaspace Xenon Var")
-- G.font = wezterm.font("Monaspace Neon Var")
-- G.font = wezterm.font("Monaspace Radon Var")
-- G.font = wezterm.font("Monaspace Krypton Var")
-- G.font = wezterm.font("Monaspace Argon Var")
G.font_size = 13

-- Tab bar
G.use_fancy_tab_bar = false
G.hide_tab_bar_if_only_one_tab = false
G.enable_tab_bar = true
G.show_tabs_in_tab_bar = true
G.tab_max_width = 50
G.tab_bar_at_bottom = true
G.show_tab_index_in_tab_bar = true
G.show_new_tab_button_in_tab_bar = false

G.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono" }),
	font_size = 12.0,
}

G.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return G
