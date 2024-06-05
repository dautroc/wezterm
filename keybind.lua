local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")
local function is_vim(pane)
	local process_info = pane:get_foreground_process_info()
	local process_name = process_info and process_info.name

	return process_name == "nvim" or process_name == "vim"
end

local G = {}

G.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
G.keys = {
	{
		-- https://wezfurlong.org/wezterm/config/lua/keyassignment/InputSelector.html?h=fuzzy#example-of-choosing-some-canned-text-to-enter-into-the-terminal
		key = "i",
		mods = "LEADER",
		action = act.InputSelector({
			action = wezterm.action_callback(function(window, pane, id, label)
				if not id and not label then
					wezterm.log_info("cancelled")
				else
					wezterm.log_info("you selected ", id, label)
					pane:send_text(id)
				end
			end),
			title = "I am title",
			choices = {
				{
					label = "Rails c",
					id = "bundle exec rails c",
				},
				{
					label = "Rename current workspace",
					id = "wezterm cli rename-workspace ",
				},
				{
					label = "cd ssh app",
					id = "cd /var/app/current && bundle exec rails c",
				},
			},
		}),
	},
	{
		key = "k",
		mods = "CMD",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},
	{ key = "p", mods = "CMD", action = act.ActivateCommandPalette },
	-- Fuzzy workspace
	{
		key = "s",
		mods = "LEADER",
		-- action = act.SwitchWorkspaceRelative(1),
		-- Enable this to show the launcher args
		action = act.ShowLauncherArgs({ flags = "WORKSPACES|FUZZY" }),
	},
	-- New workspace
	{
		key = "a",
		mods = "LEADER",
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
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
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
	{ key = "t", mods = "LEADER", action = act.ShowTabNavigator },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	-- { key = "N", mods = "LEADER", action = act.MoveTabRelative(1) },
	-- { key = "P", mods = "LEADER", action = act.MoveTabRelative(-1) },
	-- { key = "p", mods = "LEADER", action = act.PaneSelect },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "e", mods = "LEADER", action = act.EmitEvent("trigger-nvim-with-scrollback") },
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{ key = " ", mods = "LEADER", action = act.ActivateCopyMode },

	-- Support navigation
	utils.bind_if(utils.is_outside_vim, "h", "CTRL", act.ActivatePaneDirection("Left")),
	utils.bind_if(utils.is_outside_vim, "l", "CTRL", act.ActivatePaneDirection("Right")),
	utils.bind_if(utils.is_outside_vim, "j", "CTRL", act.ActivatePaneDirection("Down")),
	utils.bind_if(utils.is_outside_vim, "k", "CTRL", act.ActivatePaneDirection("Up")),

  -- Disable default keybindings
	{ key = "m", mods = "CMD", action = act.DisableDefaultAssignment },
	{ key = "h", mods = "CMD", action = act.DisableDefaultAssignment },
	{ key = "m", mods = "CTRL", action = act.DisableDefaultAssignment },
}

G.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },

		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
	search_mode = {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "j", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "k", mods = "CTRL", action = act.CopyMode("PriorMatch") },
	},
}

return G
