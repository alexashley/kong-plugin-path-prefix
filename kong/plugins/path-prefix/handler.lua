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

function plugin:access(plugin_conf)
    plugin.super.access(self)

    kong.ctx.plugin.conf = plugin_conf

    local full_path = kong.request.get_path()
    local replace_match = escape_hyphen()
    local path_without_prefix = full_path:gsub(replace_match, "", 1)

    if path_without_prefix == "" and plugin_conf.service_path == "" then
        path_without_prefix = "/"
    end

    kong.log("rewriting ", full_path, " to ", path_without_prefix)
    kong.service.request.set_path(plugin_conf.service_path .. path_without_prefix)
end

plugin.PRIORITY = 800

return plugin
