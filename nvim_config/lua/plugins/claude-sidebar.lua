-- Claude Code 集成配置（使用原生 Neovim 终端，不依赖 toggleterm 高级功能）
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = false,
    config = function()
      -- 基础配置（只用于其他终端）
      require("toggleterm").setup({
        direction = "horizontal",
        open_mapping = [[<c-\>]],
      })

      -- 使用原生 Neovim 终端管理 Claude
      local claude_buf = nil
      local claude_win = nil

      -- 检查 Claude 是否打开
      local function is_claude_open()
        if claude_win and vim.api.nvim_win_is_valid(claude_win) then
          return true
        end
        return false
      end

      -- 清理无效的引用
      local function cleanup_refs()
        if claude_win and not vim.api.nvim_win_is_valid(claude_win) then
          claude_win = nil
        end
        if claude_buf and not vim.api.nvim_buf_is_valid(claude_buf) then
          claude_buf = nil
        end
      end

      -- 切换 Claude
      vim.api.nvim_create_user_command("ClaudeToggle", function()
        cleanup_refs()

        if is_claude_open() then
          -- 关闭窗口
          vim.api.nvim_win_close(claude_win, false)
          claude_win = nil
        else
          -- 创建或重用 buffer
          if not claude_buf or not vim.api.nvim_buf_is_valid(claude_buf) then
            claude_buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_option(claude_buf, "bufhidden", "hide")
          end

          -- 创建垂直分割窗口
          vim.cmd("vsplit")
          claude_win = vim.api.nvim_get_current_win()

          -- 移到最右边
          vim.cmd("wincmd L")

          -- 设置宽度 (30%)
          local width = math.floor(vim.o.columns * 0.3)
          vim.api.nvim_win_set_width(claude_win, width)

          -- 设置 buffer
          vim.api.nvim_win_set_buf(claude_win, claude_buf)

          -- 设置窗口选项
          vim.api.nvim_win_set_option(claude_win, "number", false)
          vim.api.nvim_win_set_option(claude_win, "relativenumber", false)
          vim.api.nvim_win_set_option(claude_win, "signcolumn", "no")

          -- 启动终端（只在新 buffer 时）
          local existing_terminal = vim.api.nvim_buf_get_option(claude_buf, "buftype") == "terminal"
          if not existing_terminal then
            vim.fn.termopen("ccr code", {
              on_exit = function()
                vim.notify("Claude Code exited", vim.log.levels.INFO)
              end,
            })
          end

          -- 设置快捷键
          local opts = { buffer = claude_buf, noremap = true, silent = true }
          vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
          vim.keymap.set("n", "q", "<cmd>ClaudeToggle<cr>", opts)

          -- 粘贴支持（多种方式）
          -- Ctrl+Shift+V - 从系统剪贴板粘贴
          vim.keymap.set("t", "<C-S-v>", function()
            local content = vim.fn.getreg("+")
            vim.api.nvim_feedkeys(content, "t", false)
          end, opts)

          -- Ctrl+V - 从系统剪贴板粘贴（备选）
          vim.keymap.set("t", "<C-v>", function()
            local content = vim.fn.getreg("+")
            vim.api.nvim_feedkeys(content, "t", false)
          end, opts)

          -- Cmd+V - macOS 系统粘贴（如果终端支持）
          vim.keymap.set("t", "<D-v>", function()
            local content = vim.fn.getreg("+")
            vim.api.nvim_feedkeys(content, "t", false)
          end, opts)

          -- 进入插入模式
          vim.cmd("startinsert")

          -- 修复布局
          vim.defer_fn(function()
            local ok, layout_helper = pcall(require, "claude-layout-helper")
            if ok then
              layout_helper.fix_layout()
            end
          end, 100)
        end
      end, {})

      -- 聚焦 Claude
      vim.api.nvim_create_user_command("ClaudeFocus", function()
        cleanup_refs()
        if is_claude_open() then
          vim.api.nvim_set_current_win(claude_win)
          vim.cmd("startinsert")
        else
          vim.notify("Claude is not open", vim.log.levels.WARN)
        end
      end, {})

      -- 关闭 Claude
      vim.api.nvim_create_user_command("ClaudeClose", function()
        cleanup_refs()
        if is_claude_open() then
          vim.api.nvim_win_close(claude_win, false)
          claude_win = nil
        end
      end, {})

      -- 重启 Claude
      vim.api.nvim_create_user_command("ClaudeRestart", function()
        -- 关闭窗口和 buffer
        if is_claude_open() then
          vim.api.nvim_win_close(claude_win, false)
        end
        if claude_buf and vim.api.nvim_buf_is_valid(claude_buf) then
          vim.api.nvim_buf_delete(claude_buf, { force = true })
        end
        claude_win = nil
        claude_buf = nil

        -- 重新打开
        vim.defer_fn(function()
          vim.cmd("ClaudeToggle")
        end, 100)
      end, {})

      -- 发送文件路径
      vim.api.nvim_create_user_command("ClaudeSendFile", function()
        local filepath = vim.fn.expand("%:p")
        if filepath == "" then
          vim.notify("No file in current buffer", vim.log.levels.WARN)
          return
        end
        vim.fn.setreg("+", filepath)

        cleanup_refs()
        if not is_claude_open() then
          vim.cmd("ClaudeToggle")
          vim.defer_fn(function()
            vim.notify("File path copied. Paste into Claude with Cmd+V", vim.log.levels.INFO)
          end, 500)
        else
          vim.cmd("ClaudeFocus")
          vim.notify("File path copied. Paste with Cmd+V", vim.log.levels.INFO)
        end
      end, {})

      -- 设置快捷键
      vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeToggle<cr>", { desc = "Toggle Claude Sidebar" })
      vim.keymap.set("n", "<leader>af", "<cmd>ClaudeFocus<cr>", { desc = "Focus Claude" })
      vim.keymap.set("n", "<leader>aF", "<cmd>ClaudeSendFile<cr>", { desc = "Send File to Claude" })
      vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeRestart<cr>", { desc = "Restart Claude" })
      vim.keymap.set("n", "<leader>aq", "<cmd>ClaudeClose<cr>", { desc = "Close Claude" })

      -- 发送选中内容
      vim.keymap.set("v", "<leader>as", function()
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local lines = vim.fn.getline(start_pos[2], end_pos[2])

        if #lines == 0 then
          vim.notify("No selection", vim.log.levels.WARN)
          return
        end

        if #lines == 1 then
          lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
        else
          lines[1] = string.sub(lines[1], start_pos[3])
          lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
        end

        local selected_text = table.concat(lines, "\n")
        vim.fn.setreg("+", selected_text)

        cleanup_refs()
        if not is_claude_open() then
          vim.cmd("ClaudeToggle")
          vim.defer_fn(function()
            vim.notify("Selection copied. Paste into Claude with Cmd+V", vim.log.levels.INFO)
          end, 500)
        else
          vim.cmd("ClaudeFocus")
          vim.notify("Selection copied. Paste with Cmd+V", vim.log.levels.INFO)
        end
      end, { desc = "Send Selection to Claude" })

      -- 修复布局
      vim.keymap.set("n", "<leader>al", function()
        local ok, layout_helper = pcall(require, "claude-layout-helper")
        if ok then
          layout_helper.fix_layout()
          vim.notify("Layout fixed!", vim.log.levels.INFO)
        end
      end, { desc = "Fix Sidebar Layout" })
    end,
  },
}
