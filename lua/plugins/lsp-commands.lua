-- Comandos para diagnosticar e corrigir problemas de LSP/syntax highlighting
return {
  {
    "LazyVim/LazyVim",
    keys = {
      -- Comando para mostrar LSPs ativos
      {
        "<leader>li",
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then
            vim.notify("Nenhum LSP ativo neste buffer", vim.log.levels.INFO)
            return
          end
          
          local info = {}
          for _, client in ipairs(clients) do
            table.insert(info, string.format("• %s (id: %d)", client.name, client.id))
          end
          
          vim.notify("LSPs ativos:\n" .. table.concat(info, "\n"), vim.log.levels.INFO)
        end,
        desc = "Mostrar LSPs ativos",
      },
      
      -- Comando para reiniciar treesitter highlight
      {
        "<leader>tr",
        function()
          vim.cmd("TSBufDisable highlight")
          vim.cmd("TSBufEnable highlight")
          vim.notify("Treesitter highlight reiniciado", vim.log.levels.INFO)
        end,
        desc = "Reiniciar Treesitter highlight",
      },
      
      -- Comando para reiniciar LSPs
      {
        "<leader>lr",
        function()
          vim.cmd("LspRestart")
          vim.notify("LSPs reiniciados", vim.log.levels.INFO)
        end,
        desc = "Reiniciar LSPs",
      },
      
      -- Comando para forçar refresh do syntax highlighting
      {
        "<leader>lf",
        function()
          -- Parar todos os LSPs semantic tokens
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          for _, client in ipairs(clients) do
            if client.server_capabilities.semanticTokensProvider and client.name ~= "vtsls" then
              client.server_capabilities.semanticTokensProvider = nil
            end
          end
          
          -- Reiniciar treesitter
          vim.treesitter.stop(0)
          vim.treesitter.start(0)
          
          -- Forçar redraw
          vim.cmd("redraw!")
          vim.notify("Syntax highlighting corrigido", vim.log.levels.INFO)
        end,
        desc = "Corrigir syntax highlighting",
      },
    },
  },
}