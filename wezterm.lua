---@diagnostic disable: unused-local

local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

--------------------------
-- PLUGIN CONFIGURATION --
--------------------------
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

----------------
-- APPEARANCE --
----------------

-- Colorscheme sync
local file = io.open(wezterm.config_dir .. "/colorscheme", "r")
if file then
	config.color_scheme = file:read("*a")
	file:close()
else
	config.color_scheme = "Catppuccin Frappe"
end

config.window_decorations = "RESIZE"
config.font = wezterm.font_with_fallback { 'JetBrains Mono', 'Maple Mono' }
config.font_size = 13

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.enable_tab_bar = true
config.show_tabs_in_tab_bar = true
config.tab_max_width = 50
config.tab_bar_at_bottom = false
config.show_tab_index_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.status_update_interval = 1000

config.window_frame = {
	font = wezterm.font({ family = "JetBrains Mono" }),
	font_size = 12.0,
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

------------------
-- KEY BINDINGS --
------------------

local act = wezterm.action
local utils = require("utils")

local function is_vim(pane)
	local process_info = pane:get_foreground_process_info()
	local process_name = process_info and process_info.name

	return process_name == "nvim" or process_name == "vim"
end

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Clear scrollback
	{
		key = "k",
		mods = "CMD",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},
	-- List workspace
	{
		key = "f",
		mods = "ALT",
		action = act.ShowLauncherArgs({ flags = "WORKSPACES|FUZZY" }),
	},
	-- New workspace
	{
		key = "w",
		mods = "ALT",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
	-- Rename tab title
	{
		key = "t",
		mods = "ALT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- Toggle popup terminal pane
	{
		key = ";",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			if is_vim(pane) then
				wezterm.log_info(#tab:panes(), "ok")
				if (#tab:panes()) == 1 then
					pane:split({ direction = "Bottom" })
				else
					window:perform_action({
						SendKey = { key = ";", mods = "CTRL" },
					}, pane)
				end
				return
			end

			local vim_pane = nil

			for _, p in ipairs(tab:panes()) do
				if is_vim(p) then
					vim_pane = p
					break
				end
			end

			if vim_pane then
				vim_pane:activate()
				tab:set_zoomed(true)
			end
		end),
	},
	-- Tab navigation
	{ key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },
	{ key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "k", mods = "ALT", action = act.MoveTabRelative(-1) },
	{ key = "j", mods = "ALT", action = act.MoveTabRelative(1) },

	{ key = "z", mods = "ALT", action = act.TogglePaneZoomState },
	{ key = "x", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "e", mods = "ALT", action = act.EmitEvent("trigger-nvim-with-scrollback") }, -- Edit terminal using nvim
	{ key = "r", mods = "ALT", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{ key = "y", mods = "ALT", action = act.ActivateCopyMode },

	-- Support navigation
	utils.bind_if(utils.is_outside_vim, "h", "CTRL", act.ActivatePaneDirection("Left")),
	utils.bind_if(utils.is_outside_vim, "l", "CTRL", act.ActivatePaneDirection("Right")),
	utils.bind_if(utils.is_outside_vim, "j", "CTRL", act.ActivatePaneDirection("Down")),
	utils.bind_if(utils.is_outside_vim, "k", "CTRL", act.ActivatePaneDirection("Up")),

	-- Disable default keybindings
	{ key = "m", mods = "CTRL", action = act.DisableDefaultAssignment },

	-- Resurrect: Save workspace state
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	-- Resurrect: Load workspace state
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action_callback(function(window)
			local w = window:active_workspace()
			utils.kill_workspace(w)
		end),
	},
}

-- Resze pane key table
config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },

		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
	search_mode = {
		{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	},
}

----------------
-- CALLBACKS ---
----------------
require("callbacks")

-- Return the final configuration
return config
