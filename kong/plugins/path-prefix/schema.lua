local typedefs = require "kong.db.schema.typedefs"

return {
  name = "path-prefix",
  fields = {
    {
      consumer = typedefs.no_consumer
    },
    {
      run_on = typedefs.run_on_first
    },
    {
      protocols = typedefs.protocols_http
    },
    {
      config = {
        type = "record",

        fields = {

          { path_prefix = {type = "string", required = true} },
          { escape = {type = "boolean", default = true} },

        }, 

      },
    },
  },
  entity_checks = {
  },
}
