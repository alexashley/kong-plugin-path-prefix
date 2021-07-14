# kong-plugin-path-prefix

A Kong plugin that rewrites the upstream request path. This can be useful if you have routes associated to a single service that all share the same path prefix.

For example, given `/foobar`, `/foobar/version`, and `/foobar/healthz` routes, the resulting upstream request routes will be `/`, `/version`, and `/healthz`, respectively, (assuming that `/foobar` is set as `config.path_prefix`).

This plugin is not compatible with APIs or any version older than Kong `0.14`.

## Usage

Can be installed on either a service or individual routes.

### Schema

| field          | explanation                                                          | default |
|----------------|----------------------------------------------------------------------|---------|
| `path_prefix`  | The prefix shared by all routes associated with the service.         | N/A     |
| `escape`       | Whether any hyphens in the path prefix should be escaped             | `true`  |

### Versions

The version of Kong that this plugin was last tested against is 2.5.0. 
The following branches have versions of the plugin that worked against the name of the branch:
- `0.14.x`
- `1.x.x`

## Development

Run `docker-compose up --build` to stand up an instance of Kong with the plugin.
Integration tests can be run with `make test`. 