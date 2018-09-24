FROM kong:0.14.1-alpine

WORKDIR /usr/local/kong

RUN apk update && apk add postgresql-client

COPY entrypoint.sh .
COPY kong/plugins/ /usr/local/share/lua/5.1/kong/plugins/

CMD ["/usr/local/kong/entrypoint.sh"]