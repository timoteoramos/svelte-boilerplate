FROM alpine:latest AS build

WORKDIR /srv

RUN adduser -D -h /srv srv && chown -R srv:srv /srv

RUN apk add yarn

COPY --chown=srv:srv ./*.js ./*.json ./yarn.lock /srv/

USER srv

RUN yarn install

COPY --chown=srv:srv ./public /srv/public

COPY --chown=srv:srv ./src /srv/src

RUN yarn run build && tar czvf production.tar.gz -C public .


FROM alpine:latest AS production

WORKDIR /srv

RUN adduser -D -h /srv srv && chown -R srv:srv /srv

EXPOSE 8000

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]

CMD ["/usr/sbin/thttpd", "-D", "-h", "0.0.0.0", "-p", "8000", "-u", "srv", "-l", "-", "-d", "/srv", "-M", "60"]

RUN apk add dumb-init thttpd

USER srv

COPY --chown=srv:srv --from=build /srv/production.tar.gz /srv/

RUN tar xf production.tar.gz && rm production.tar.gz
