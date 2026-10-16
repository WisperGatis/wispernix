
return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 10001,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local path = vim.fn.expand(
          "~/.config/nvim/lua/matugen.lua"
        )

        local theme = dofile(path)
        theme.setup()
      end,
    },
  },
}

