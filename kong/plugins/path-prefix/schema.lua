local typedefs = require "kong.db.schema.typedefs"

return {
    name = "path-prefix",
    fields = {
        {
            consumer = typedefs.no_consumer
        },
        {
            protocols = typedefs.protocols_http
        },
        {
            config = {
                type = "record",
                fields = {
                    { path_prefix = { type = "string", required = true } },
                    { escape = { type = "boolean", default = true } },
                    { forwarded_header = { type = "boolean", default = false } },
                },
            },
        },
    },
    entity_checks = {},
}
