local function lspinfo()
  local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if next(buf_clients) == nil then
    return "No LSP"
  end
  return "LSP: " .. buf_clients[1].name
end

return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto", -- pode usar 'tokyonight', 'catppuccin', etc.
      section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
      disabled_filetypes = { "NvimTree", "lazy" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        { "filename", path = 1 }, -- mostra caminho relativo
      },
      lualine_x = { lspinfo, "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
