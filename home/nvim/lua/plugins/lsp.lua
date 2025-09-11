-- File: nvim/lua/plugins/lsp.lua

return {
  -- Core LSP configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason").setup()
      require("mason-lspconfig").setup()

      -- Setup language servers here. Mason will install them automatically.
      -- Example for Rust and Go:
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      -- Add more language servers as needed, e.g.:
      -- lspconfig.tsserver.setup({ capabilities = capabilities }) -- for TypeScript
      -- lspconfig.pyright.setup({ capabilities = capabilities }) -- for Python
    end,
  },

  -- Autocompletion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "L3MON4D3/LuaSnip" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
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
