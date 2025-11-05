-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Configurações para melhorar syntax highlighting
vim.opt.syntax = "on"
vim.opt.termguicolors = true

-- Configurações específicas para LSP e treesitter
vim.g.lazy_format = true

-- Priorizar treesitter para syntax highlighting
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Desabilitar highlighting baseado em regex em favor do treesitter
    vim.cmd("syntax off")
    vim.opt.syntax = "off"
  end,
})
