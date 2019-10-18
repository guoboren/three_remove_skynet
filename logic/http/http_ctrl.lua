local skynet = require "skynet"

local httpModule = {
    ['three-remove'] = require "three_remove.three_remove_ctrl"
}

local httpCtrl = {}

function httpCtrl.doCmd(module, method, ...)
    local mod = httpModule[module]
    if mod == nil then
        local tmp = {}
        tmp.data = {}
        tmp.errorCode = 3
        return tmp
    end
    local func = mod[method]
    return func(...)
end

return httpCtrl