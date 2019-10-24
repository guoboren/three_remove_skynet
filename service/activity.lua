local skynet = require "skynet"

skynet.start(function() 
    -- skynet.newservice("three_remove")
    skynet.newservice("three_remove2")
    skynet.newservice("simpleweb")
end)