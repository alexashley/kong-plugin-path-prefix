local http_request = require 'http.request'
local lunajson = require 'lunajson'

local _Module = {}

function _Module.get(url)
    local request = http_request.new_from_uri(url)
    request.headers:upsert("Accept", "application/json")
    request.headers:upsert(":method", "GET")

    local headers, stream, err = request:go()

    local body = stream:get_body_as_string()
    if headers:get(":status") ~= "200" then
        return "Request error: " .. body
    end

    return lunajson.decode(body)
end

return _Module