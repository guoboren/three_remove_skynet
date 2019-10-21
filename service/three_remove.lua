local skynet = require "skynet"
local cjson = require "cjson"
local cjson2 = cjson.new()
cjson2.encode_sparse_array(true)
require "functions"
require "errorCode"
require "skynet.manager"
local trCtrl = require "three_remove.three_remove_ctrl"

local CMD = {}

local panes = {}

function CMD.getConfig()
    return trCtrl.getConfig()
end

function CMD.initPane(roleId)
    if panes[roleId] then
        return SystemError.success, panes[roleId]
    end
    local pane = trCtrl.initPane(roleId)
    panes[roleId] = pane
    return SystemError.success, pane
end

function CMD.doExchange(roleId, exchange)
    local p1 = exchange[1]
    local p2 = exchange[2]
    local pane = panes[roleId]
    assert(pane)
    assert(pane[p1.x + 1][p1.y + 1] == p1.id)
    assert(pane[p2.x + 1][p2.y + 1] == p2.id)
    pane[p1.x + 1][p1.y + 1] = p2.id
    pane[p2.x + 1][p2.y + 1] = p1.id
    return SystemError.success
end

function CMD.exit(roleId)
    print(roleId)
    if panes[roleId] == nil then
        return SystemError.notExist
    end
    panes[roleId] = nil
    return SystemError.success
end  

skynet.start(function()
    skynet.dispatch("lua", function(_, _, method, ...)
        print(method)
        assert(method ~= nil)
        local func = CMD[method]
        assert(func)
        return skynet.ret(skynet.pack(func(...)))
    end)
    skynet.register(SERVICE.THREE_REMOVE)
end)