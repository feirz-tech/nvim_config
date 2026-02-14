-- Claude 和 nvim-tree 布局辅助工具
local M = {}

-- 检查 nvim-tree 是否打开
function M.is_nvim_tree_open()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "NvimTree" then
      return true, win
    end
  end
  return false, nil
end

-- 检查 Claude 终端是否打开
function M.is_claude_open()
  if _G.claude_instance and _G.claude_instance:is_open() then
    return true
  end
  return false
end

-- 智能布局：nvim-tree 在左（20%），Claude 在右（30%）
function M.fix_layout()
  local tree_open, tree_win = M.is_nvim_tree_open()
  local claude_open = M.is_claude_open()

  if tree_open and tree_win then
    -- 确保 nvim-tree 在最左边，20% 宽度
    vim.api.nvim_set_current_win(tree_win)
    vim.cmd("wincmd H")
    local tree_width = math.floor(vim.o.columns * 0.2)
    vim.cmd("vertical resize " .. tree_width)
  end

  if claude_open and _G.claude_instance then
    -- 确保 Claude 在最右边，30% 宽度
    for _, win in pairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if buf == _G.claude_instance.bufnr then
        vim.api.nvim_set_current_win(win)
        vim.cmd("wincmd L")
        local claude_width = math.floor(vim.o.columns * 0.3)
        vim.cmd("vertical resize " .. claude_width)
        break
      end
    end
  end
end

-- 在打开/关闭侧边栏后调用
function M.on_sidebar_change()
  vim.defer_fn(function()
    M.fix_layout()
  end, 50)
end

return M
