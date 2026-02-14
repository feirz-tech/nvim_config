-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "v", "c", "x", "s" }, "bb", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("t", "bb", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Terminal Normal Mode" })

-- 终端模式粘贴支持（全局）
vim.keymap.set("t", "<C-v>", function()
  local content = vim.fn.getreg("+")
  vim.api.nvim_feedkeys(content, "t", false)
end, { noremap = true, silent = true, desc = "Paste from clipboard (Ctrl+V)" })

vim.keymap.set("t", "<C-S-v>", function()
  local content = vim.fn.getreg("+")
  vim.api.nvim_feedkeys(content, "t", false)
end, { noremap = true, silent = true, desc = "Paste from clipboard (Ctrl+Shift+V)" })

-- 终端模式：Cmd+V 粘贴（需要 iTerm2 配置支持）
vim.keymap.set("t", "<D-v>", function()
  local content = vim.fn.getreg("+")
  vim.api.nvim_feedkeys(content, "t", false)
end, { noremap = true, silent = true, desc = "Paste from clipboard (Cmd+V)" })

-- 终端模式：Cmd+C 复制（需要先选中文本）
vim.keymap.set("t", "<D-c>", function()
  -- 先退出终端模式到普通模式
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
  -- 然后复制
  vim.defer_fn(function()
    vim.cmd('normal! "+y')
  end, 50)
end, { noremap = true, silent = true, desc = "Copy in terminal (Cmd+C)" })

-- Visual 模式：y 和 Cmd+C 复制到系统剪贴板
vim.keymap.set("v", "y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("v", "Y", '"+Y', { desc = "Yank line to system clipboard" })
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to clipboard (Cmd+C)" })

-- 普通模式：y 复制到系统剪贴板
vim.keymap.set("n", "y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Visual 模式：粘贴（不覆盖剪贴板）
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without overwriting clipboard" })
vim.keymap.set("v", "<D-v>", '"+p', { desc = "Paste from clipboard (Cmd+V)" })

-- 普通和插入模式：Cmd+V 粘贴
vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste from clipboard (Cmd+V)" })
vim.keymap.set("i", "<D-v>", '<C-r>+', { desc = "Paste from clipboard (Cmd+V)" })
vim.keymap.set("c", "<D-v>", '<C-r>+', { desc = "Paste from clipboard in cmdline (Cmd+V)" })

-- 普通模式：p 从系统剪贴板粘贴
vim.keymap.set("n", "p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("n", "P", '"+P', { desc = "Paste before from system clipboard" })

-- 删除到黑洞寄存器，不影响剪贴板
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete without yank" })
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete char without yank" })
vim.keymap.set({ "n", "v" }, "c", '"_c', { desc = "Change without yank" })
