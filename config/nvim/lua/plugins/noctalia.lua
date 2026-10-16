return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        dofile(vim.fn.expand("~/.config/lua/matugen.lua"))
      end,
    },
  },
}
