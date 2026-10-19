FROM nginxinc/nginx-unprivileged:1.27-alpine

ARG BUILD_SHA=local

USER root

COPY index.html /tmp/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN sed "s/BUILD_SHA_PLACEHOLDER/${BUILD_SHA}/g" /tmp/index.html \
    > /usr/share/nginx/html/index.html \
    && chown 101:101 /usr/share/nginx/html/index.html \
    && rm /tmp/index.html

USER 101

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
