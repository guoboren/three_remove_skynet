local skynet = require "skynet"
require "errorCode"

local httpModule = {
    ['three-remove'] = SERVICE.THREE_REMOVE
}

local httpCtrl = {}

function httpCtrl.doCmd(module, method, ...)
    local mod = httpModule[module]
    if mod == nil then
        return SystemError.notExist
    end
    return skynet.call(mod, "lua", method, ...)
end

return httpCtrl