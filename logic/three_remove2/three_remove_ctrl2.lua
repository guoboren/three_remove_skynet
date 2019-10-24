local threeRemoveConfig = require "config.three_remove_config"
require "functions"
require "errorCode"
local cjson = require "cjson"
local cjson2 = cjson.new()

local ROWS = threeRemoveConfig.rows
local COLS = threeRemoveConfig.cols

local threeRemoveCtrl = {}

local function _getRandomId()
    return math.random(0, #threeRemoveConfig.config - 1)
end

function threeRemoveCtrl.printPane(pane)
    print("---------------------------------------------------------------------------------------------------------------")
    for i = 1, 10 do
        print(string.format("|          |          |          |          |          |          |          |          |          |          |"))
        print(string.format("|  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |  %2d, %2d  |", 
                  pane[i][1].id, pane[i][1].status,
                  pane[i][2].id, pane[i][2].status,
                  pane[i][3].id, pane[i][3].status,
                  pane[i][4].id, pane[i][4].status,
                  pane[i][5].id, pane[i][5].status,
                  pane[i][6].id, pane[i][6].status,
                  pane[i][7].id, pane[i][7].status,
                  pane[i][8].id, pane[i][8].status,
                  pane[i][9].id, pane[i][9].status,
                  pane[i][10].id, pane[i][10].status))
        print(string.format("|          |          |          |          |          |          |          |          |          |          |"))
        print("---------------------------------------------------------------------------------------------------------------")
    end
end


function threeRemoveCtrl.initPane()
    local pane = {}
    local i = 1
    local j = 1
    while i <= COLS do
        pane[i] = {}
        while j <= ROWS do
            pane[i][j] = {
                id = -1,
                x = i,
                y = j,
                status = GRID_ITEM_STATUS.NOT_INIT
            }
            j = j + 1
        end
        j = 1
        i = i + 1
    end
    i = 1
    j = 1
    while i <= COLS do
        while j <= ROWS do
            local id = _getRandomId()
            if pane[i-2] and pane[i-2][j].id == id and pane[i-1] and pane[i-1][j].id == id or 
               pane[i][j-2] and pane[i][j-2].id == id and pane[i][j-1] and pane[i][j-1].id == id
            then
                j = j - 1
            else
                pane[i][j].id = id
                pane[i][j].status = GRID_ITEM_STATUS.NORMAL
            end
            j = j + 1
        end
        j = 1
        i = i + 1
    end
    return pane
end

function _swap(to, from, pane)
    local pane = pane
    local p1 = pane[to.x][to.y]
    local p2 = pane[from.x][from.y]
    local id = p1.id
    local status = p1.status
    p1.id = p2.id
    p1.status = p2.status
    p2.id = id
    p2.status = status
end

function PRINT(pane)
    threeRemoveCtrl.printPane(pane)
end

function _getVertiRemoves(removes, des, pane)
    local list = {}
    local res = 0
    local x = des.x
    local y = des.y
    local index = 1
    local id = pane[x][y].id
    while x - index > 0 do
        if id == pane[x - index][y].id then
            table.insert(list, {
                x = x - index,
                y = y
            })
            res = res + 1
        else
            break
        end
        index = index + 1
    end
    index = 1
    while x + index <= ROWS do
        if id == pane[x + index][y].id then
            table.insert(list, {
                x = x + index,
                y = y
            })
            res = res + 1
        else
            break
        end
        index = index + 1
    end
    if res < 2 then
        list = {}
    end
    return list
end

function _getHorizRemoves(removes, des, pane)
    local res = 0
    local list = {}
    local x = des.x
    local y = des.y
    local index = 1
    local id = pane[x][y].id
    while y - index > 0 do
        if id == pane[x][y - index].id then
            table.insert(list, {
                x = x,
                y = y - index
            })
            res = res + 1
        else
            break
        end
        index = index + 1
    end
    index = 1
    while y + index <= COLS do
        if id == pane[x][y + index].id then
            table.insert(list, {
                x = x,
                y = y + index
            })
            res = res + 1
        else
            break
        end
        index = index + 1
    end
    if res < 2 then
        list = {}
    end
    return list
end

function _listHasPoint(p, src)
    for _, v in pairs(src) do
        if v.x == p.x and v.y == p.y then
            return true
        end
    end
    return false
end

function _addListToList(des, src)
    for _, p in pairs(des) do
        if not _listHasPoint(p, src) then
            table.insert(src, p)
        end
    end
end

function _addPointToList(p, src)
    if not _listHasPoint(p, src) then
        table.insert(src, p)
    end
end

function _getPointsRemoves(removes, des, pane)
    local hRemoves = _getHorizRemoves(removes, des, pane)
    local vRemoves = _getVertiRemoves(removes, des, pane)
    -- print(string.format("x:%2d, y:%2d, h:%2d, v:%2d", des.x, des.y, table.length(hRemoves), table.length(vRemoves)))
    if table.length(hRemoves) >= 2 or table.length(vRemoves) >= 2 then
        _addListToList(hRemoves, removes)
        _addListToList(vRemoves, removes)
        _addPointToList(des, removes)
    end
end

function _resetAllStatus(pane, status)
    for i = 1, ROWS do
        for j = 1, COLS do
            pane[i][j].status = status
        end
    end
end

function _setStatusByList(list, pane, status)
    for _, p in pairs(list) do
        pane[p.x][p.y].status = status
    end
end

function _removePoints(pane)
    for i = 1, ROWS do
        for j = 1, COLS do
            if pane[i][j].status == GRID_ITEM_STATUS.READY_TO_REMOVE then
                pane[i][j].status = GRID_ITEM_STATUS.REMOVED
            end
        end
    end
end

function _getValidId(pos, pane)
    local x = pos.x
    local y = pos.y
    local time = os.time()
    while true do
        if os.time() - time > 1 then
            return -1
        end
        local id = _getRandomId()
        if x - 2 > 0 and pane[x - 2][y].id ~= id and pane[x - 1][y].id ~= id and 
           x + 2 <= ROWS and pane[x + 2][y].id ~= id and pane[x + 1][y].id ~= id and
           y - 2 > 0 and pane[x][y - 2].id ~= id and pane[x][y - 1].id ~= id and 
           y + 2 <= COLS and pane[x][y + 2].id ~= id and pane[x][y + 1].id ~= id
        then
            return id
        end
    end
end

function _getNewPoints(pane, news)
    local x = 1
    local y = 1
    while x <= ROWS do
        while y <= COLS do
            if pane[x][y].status == GRID_ITEM_STATUS.REMOVED then
                local id = _getRandomId()
                if x - 2 > 0 and pane[x - 2][y].id == id and pane[x - 1][y].id == id or 
                   x + 2 <= ROWS and pane[x + 2][y].id == id and pane[x + 1][y].id == id or
                   y - 2 > 0 and pane[x][y - 2].id == id and pane[x][y - 1].id == id or 
                   y + 2 <= COLS and pane[x][y + 2].id == id and pane[x][y + 1].id == id or
                   x - 1 > 0 and pane[x - 1][y].id == id and x + 1 <= COLS and pane[x + 1][y].id == id or
                   y - 1 > 0 and pane[x][y - 1].id == id and y + 1 <= ROWS and pane[x][y + 1].id == id
                then
                    y = y - 1
                else
                    pane[x][y].id = id
                    pane[x][y].status = GRID_ITEM_STATUS.NORMAL
                    table.insert(news, pane[x][y])
                end
            end
            y = y + 1
        end
        y = 1
        x = x + 1
    end
end

function _downToBottom(pane)
    for j = 1, COLS do
        local des = {x = -1, y = -1}
        for i = ROWS, 1, -1 do
            if des.x > 0 and des.y > 0 then
                _swap(des, {x = i, y = j}, pane)
                des.x = des.x - 1
                des.y = j
            elseif pane[i][j].status == GRID_ITEM_STATUS.REMOVED then
                des.x = i
                des.y = j
            end
        end
    end
end

function threeRemoveCtrl.doRemove(pane, exchange)
    local p1 = exchange[1]
    local p2 = exchange[2]
    local painting = {
        
    }
    local removes = {}
    local news = {}
    if p1.x ~= p2.x and p1.y ~= p2.y or
       p1.x == p2.x and math.abs(p1.y - p2.y) > 1 or
       p1.y == p2.y and math.abs(p1.x - p2.x) > 1
    then
        return painting
    end
    _swap(p1, p2, pane)

    repeat
        removes = {}
        news = {}
        local one = {}
        -- 获取要删除的坐标
        for i = 1, ROWS do
            for j = 1, COLS do
                _getPointsRemoves(removes, {x = i, y = j}, pane)
            end
        end
        if table.length(removes) == 0 then
            break
        end
        -- 设置坐标状态
        _setStatusByList(removes, pane, GRID_ITEM_STATUS.READY_TO_REMOVE)
        -- 删除坐标点
        _removePoints(pane)
        one.removes = removes
        -- 下沉
        _downToBottom(pane)
        -- 获取新生点
        _getNewPoints(pane, news)
        one.news = news
        one.pane = pane
        table.insert(painting, one)
    until(table.length(removes) == 0)
    return painting
end

function threeRemoveCtrl.getConfig()
    return SystemError.success, {config = threeRemoveConfig.data, status = threeRemoveConfig.status, rows = ROWS, cols = COLS}
end

return threeRemoveCtrl