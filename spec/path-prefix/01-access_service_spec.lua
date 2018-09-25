local kong = require('spec.kong')
local chance = require('spec.chance')
local http = require('spec.http')

describe('access', function()
    local upstream_url = "https://mockbin.org/request"

    local path
    local service_with_plugin
    local first_route
    local first_route
    local second_route

    local function assert_nil(err)
        assert.equals(err, nil)
    end

    setup(function()
        local err

        err, service_with_plugin = kong.create_service(chance.string("service-with-plugin"), upstream_url)
        assert_nil(err)

        path = "/service-with-plugin-route/foobar"
        err, first_route = kong.create_route(service_with_plugin.id, path, false)
        assert_nil(err)

        err, second_route = kong.create_route(service_with_plugin.id, "/service-with-plugin-route", false)
        assert_nil(err)

        local err, _ kong.create_plugin("path-prefix", {
        ["path_prefix"] = "/service-with-plugin-route",
        ["service_path"] = "/request"
    }, service_with_plugin.id, nil)

        assert_nil(err)
    end)

    teardown(function()
        kong.delete_route(first_route.id)
        kong.delete_route(second_route.id)
        kong.delete_service(service_with_plugin.id)
    end)


    describe('attached to a service', function()
        it("should rewrite the path to the upstream from /service-with-plugin-route/foobar to /foobar", function()
            local body = http.get("http://localhost:8000/service-with-plugin-route/foobar")

            -- localhost is the the value of the x-forwarded-host header, so Mockbin sets it as the host
            -- /request is the upstream's path
            local expected_url = 'http://localhost/request/foobar'

            assert.equal(body.url, expected_url)
        end)

        it("should rewrite /service-with-plugin-route to the empty string", function()
            -- rewriting the entire path is more easily accomplished by setting strip_prefix to true when creating the route
            -- but it's worth testing this flow anyway
            local body = http.get("http://localhost:8000/service-with-plugin-route")

            local expected_url = 'http://localhost/request'

            assert.equal(body.url, expected_url)
        end)

        it("should only make one path replacement", function()
            local body = http.get("http://localhost:8000/service-with-plugin-route/service-with-plugin-route")

            local expected_url = 'http://localhost/request/service-with-plugin-route'

            assert.equal(body.url, expected_url)
        end)
    end)
end)
