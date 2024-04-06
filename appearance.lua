local wezterm = require("wezterm")

local G = {}

G.color_scheme = "Kanagawa (Gogh)"
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
		background = "#0b0022",
		active_tab = {
			bg_color = "#ffffff",
			fg_color = "#000000",
			intensity = "Normal",
			underline = "None",
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = "#1b1032",
			fg_color = "#808080",
		},
		inactive_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#909090",
			italic = true,
		},

		new_tab = {
			bg_color = "#1b1032",
			fg_color = "#808080",
		},
		new_tab_hover = {
			bg_color = "#3b3052",
			fg_color = "#909090",
			italic = true,
		},
	},
}

G.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return G
