return {
  "zaldih/themery.nvim",
  config = function()
    require("themery").setup({
      themes = { "tokyonight", "catppuccin", "gruvbox", "rose-pine" },
      livePreview = true,
    })
  end,
}
