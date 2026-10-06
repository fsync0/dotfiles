-- Minimal Neovim foundation. The top buffer tabs intentionally mirror the
-- clean, flat BufferLine treatment used by 0xheap/neo.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.cmd.source(vim.fn.expand("~/.config/vim/wallpaper-theme.vim"))

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function kitty_palette()
  local palette = {}
  local palette_file = vim.fn.expand("~/.config/kitty/dynamic.conf")

  for line in io.lines(palette_file) do
    local name, color = line:match("^(background|foreground|selection_background|color%d+)%s+(#%x%x%x%x%x%x)")
    if name and color then
      palette[name] = color
    end
  end

  return palette
end

local function apply_tabline_colors()
  local colors = kitty_palette()
  if not (colors.background and colors.foreground and colors.color0 and colors.color4 and colors.color8) then
    return
  end

  local set = vim.api.nvim_set_hl
  set(0, "BufferLineFill", { bg = colors.background })
  set(0, "BufferLineBackground", { fg = colors.color8, bg = colors.background })
  set(0, "BufferLineBufferVisible", { fg = colors.foreground, bg = colors.background })
  set(0, "BufferLineBufferSelected", { fg = colors.foreground, bg = colors.color0, bold = false, italic = false })
  set(0, "BufferLineSeparator", { fg = colors.color0, bg = colors.background })
  set(0, "BufferLineSeparatorVisible", { fg = colors.color0, bg = colors.background })
  set(0, "BufferLineSeparatorSelected", { fg = colors.color0, bg = colors.color0 })
  set(0, "BufferLineModified", { fg = colors.color4, bg = colors.background })
  set(0, "BufferLineModifiedSelected", { fg = colors.color4, bg = colors.color0 })
  set(0, "BufferLineIndicatorSelected", { fg = colors.color0, bg = colors.color0 })
end

require("lazy").setup({
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local bufferline = require("bufferline")
      bufferline.setup({
        options = {
          mode = "buffers",
          style_preset = {
            bufferline.style_preset.no_bold,
            bufferline.style_preset.no_italic,
          },
          themable = false,
          separator_style = "thin",
          indicator = { style = "none" },
          show_buffer_close_icons = false,
          show_close_icon = false,
          always_show_bufferline = true,
        },
      })
      apply_tabline_colors()
    end,
  },
}, {
  checker = { enabled = false },
  change_detection = { notify = false },
})

vim.api.nvim_create_autocmd("FocusGained", {
  callback = apply_tabline_colors,
  desc = "Refresh tabline after a wallpaper palette change",
})
