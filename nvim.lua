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

vim.pack.add({
  { src = "https://github.com/vague2k/vague.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-mini/mini.pick" },
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
  "sourcekit",
  "tinymist",
  "lua_ls",
  "gleam",
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
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

require("mason").setup()

require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
})
vim.keymap.set("n", "\\", "<cmd>Oil<cr>")

require("mini.pick").setup()
vim.keymap.set("n", "<leader>s", "<cmd>Pick files<cr>")
vim.keymap.set("n", "<leader>g", "<cmd>Pick grep<cr>")
