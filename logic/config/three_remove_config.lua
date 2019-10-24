local threeRemove = require "config.three_remove"

local config = {
    total = 0,
    data = {},
    config = {},
    status = {},
    rows = 10,
    cols = 10
}

GRID_ITEM_STATUS = {
    NORMAL = 0,
    READY_TO_REMOVE = 1,
    REMOVED = 2,
    NOT_INIT = 3
}

for k, v in pairs(threeRemove) do
    config.total = config.total + v.weight
    config.data[k] = {
        id = v.id,
        score = v.score,
        color = v.color
    }
    config.config[k] = v
end

config.status = GRID_ITEM_STATUS

return config

