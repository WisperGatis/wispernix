return {
  {
    "lambdalisue/vim-suda",
    lazy = false,
    init = function()
      vim.g.suda_smart_edit = 1
    end,
  },

  {
    "folke/snacks.nvim",
    opts = {
      indent = {
        filter = function(buf)
          local bt = vim.bo[buf].buftype
          return bt == "" or bt == "acwrite"
        end,
      },
    },
  },

  {
    "keremimo/noctalia.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      palette_path = vim.fn.expand("~/.config/noctalia/colors.json"),
      auto_reload = true,
      transparent = false,
    },
  },
  {
    "LazyVim/LazyVim",
    pts = {
      colorscheme = "noctalia",
    },
  },
}
