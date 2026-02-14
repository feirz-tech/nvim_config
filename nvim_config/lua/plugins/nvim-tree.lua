return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      -- 固定在左侧
      view = {
        side = "left",
        width = function()
          return math.floor(vim.o.columns * 0.2) -- 20% 屏幕宽度
        end,
        preserve_window_proportions = true, -- 保持窗口比例
      },
      -- 当其他窗口打开时的行为
      actions = {
        open_file = {
          resize_window = false, -- 打开文件时不调整窗口大小
        },
      },
      -- 渲染设置
      renderer = {
        indent_markers = {
          enable = true,
        },
      },
    })
  end,
}
