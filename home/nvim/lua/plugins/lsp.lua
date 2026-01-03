return {
  -- Core LSP configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      -- Import the plugins
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 1. Setup Mason (the installer)
      mason.setup()

      -- 2. Setup Mason-LSPConfig (the bridge)
      mason_lspconfig.setup({
        -- List servers you want automatically installed here:
        ensure_installed = { "rust_analyzer", "gopls", "lua_ls" }, 
        
        -- This "handlers" function is the modern way to setup servers
        handlers = {
          -- The default handler: applied to every server installed by Mason
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
            })
          end,

          -- Example: If you need specific settings for a server (like Lua), override it here:
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = { globals = { "vim" } },
                },
              },
            })
          end,
        },
      })
    end,
  },

  -- Autocompletion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "L3MON4D3/LuaSnip" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        -- Fix the "bad argument #1 to max" error by using native menu
        view = { entries = "native" }, 
        
        sources = { { name = "nvim_lsp" }, { name = "buffer" } },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
      })
    end,
  },
}
