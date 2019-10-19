local threeRemoveConfig = require "config.three_remove_config"
require "functions"

local threeRemoveCtrl = {}
local PANE_WIDTH = 10
local PANE_HEIGHT = 10
--[[

    返回格式统一为
    {
        errorCode: ...,
        data: {}
    }

]]

local function getRandomId()
    -- local num = math.random(0, threeRemoveConfig.total)
    -- local result = -1
    -- for _, v in pairs(threeRemoveConfig.config) do
    --     if num >= v.weight then
    --         result = v.id
    --         break
    --     end
    -- end
    -- return result
    return math.random(0, #threeRemoveConfig.config - 1)
end

function threeRemoveCtrl.initPane(username, password)
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
    return {
        errorCode = 0, 
        data = pane
    }
end

function threeRemoveCtrl.getConfig()
    return {
        errorCode = 0, 
        data = threeRemoveConfig.data
    }
end

return threeRemoveCtrl