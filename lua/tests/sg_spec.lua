require("plenary.async").tests.add_to_env()
local eq = assert.are.same

local rpc = require "sg.rpc"

describe("sg-agent", function()
  a.it("can send echo request", function()
    local echoed = rpc.echo "hello"
    eq("hello", echoed)
  end)
end)