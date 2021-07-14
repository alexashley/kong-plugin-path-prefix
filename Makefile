MAKEFLAGS += --silent
.PHONY=test test-image

default:
	echo "No default"

test-image:
	docker build -t kong-plugin-path-prefix-test:latest spec/

test: test-image
	docker run \
		-it \
		--rm \
		-e KONG_API_URL="http://host.docker.internal:8001" \
		-e KONG_PROXY_URL="http://host.docker.internal:8000" \
		-v $$(pwd):/usr/src \
		kong-plugin-path-prefix-test:latest /usr/src/spec
