local plugin = require("kong.plugins.base_plugin"):extend()

function plugin:new()
    plugin.super.new(self, "path-prefix")
end

function plugin:access(plugin_conf)
    plugin.super.access(self)

    local full_path = kong.request.get_path()
    local path_without_prefix = full_path:gsub("%" .. plugin_conf.path_prefix, "")

    if path_without_prefix == "" and plugin_conf.service_path == "" then
        path_without_prefix = "/"
    end

    kong.log("rewriting ", full_path, " to ", path_without_prefix)
    kong.service.request.set_path(plugin_conf.service_path .. path_without_prefix)
end

plugin.PRIORITY = 800

return plugin
