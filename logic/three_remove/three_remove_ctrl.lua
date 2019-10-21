local threeRemoveConfig = require "config.three_remove_config"
require "functions"
require "errorCode"
local cjson = require "cjson"
local cjson2 = cjson.new()

local threeRemoveCtrl = {}
local PANE_WIDTH = 10
local PANE_HEIGHT = 10

local function getRandomId()
    return math.random(0, #threeRemoveConfig.config - 1)
end

function threeRemoveCtrl.initPane(roleId)
    local pane = {}
    local i = 1
    local j = 1
    while i <= PANE_WIDTH do
        pane[i] = {}
        while j <= PANE_HEIGHT do
            local id = getRandomId()
            if (i-2 >= 1 and pane[i-2] ~= nil and pane[i-2][j] == id) and (i-1 >= 1 and pane[i-1] ~= nil and pane[i-1][j] == id) or 
                (j-2 >= 1 and pane[i][j-2] == id) and (j-1 >= 1 and pane[i][j-1] == id) then
                j = j - 1
            else
                pane[i][j] = id
            end
            j = j + 1
        end
        j = 1
        i = i + 1
    end
    return pane
end

function threeRemoveCtrl.getConfig()
    return SystemError.success, threeRemoveConfig.data
end

function threeRemoveCtrl.doExchange(roleId, exchange)
    local p1 = exchange[1]
    local p2 = exchange[2]
    return SystemError.success
end

return threeRemoveCtrl