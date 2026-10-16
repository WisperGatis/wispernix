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
}
