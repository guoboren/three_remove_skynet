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

function threeRemoveCtrl.printPane(pane)
    for i = 1, PANE_WIDTH do
        local str = string.format("%2d %2d %2d %2d %2d %2d %2d %2d %2d %2d\n", 
                  pane[i][1],
                  pane[i][2], 
                  pane[i][3], 
                  pane[i][4], 
                  pane[i][5], 
                  pane[i][6], 
                  pane[i][7], 
                  pane[i][8], 
                  pane[i][9], 
                  pane[i][10])
        print(str)
    end
end

function _canFill(p, pane)
    if p.x - 2 > 0 and pane[p.x - 2][p.y] == p.id and pane[p.x - 1][p.y] == p.id or
       p.x + 2 <= PANE_HEIGHT and pane[p.x + 2][p.y] == p.id and pane[p.x + 1][p.y] == p.id or
       p.x - 1 > 0 and pane[p.x - 1][p.y] == p.id and p.x + 1 <= PANE_HEIGHT and pane[p.x + 1][p.y] == p.id or
       p.y - 2 > 0 and pane[p.x][p.y - 2] == p.id and pane[p.x][p.y - 1] == p.id or
       p.y + 2 <= PANE_WIDTH and pane[p.x][p.y + 2] == p.id and pane[p.x][p.y + 1] == p.id or
       p.y - 1 > 0 and pane[p.x][p.y - 1] == p.id and p.y + 1 <= PANE_WIDTH and pane[p.x][p.y + 1] == p.id
    then
        return false
    end
    return true
end

function _fillNil(pane, removeRange)
    local fillPoints = {}
    local i = 1
    local j = removeRange.minY
    while i <= removeRange.maxX - removeRange.minX + 1 do
        while j <= removeRange.maxY do
            if pane[i][j] == -1 then
                local p = {
                    id = getRandomId(),
                    x = i,
                    y = j
                }
                if not _canFill(p, pane) then
                    j = j - 1
                else
                    pane[i][j] = p.id
                    table.insert(fillPoints, p)
                end
            end
            j = j + 1
        end
        j = 1
        i = i + 1
    end
    return fillPoints
end

function threeRemoveCtrl.initPane(roleId)
    local pane = {}
    local i = 1
    local j = 1
    while i <= PANE_HEIGHT do
        pane[i] = {}
        while j <= PANE_WIDTH do
            local id = getRandomId()
            if (i-2 >= 1 and pane[i-2] ~= nil and pane[i-2][j] == id) and (i-1 >= 1 and pane[i-1] ~= nil and pane[i-1][j] == id) or 
               (j-2 >= 1 and pane[i][j-2] == id) and (j-1 >= 1 and pane[i][j-1] == id) 
            then
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

local function _canRemove(p, pane)
    local sumVertical = 1
    local sumHorizontal = 1
    local id = p.id
    local x = p.x - 1
    local y = p.y
    while x > 0 do
        if pane[x][y] == id then
            sumVertical = sumVertical + 1
        else
            break
        end
        x = x - 1
    end
    y = p.y
    x = p.x + 1
    while x <= PANE_HEIGHT do
        if pane[x][y] == id then
            sumVertical = sumVertical + 1
        else
            break
        end
        x = x + 1
    end
    x = p.x
    y = p.y - 1
    while y > 0 do
        if pane[x][y] == id then
            sumHorizontal = sumHorizontal + 1
        else
            break
        end
        y = y - 1
    end
    x = p.x
    y = p.y + 1
    while y <= PANE_WIDTH do
        if pane[x][y] == id then
            sumHorizontal = sumHorizontal + 1
        else
            break
        end
        y = y + 1
    end
    return sumHorizontal, sumVertical
end

local function _getHorizontalRemove(p, pane)
    local result = {}
    table.insert(result, p)
    local x = p.x
    local y = p.y - 1
    local id = p.id
    -- 左
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
    -- 右
    y = p.y + 1
    while y <= PANE_WIDTH do
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

