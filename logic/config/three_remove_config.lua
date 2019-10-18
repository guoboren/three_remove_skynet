local threeRemove = require "config.three_remove"

local config = {
    total = 0,
    data = {},
    config = {}
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

return config

