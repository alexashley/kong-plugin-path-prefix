MAKEFLAGS += --silent
.PHONY=all
.all=dev

default:
	echo "No default"

dev:
	luarocks install --local http
	luarocks install --local lunajson
	luarocks install --local busted

test:
	busted spec/
