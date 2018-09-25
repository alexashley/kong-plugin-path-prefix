local plugin = require("kong.plugins.base_plugin"):extend()

function plugin:new()
    plugin.super.new(self, "path-prefix")
end

local function escape_hyphen()
    local conf = kong.ctx.plugin.conf
    local path_prefix = conf.path_prefix
    local should_escape = conf.escape

    if should_escape then
        return string.gsub(path_prefix, "%-", "%%%1")
    end

    return path_prefix
end

local function get_service_for_plugin()
    local conf = kong.ctx.plugin.conf
    local service
    local err

    local service_id = conf.service_id

    if not service_id and conf.route_id then
        local route, err = kong.db.routes:select({ id = conf.route_id })
        if err then
            return nil, err
        end

        service_id = route.service_id
    end

    if not service_id then
        return nil, "Unable to determine associated service"
    end

    return kong.db.services:select({ id = conf.service_id })
end

function plugin:access(plugin_conf)
    plugin.super.access(self)
    kong.ctx.plugin.conf = plugin_conf

    local service, err = get_service_for_plugin()

    if err then
        kong.log.err("Unable to determine service for plugin " .. err)
        return kong.response.exit(500, "Internal server error")
    end

    -- ideally this plugin wouldn't need to do lookup the service's path,
    -- but the path returned by kong.request.get_path() doesn't include it
    -- and using kong.service.request.set_path will overwrite it (under the hood, get_path and set_path refer to different nginx vars).
    -- more here: https://discuss.konghq.com/t/pdk-path-related-function-relative-to-router-matches-and-service-path/1329
    local service_path = service.path or ""

    local full_path = kong.request.get_path()
    local replace_match = escape_hyphen()
    local path_without_prefix = full_path:gsub(replace_match, "", 1)

    if path_without_prefix == "" and service_path == "" then
        path_without_prefix = "/"
    end

    local new_path = path_without_prefix
    kong.log("rewriting ", full_path, " to ", path_without_prefix)
    if service_path ~= "" then
        kong.log("Prefixing request with service path ", service_path)
        new_path = service_path .. new_path
    end
    kong.service.request.set_path(new_path)
end

plugin.PRIORITY = 800

return plugin
