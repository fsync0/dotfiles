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

local lsp_servers = { "lua_ls", "pyright", "ts_ls", "bashls", "jsonls", "yamlls" }

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { prefix = "●", spacing = 2 },
  float = { border = "rounded", source = "if_many" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local function map(mode, keys, action, description)
      vim.keymap.set(mode, keys, action, {
        buffer = event.buf,
        silent = true,
        desc = description,
      })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gr", vim.lsp.buf.references, "Show references")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "K", vim.lsp.buf.hover, "Show documentation")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    vim.keymap.set("n", "<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = event.buf, silent = true, desc = "Format buffer" })
  end,
  desc = "Set LSP buffer shortcuts",
})

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
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      for _, server in ipairs(lsp_servers) do
        vim.lsp.config(server, { capabilities = capabilities })
      end
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })
      require("mason-lspconfig").setup({
        ensure_installed = lsp_servers,
        automatic_enable = lsp_servers,
      })
      vim.schedule(function()
        if vim.bo.filetype ~= "" then
          vim.api.nvim_exec_autocmds("FileType", {
            pattern = vim.bo.filetype,
            modeline = false,
          })
        end
      end)
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Show buffer keymaps",
      },
    },
    opts = {
      preset = "modern",
      delay = 250,
      win = { border = "rounded" },
      spec = {
        { "<leader>c", group = "Code" },
        { "<leader>r", group = "Refactor" },
      },
    },
  },
}, {
  checker = { enabled = false },
  change_detection = { notify = false },
})

vim.api.nvim_create_autocmd("FocusGained", {
  callback = apply_tabline_colors,
  desc = "Refresh tabline after a wallpaper palette change",
})
