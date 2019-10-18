local threeRemoveConfig = require "config.three_remove_config"
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
    return math.random(0, #threeRemoveConfig.config)
end

function threeRemoveCtrl.initPane(username, password)
    local pane = {}
    for i=1, PANE_WIDTH do
        pane[i] = {}
        for j=1, PANE_HEIGHT do
            local id = getRandomId()
            if (i-2 >= 1 and pane[i-2][j] ~= id) and 
                (i-1 >= 1 and pane[i-1][j] ~= id) then
                pane[i][j] = 
            end
        end
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