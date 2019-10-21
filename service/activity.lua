local skynet = require "skynet"

skynet.start(function() 
    skynet.newservice("three_remove")
    skynet.newservice("simpleweb")
end)