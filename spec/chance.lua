local os = require('os')
local math = require('math')

math.randomseed(os.time())

local _Module = {}

function _Module.string(prefix)
    if not prefix then
        prefix = ""
    end

    return prefix .. "-" .. tostring(math.random(1, 100))
end


return _Module