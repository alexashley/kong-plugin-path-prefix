FROM openresty/openresty:alpine-fat

WORKDIR /usr/src

RUN apk update --no-cache && \
    apk add openssl openssl-dev bsd-compat-headers m4
RUN luarocks install --local luasec
RUN luarocks install --local http 0.2 && \
    luarocks install --local lunajson && \
    luarocks install --local busted 

ENTRYPOINT ["/root/.luarocks/bin/busted"]
