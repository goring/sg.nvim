---@tag sg.commands

---@brief [[
--- Default commands for interacting with Sourcegraph
---@brief ]]

local bufread = require "sg.bufread"

-- TODO: I don't know how to turn off this https://* stuff and not make netrw users mad
pcall(vim.api.nvim_clear_autocmds, {
  group = "Network",
  event = "BufReadCmd",
  pattern = "https://*",
})

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("sourcegraph-bufread", { clear = true }),
  pattern = { "sg://*", "https://sourcegraph.com/*" },
  callback = function()
    bufread.edit(vim.fn.expand "<amatch>")
  end,
  desc = "Sourcegraph link and protocol handler",
})

vim.api.nvim_create_user_command("SourcegraphInfo", function()
  print "Attempting to get sourcegraph info..."

  -- TODO: Would be nice to get the version of the plugin
  local info = require("sg.lib").get_info()
  local contents = vim.split(vim.inspect(info), "\n")

  table.insert(contents, 1, "Sourcegraph info:")

  vim.cmd.vnew()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, contents)

  vim.schedule(function()
    print "... got sourcegraph info"
  end)
end, {})

---@command SourcegraphLink [[
--- Get a sourcegraph link to the current repo + file + line.
--- Automatically adds it to your '+' register
---@command ]]
vim.api.nvim_create_user_command("SourcegraphLink", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ok, link = pcall(require("sg.lib").get_link, vim.api.nvim_buf_get_name(0), cursor[1], cursor[2] + 1)
  if not ok then
    print("Failed to get link:", link)
    return
  end

  print("Setting '+' register to:", link)
  vim.fn.setreg("+", link)
end, {
  desc = "Get a sourcegraph link to the current location",
})

---@command SourcegraphSearch [[
--- Run a search. For more sourcegraph search syntax, refer to online documentation
---@command ]]
vim.api.nvim_create_user_command("SourcegraphSearch", function(args)
  local input = nil
  if args.args and #args.args > 0 then
    input = args.args
  end

  require("sg.extensions.telescope").fuzzy_search_results { input = input }
end, {
  desc = "Run a search on your connected Sourcegraph instance",
})

---@command SourcegraphLogin [[
--- Get prompted for endpoint and access_token if you don't
--- want to set them via environment variables.
---@command ]]
vim.api.nvim_create_user_command("SourcegraphLogin", function()
  local env = require "sg.env"

  -- TODO: Maybe this is bad hack?...
  vim.env.SRC_ENDPOINT = nil
  vim.env.SRC_ACCESS_TOKEN = nil

  env.endpoint(true)
  env.token(true)
end, {
  desc = "Login and store credentials for later use (an alternative to the environment variables",
})
