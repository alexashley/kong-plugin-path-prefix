local lunajson = require 'lunajson'
local http_request = require 'http.request'

local _Module = {}

local kong_url = os.getenv("KONG_API_URL") or "http://localhost:8001"

local function post(path, payload)
    local request = http_request.new_from_uri(kong_url .. path)
    request.headers:upsert("Accept", "application/json")
    request.headers:upsert("Content-Type", "application/json")
    request.headers:upsert(":method", "POST")
    request:set_body(lunajson.encode(payload))
    local headers, stream, err = request:go()
    local body = stream:get_body_as_string()
    if headers:get(":status") ~= "201" then
        return "Kong error: " .. body
    end

    return nil, lunajson.decode(body)
end

local function delete(path)
    local request = http_request.new_from_uri(kong_url .. path)
    request.headers:upsert(":method", "DELETE")
    local headers, stream = request:go()

    local body = stream:get_body_as_string()
    if headers:get(":status") ~= "204" then
        return "Kong error: " .. body
    end
end

function _Module.create_service(service_name, service_url)
    local payload = {
        ["name"] = service_name,
        ["url"] = service_url
    }
    return post("/services", payload)
end

function _Module.delete_service(service_id)
    return delete("/services/" .. service_id)
end

function _Module.delete_route(route_id)
    return delete("/routes/" .. route_id)
end

function _Module.create_route(service_id, path, strip_path)
    local payload = {
        ["paths"] = { path },
        ["strip_path"] = strip_path,
        ["service"] = {
            ["id"] = service_id
        }
    }
    return post("/routes", payload)
end

function _Module.create_plugin(name, config, service_id, route_id)
    local payload = {
        ["name"] = name,
        ["config"] = config
    }

    if service_id then
        payload["service_id"] = service_id
    end

    if route_id then
        payload["route_id"] = route_id
    end

    return post("/plugins", payload)
end

return _Module