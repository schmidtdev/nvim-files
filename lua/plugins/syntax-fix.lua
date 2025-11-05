-- Configuração para otimizar syntax highlighting e resolver conflitos
return {
  -- Configurar treesitter com prioridade para syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Garantir parsers necessários
      vim.list_extend(opts.ensure_installed, {
        "javascript",
        "typescript",
        "tsx",
        "jsx",
        "css",
        "scss",
        "html",
        "json",
        "yaml",
      })
      
      -- Configurações de highlight otimizadas
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      opts.highlight.additional_vim_regex_highlighting = false
      
      -- Desabilitar LSP highlighting em favor do treesitter
      opts.highlight.disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end
      
      return opts
    end,
  },
  
  -- Configurar autocmds para priorizar treesitter
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Autocmd para forçar treesitter em arquivos JS/TS
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        callback = function(ev)
          local buf = ev.buf
          
          -- Forçar treesitter highlight
          vim.treesitter.start(buf)
          
          -- Desabilitar semantic tokens de todos os LSPs para este buffer
          local clients = vim.lsp.get_clients({ bufnr = buf })
          for _, client in ipairs(clients) do
            if client.server_capabilities.semanticTokensProvider then
              client.server_capabilities.semanticTokensProvider = nil
            end
          end
          
          -- Garantir que apenas vtsls forneça funcionalidades principais
          vim.api.nvim_create_autocmd("LspAttach", {
            buffer = buf,
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if not client then return end
              
              -- Se não for vtsls, limitar capacidades
              if client.name ~= "vtsls" then
                if client.name == "eslint" then
                  -- ESLint: apenas code actions e diagnostics
                  client.server_capabilities.hoverProvider = false
                  client.server_capabilities.completionProvider = false
                  client.server_capabilities.definitionProvider = false
                  client.server_capabilities.referencesProvider = false
                  client.server_capabilities.documentHighlightProvider = false
                  client.server_capabilities.semanticTokensProvider = nil
                elseif client.name == "tailwindcss" then
                  -- Tailwind: apenas completion para classes CSS
                  client.server_capabilities.hoverProvider = true -- manter para ver classes
                  client.server_capabilities.definitionProvider = false
                  client.server_capabilities.referencesProvider = false
                  client.server_capabilities.documentHighlightProvider = false
                  client.server_capabilities.semanticTokensProvider = nil
                end
              end
            end,
          })
        end,
      })
      
      -- Autocmd para refresh do highlighting quando necessário
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
        callback = function()
          -- Force refresh do treesitter highlighting
          vim.cmd("silent! TSBufEnable highlight")
        end,
      })
    end,
  },
}