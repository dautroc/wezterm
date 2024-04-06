local wezterm = require("wezterm")
local act = wezterm.action
local io = require("io")
local os = require("os")
local mux = wezterm.mux

-- Toogle nvim zen mode
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

-- Toogle fullscreen when startup
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

-- Status bar
wezterm.on("update-right-status", function(window, pane)
	local separator = "  |  "
	local date = wezterm.strftime("%a %b %-d %H:%M ")

	window:set_right_status(wezterm.format({
		{ Text = " " .. window:active_workspace() .. separator .. date },
	}))
end)

wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
	local scrollback = pane:get_lines_as_text()
	local name = os.tmpname()
	local f = io.open(name, "w+")
	if f == nil then
		return
	end
	f:write(scrollback)
	f:flush()
	f:close()
	window:perform_action(
		act({
			SpawnCommandInNewTab = {
				args = { "/opt/homebrew/bin/nvim", name },
			},
		}),
		pane
	)
	wezterm.sleep_ms(1000)
	os.remove(name)
end)

-- Automatic switching theme
-- local function scheme_for_appearance(appearance)
--   if appearance:find 'Dark' then
--     return 'Gruvbox dark, soft (base16)'
--   else
--     return 'Gruvbox dark, soft (base16)'
--   end
-- end

-- wezterm.on('window-config-reloaded', function(window, pane)
--   local overrides = window:get_config_overrides() or {}
--   local appearance = window:get_appearance()
--   local scheme = scheme_for_appearance(appearance)
--   if overrides.color_scheme ~= scheme then
--     overrides.color_scheme = scheme
--     window:set_config_overrides(overrides)
--   end
-- end)
