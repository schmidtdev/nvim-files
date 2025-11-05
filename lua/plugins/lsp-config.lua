-- Configuração personalizada para evitar conflitos entre LSPs
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Configurar vtsls como LSP principal para TypeScript/JavaScript
        vtsls = {
          settings = {
            vtsls = {
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              preferences = {
                includePackageJsonAutoImports = "auto",
              },
              suggest = {
                completeFunctionCalls = true,
              },
            },
            javascript = {
              preferences = {
                includePackageJsonAutoImports = "auto",
              },
              suggest = {
                completeFunctionCalls = true,
              },
            },
          },
        },
        -- ESLint configurado apenas para linting, sem syntax highlighting
        eslint = {
          settings = {
            -- Desabilitar resources que conflitam com vtsls
            validate = "on",
            packageManager = "npm",
            useESLintClass = false,
            experimental = {
              useFlatConfig = false,
            },
            codeActionOnSave = {
              enable = true,
              mode = "all",
            },
          },
          -- Limitar capacidades do ESLint
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- Desabilitar hover e completion do ESLint
            capabilities.textDocument.hover = nil
            capabilities.textDocument.completion = nil
            capabilities.textDocument.signatureHelp = nil
            return capabilities
          end)(),
        },
        -- Tailwind CSS configurado apenas para CSS classes
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  "tw`([^`]*)",
                  "tw=\"([^\"]*)",
                  "tw={'([^'}]*)",
                  "tw\\.\\w+`([^`]*)",
                  "tw\\(.*?\\)`([^`]*)",
                },
              },
            },
          },
          -- Limitar escopo do Tailwind
          filetypes = {
            "html",
            "css",
            "scss",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
          },
          -- Limitar capacidades do Tailwind
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- Manter apenas completion e hover para classes CSS
            capabilities.textDocument.semanticTokens = nil
            capabilities.textDocument.formatting = nil
            return capabilities
          end)(),
        },
      },
      -- Configurar prioridades e conflitos
      setup = {
        eslint = function(_, opts)
          -- Configurar ESLint para trabalhar apenas como linter
          local eslint = require("lspconfig").eslint
          eslint.setup(vim.tbl_deep_extend("force", opts, {
            on_attach = function(client, bufnr)
              -- Desabilitar funcionalidades que conflitam
              client.server_capabilities.hoverProvider = false
              client.server_capabilities.completionProvider = false
              client.server_capabilities.signatureHelpProvider = false
              client.server_capabilities.semanticTokensProvider = nil
              
              -- Manter apenas code actions e formatting
              vim.api.nvim_buf_create_user_command(bufnr, "EslintFixAll", function()
                vim.lsp.buf.code_action({
                  context = {
                    only = { "source.fixAll.eslint" },
                    diagnostics = {},
                  },
                })
              end, { desc = "Fix all eslint problems" })
            end,
          }))
          return true
        end,
        
        vtsls = function(_, opts)
          -- Configurar vtsls como LSP principal
          local vtsls = require("lspconfig").vtsls
          vtsls.setup(vim.tbl_deep_extend("force", opts, {
            on_attach = function(client, bufnr)
              -- Garantir que vtsls seja o provider principal
              client.server_capabilities.semanticTokensProvider = {
                legend = {
                  tokenTypes = { "namespace", "type", "class", "enum", "interface", "struct", "typeParameter", "parameter", "variable", "property", "enumMember", "event", "function", "method", "macro", "keyword", "modifier", "comment", "string", "number", "regexp", "operator" },
                  tokenModifiers = { "declaration", "definition", "readonly", "static", "deprecated", "abstract", "async", "modification", "documentation", "defaultLibrary" }
                },
                range = true,
                full = { delta = true }
              }
            end,
          }))
          return true
        end,
      },
    },
  },
  
  -- Configurar treesitter para syntax highlighting consistente
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = {
        enable = true,
        -- Garantir que treesitter seja usado para syntax highlighting
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
}