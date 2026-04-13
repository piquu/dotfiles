vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.path:append("**")
vim.opt.scrolloff = 10
vim.opt.winborder = "rounded"
vim.opt.termguicolors = true
vim.cmd("setlocal spell spelllang=de_at,en_us")
vim.g.mapleader = " "

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('fff.nvim')
      end
      require('fff.download').download_or_build_binary()
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/nvim-mini/mini.files" },
  { src = "https://github.com/dmtrKovalenko/fff.nvim" },
})

require("vague").setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
  },
})

vim.lsp.enable({
  "rust_analyzer",
  "tinymist",
  "lua_ls",
  "biome",
  "gleam",
  "ts_ls",
  "emmet_ls",
})
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "e",
      [vim.diagnostic.severity.WARN] = "w",
      [vim.diagnostic.severity.HINT] = "h",
      [vim.diagnostic.severity.INFO] = "i",
    }
  }
})
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method('textDocument/completion') then
			-- Optional: trigger autocompletion on EVERY keypress. May be slow!
			--local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
			--client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})
vim.cmd("set completeopt+=menuone,popup,fuzzy,noinsert")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

require("conform").setup({
  formatters_by_ft = {
    javascript = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
  },
})

require("mason").setup()

require("mini.files").setup({
  content = {
    prefix = function() end,
  },

  windows = {
    preview = true,
  },
})
vim.keymap.set("n", "\\", MiniFiles.open)

vim.g.fff = {
  prompt = "? "
}
vim.keymap.set("n", "<leader>s", require("fff").find_files)
vim.keymap.set("n", "<leader>g", require("fff").live_grep)