local function _getVerticalRemove(p, pane)
    local result = {}
    table.insert(result, p)
    local x = p.x - 1
    local y = p.y
    local id = p.id
    -- 上
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
    -- 下
    x = p.x + 1
    while x <= PANE_HEIGHT do
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

function _downMoveByPoint(p, pane)
    local x = p.x
    local y = p.y
    local id = p.id
    while x + 1 <= PANE_HEIGHT and pane[x + 1][y] == -1 do
        pane[x + 1][y] = id
        pane[x][y] = -1
        x = x + 1
    end
end

function _getRemoveRange(removes)
    local minX = PANE_HEIGHT + 1
    local minY = PANE_WIDTH + 1
    local maxX = 0
    local maxY = 0
    for _, v in pairs(removes) do
        if v.x < minX then
            minX = v.x
        end
    end
    for _, v in pairs(removes) do
        if v.y < minY then
            minY = v.y
        end
    end
    for _, v in pairs(removes) do
        if v.x > maxX then
            maxX = v.x
        end
    end
    for _, v in pairs(removes) do
        if v.y > maxY then
            maxY = v.y
        end
    end
    return minX, minY, maxX, maxY
end

function _updatePane(removes, pane)
    local minX, minY, maxX, maxY = _getRemoveRange(removes)
    for _, v in pairs(removes) do
        pane[v.x][v.y] = -1
    end
    for j = minY, maxY do
        for i = maxX, 2, -1 do
            if i - 1 >= 1 and pane[i - 1][j] ~= -1 then
                local p = {
                    id = pane[i - 1][j],
                    x = i - 1,
                    y = j
                }
                _downMoveByPoint(p, pane)
            end
        end
    end
    return {
        minX = minX,
        minY = minY, 
        maxY = maxY,
        maxX = maxX
    }
end

function _getLastLinePoints(left, right, removes)
    local result = {}
    local maxIndex = right - left + 1
    local margin = left - 1
    for i = 1, maxIndex do
        for _, v in pairs(removes) do
            if result[i] ~= nil then
                if result[i].x < v.x and result[i].y == v.y then
                    result[i] = v
                end
            else
                if v.y == i + margin then
                    result[i] = v
                end
            end
        end
    end
    return result
end

function threeRemoveCtrl.doRemove(p1, p2, pane)
    local result = {}
    local removes = {}

    if p1.y == p2.y and p1.x > p2.x or 
       p1.y == p2.y and p1.x < p2.x or 
       p1.x == p2.x and p1.y > p2.y or 
       p1.x == p2.x and p1.y < p2.y 
    then 
        local canHorizontal, canVertical = _canRemove(p1, pane)
        -- p1
        -- 如果可以水平方向消除
        if canHorizontal >= 3 then
            table.mergeNumberArray(removes, _getHorizontalRemove(p1, pane))
        end
         -- 如果可以垂直方向消除
        if canVertical >= 3 then
            table.mergeNumberArray(removes, _getVerticalRemove(p1, pane))
        end
        --p2
        canHorizontal, canVertical = _canRemove(p2, pane)
        -- 如果可以水平方向消除
        if canHorizontal >= 3 then
            table.mergeNumberArray(removes, _getHorizontalRemove(p2, pane))
        end
         -- 如果可以垂直方向消除
        if canVertical >= 3 then
            table.mergeNumberArray(removes, _getVerticalRemove(p2, pane))
        end
    end
    result.removes = nil
    result.isRemove = false
    result.removeRange = nil
    result.fillPoints = nil
    result.lastPoints = nil
    if #removes > 0 then
        result.removes = removes
        result.isRemove = true
        result.removeRange = _updatePane(removes, pane)
        result.lastPoints = _getLastLinePoints(result.removeRange.minY, result.removeRange.maxY, removes)
        result.fillPoints = _fillNil(pane, result.removeRange)
    end

    

    return result
end

function threeRemoveCtrl.getConfig()
    return SystemError.success, {config = threeRemoveConfig.data, width = PANE_WIDTH, height = PANE_HEIGHT}
end

function threeRemoveCtrl.doExchange(roleId, exchange)
    local p1 = exchange[1]
    local p2 = exchange[2]
    return SystemError.success
end

return threeRemoveCtrl