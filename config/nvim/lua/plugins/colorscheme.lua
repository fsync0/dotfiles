return {
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		opts = function()
			return {
				transparent = true,
				on_highlights = function(highlights)
					local terminal_bg = "#06191d"
					local terminal_fg = "#aebdc0"
					local terminal_border = "#585858"

					highlights.Pmenu = { fg = terminal_fg, bg = terminal_bg }
					highlights.PmenuSel = { fg = terminal_fg, bg = "#1d3035" }
					highlights.PmenuSbar = { bg = terminal_bg }
					highlights.PmenuThumb = { bg = "#587177" }
					highlights.NormalFloat = { fg = terminal_fg, bg = terminal_bg }
					highlights.FloatBorder = { fg = terminal_border, bg = terminal_bg }

					-- Blink completion list: keep its own background solid and dark.
					highlights.BlinkCmpMenu = { fg = terminal_fg, bg = terminal_bg }
					highlights.BlinkCmpMenuSelection = { fg = terminal_fg, bg = "#1d3035" }
					highlights.BlinkCmpMenuBorder = { fg = terminal_border, bg = terminal_bg }
					highlights.BlinkCmpDocBorder = { fg = terminal_border, bg = terminal_bg }
					highlights.BlinkCmpDocSeparator = { fg = terminal_border, bg = terminal_bg }
					highlights.BlinkCmpSignatureHelpBorder = { fg = terminal_border, bg = terminal_bg }
				end,
			}
		end,
	},
}
