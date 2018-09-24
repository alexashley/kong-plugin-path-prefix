# kong-plugin-path-prefix

A Kong plugin that rewrites the upstream request path. This can be useful if you have routes associated to a single service that all share the same path prefix.

For example, given `/foobar`, `/foobar/version`, and `/foobar/healthz` routes, the resulting upstream request routes will be `/`, `/version`, and `/healthz`, respectively, (assuming the `/foobar` is set as `config.path_prefix`).

## usage

Can be installed on either a service or individual routes.

### schema
| field          | explanation                                                                                     | default |
|----------------|-------------------------------------------------------------------------------------------------|---------|
| `path_prefix`  | The prefix shared by all routes associated with the service.                                    | N/A     |
| `service_path` | If the configured service has an upstream path (e.g., `/api`) then this should match that path. | `""`    |