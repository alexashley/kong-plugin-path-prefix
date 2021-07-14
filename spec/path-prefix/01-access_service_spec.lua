local http = require('spec.http')

describe('access', function()
    local kong_proxy_url = os.getenv("KONG_PROXY_URL") or "http://localhost:8000"
    local kong_host = string.match(kong_proxy_url, 'http://([%w+.]+)')

    describe('attached to a service', function()
        it("should rewrite the path to the upstream from /service-with-plugin-route/foobar to /foobar", function()
            local body = http.get(kong_proxy_url .. "/service-with-plugin-route/foobar")

            -- kong_host is the the value of the x-forwarded-host header, so Mockbin sets it as the host
            -- /request is the upstream's path
            -- the protocol is upgraded to https by Cloudflare
            local expected_url = 'https://' .. kong_host .. '/request/foobar'

            assert.equal(body.url, expected_url)
        end)

        it("should rewrite /service-with-plugin-route to the empty string", function()
            -- rewriting the entire path is more easily accomplished by setting strip_prefix to true when creating the route
            -- but it's worth testing this flow anyway
            local body = http.get(kong_proxy_url .. "/service-with-plugin-route")

            local expected_url = 'https://' .. kong_host .. '/request'

            assert.equal(body.url, expected_url)
        end)

        it("should only make one path replacement", function()
            local body = http.get(kong_proxy_url .. "/service-with-plugin-route/service-with-plugin-route")

            local expected_url = 'https://' .. kong_host .. '/request/service-with-plugin-route'

            assert.equal(body.url, expected_url)
        end)
    end)
end)