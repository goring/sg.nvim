local shared = require "sg.components.shared"

---@class CodyHistoryOptions
---@field split string?
---@field height number|string
---@field width number|string
---@field row number|string
---@field col number|string
---@field filetype string?
---@field title string?
---@field title_pos string?

---@class CodyHistory
---@field opts CodyHistoryOptions
---@field popup_options table
---@field bufnr number
---@field win number
---@field mounted boolean
---@field filetype string?
local CodyHistory = {}
CodyHistory.__index = CodyHistory

--- Create a new CodyHistory
---@param opts CodyHistoryOptions
---@return CodyHistory
function CodyHistory.init(opts)
  local popup_options = {
    relative = "editor",
    width = shared.calculate_width(opts.width),
    height = shared.calculate_height(opts.height),
    row = shared.calculate_row(opts.row),
    col = shared.calculate_col(opts.col),
    style = "minimal",
    border = "rounded",
    title = opts.title or " Cody History ",
    title_pos = opts.title_pos or "center",
  }

  return setmetatable({
    opts = opts,
    popup_options = popup_options,
    bufnr = -1,
    win = -1,
    mounted = false,
    filetype = opts.filetype or "markdown",
  }, CodyHistory)
end

function CodyHistory:mount(listed)
  if self.opts.split then
    -- TODO: I don't remember how to do this
    vim.cmd [[botright vnew]]
    self.win = vim.api.nvim_get_current_win()
    self.bufnr = vim.api.nvim_get_current_buf()
  else
    self.bufnr, self.win = shared.create(self.bufnr, self.win, listed, self.popup_options)
  end

  vim.bo[self.bufnr].filetype = self.filetype
end

function CodyHistory:unmount()
  self:hide()
  self.bufnr = shared.buf_del(self.bufnr)
end

function CodyHistory:hide()
  self.win = shared.win_del(self.win)
end

return CodyHistory
