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

local function _getLeftRemove(p, pane)
    local result = {}
    local x = p.x - 1
    local y = p.y
    local id = p.id
    while x > 0 do
        if pane[x][y] == id then
            table.insert(result, {
                id = id,
                x = x,
                y = y
            })
        else
            break
        end
        x = x - 1
    end
    return result
end

local function _getTopRemove(p, pane)
    local result = {}
    local x = p.x
    local y = p.y - 1
    local id = p.id
    while y > 0 do
        if pane[x][y] == id then
            table.insert(result, {
                id = id,
                x = x,
                y = y
            })
        else
            break
        end
        y = y - 1
    end
    return result
end

local function _getRightRemove(p, pane)
    local result = {}
    local x = p.x + 1
    local y = p.y
    local id = p.id
    while x <= PANE_WIDTH do
        if pane[x][y] == id then
            table.insert(result, {
                id = id,
                x = x,
                y = y
            })
        else
            break
        end
        x = x + 1
    end
    return result
end

local function _getBottomRemove(p, pane)
    local result = {}
    local x = p.x
    local y = p.y + 1
    local id = p.id
    while y <= PANE_HEIGHT do
        if pane[x][y] == id then
            table.insert(result, {
                id = id,
                x = x,
                y = y
            })
        else
            break
        end
        y = y + 1
    end
    return result
end

function threeRemoveCtrl.doExchange(p1, p2, pane)
    local result = {}
    print(00)
    if p1.x == p2.x then -- 纵向交换
        if p1.y > p2.y then -- p2在上
            print(11)
            table.mergeNumberArray(result, _getLeftRemove(p2, pane))
            table.mergeNumberArray(result, _getTopRemove(p2, pane))
            table.mergeNumberArray(result, _getRightRemove(p2, pane))
            table.mergeNumberArray(result, _getLeftRemove(p1, pane))
            table.mergeNumberArray(result, _getBottomRemove(p1, pane))
            table.mergeNumberArray(result, _getRightRemove(p1, pane))
        else -- p1在上
            print(22)
            table.mergeNumberArray(result, _getLeftRemove(p1, pane))
            table.mergeNumberArray(result, _getTopRemove(p1, pane))
            table.mergeNumberArray(result, _getRightRemove(p1, pane))
            table.mergeNumberArray(result, _getLeftRemove(p2, pane))
            table.mergeNumberArray(result, _getBottomRemove(p2, pane))
            table.mergeNumberArray(result, _getRightRemove(p2, pane))
        end
    else -- 横向交换
        if p1.x > p2.x then -- p2在左
            print(33)
            table.mergeNumberArray(result, _getLeftRemove(p2, pane))
            table.mergeNumberArray(result, _getTopRemove(p2, pane))
            table.mergeNumberArray(result, _getBottomRemove(p2, pane))
            table.mergeNumberArray(result, _getRightRemove(p1, pane))
            table.mergeNumberArray(result, _getTopRemove(p1, pane))
            table.mergeNumberArray(result, _getBottomRemove(p1, pane))
        else -- p1在左
            print(44)
            table.mergeNumberArray(result, _getLeftRemove(p1, pane))
            table.mergeNumberArray(result, _getTopRemove(p1, pane))
            table.mergeNumberArray(result, _getBottomRemove(p1, pane))
            table.mergeNumberArray(result, _getRightRemove(p2, pane))
            table.mergeNumberArray(result, _getTopRemove(p2, pane))
            table.mergeNumberArray(result, _getBottomRemove(p2, pane))
        end
    end
    pane[p1.x][p1.y] = p2.id
    pane[p2.x][p2.y] = p1.id
    return result
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