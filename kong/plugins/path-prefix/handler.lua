local plugin = require("kong.plugins.base_plugin"):extend()

function plugin:new()
    plugin.super.new(self, "path-prefix")
end

local function escape_hyphen(conf)
    local path_prefix = conf.path_prefix
    local should_escape = conf.escape

    if should_escape then
        return string.gsub(path_prefix, "%-", "%%%1")
    end

    return path_prefix
end

function plugin:access(plugin_conf)
    plugin.super.access(self)

    local service_path = ngx.ctx.service.path or ""
    local full_path = kong.request.get_path()
    local replace_match = escape_hyphen(plugin_conf)
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
