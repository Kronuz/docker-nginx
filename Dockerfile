################################################################################
#  _   _       _
# | \ | | __ _(_)_ __ __  __
# |  \| |/ _` | | '_ \\ \/ /
# | |\  | (_| | | | | |>  <
# |_| \_|\__, |_|_| |_/_/\_\
#        |___/
#
# Based on:
# https://github.com/nginxinc/docker-nginx/blob/ddbbbdf9c410d105f82aa1b4dbf05c0021c84fd6/stable/alpine/Dockerfile
#
# Nginx image adds:
#        IPV6, HTTP, HTTP_CACHE, HTTP_FLV, HTTP_GZIP_STATIC, HTTP_REWRITE,
#        HTTP_SECURE_LINK, HTTP_SSL, HTTP_STATUS, HTTP_SUB, WWW,
#        ECHO, HEADERS_MORE, HTTP_PUSH_STREAM, HTTP_MP4_H264, LUA
#
# Build using:
# docker build -t kronuz/nginx:1.14.0 .
# docker tag kronuz/nginx:1.14.0 kronuz/nginx:latest
# docker push kronuz/nginx

FROM alpine:3.8

MAINTAINER Kronuz

ENV NGINX_VERSION 1.14.0

RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
  && CONFIG="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-pcre \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --add-module=/usr/src/headers-more-nginx-module-0.33 \
    --add-module=/usr/src/nginx-push-stream-module-0.5.4 \
    --add-module=/usr/src/nginx_mod_h264_streaming-2.2.7 \
    --add-module=/usr/src/ngx_devel_kit-0.3.0 \
    --add-module=/usr/src/lua-nginx-module-0.10.13 \
  " \
  && addgroup -S nginx \
  && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
  && apk add libgcc \
  && apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev \
  && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
  && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
  && curl -fSL https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz -o headers-more-nginx-module.tar.gz \
  && curl -fSL http://h264.code-shop.com/download/nginx_mod_h264_streaming-2.2.7.tar.gz -o nginx_mod_h264_streaming.tar.gz \
  && curl -fSL https://github.com/wandenberg/nginx-push-stream-module/archive/0.5.4.tar.gz -o nginx-push-stream-module.tar.gz \
  && curl -fSL http://luajit.org/download/LuaJIT-2.0.5.tar.gz -o LuaJIT-2.0.5.tar.gz \
  && curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz -o nginx_devel_kit.tar.gz \
  && curl -fSL https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz -o nginx_lua_module.tar.gz \
  && export GNUPGHOME="$(mktemp -d)" \
  && found=''; \
  for server in \
    ha.pool.sks-keyservers.net \
    hkp://keyserver.ubuntu.com:80 \
    hkp://p80.pool.sks-keyservers.net:80 \
    pgp.mit.edu \
  ; do \
    echo "Fetching GPG key $GPG_KEYS from $server"; \
    gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
  done; \
  test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
  gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
  && rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
  && mkdir -p /usr/src \
  && tar -zxC /usr/src -f nginx.tar.gz \
  && tar -zxC /usr/src -f headers-more-nginx-module.tar.gz \
  && tar -zxC /usr/src -f nginx_mod_h264_streaming.tar.gz \
  && tar -zxC /usr/src -f nginx-push-stream-module.tar.gz \
  && tar -zxC /usr/src -f LuaJIT-2.0.5.tar.gz \
  && tar -zxC /usr/src -f nginx_devel_kit.tar.gz \
  && tar -zxC /usr/src -f nginx_lua_module.tar.gz \
  && rm *.tar.gz \
  && cd /usr/src/LuaJIT-2.0.5 \
  && make install \
  && curl -fSL https://raw.githubusercontent.com/freebsd/freebsd-ports/master/www/nginx/files/extra-patch-ngx_http_streaming_module.c -o /usr/src/nginx_mod_h264_streaming-2.2.7/extra-patch-ngx_http_streaming_module.c \
  && cd /usr/src/nginx_mod_h264_streaming-2.2.7 \
  && printf "begin-base64 644 patch\nLS0tIG5naW54X21vZF9oMjY0X3N0cmVhbWluZy0yLjIuNy9zcmMvbXA0X2lvLmMub3JpZwkyMDE4LTA4LTAxIDE3OjEwOjUzLjAwMDAwMDAwMCAtMDUwMAorKysgbmdpbnhfbW9kX2gyNjRfc3RyZWFtaW5nLTIuMi43L3NyYy9tcDRfaW8uYwkyMDE4LTA4LTAxIDE3OjEwOjU3LjAwMDAwMDAwMCAtMDUwMApAQCAtMTUyMCwxMiArMTUyMCw2IEBACiAgIDE2MDAwLCAxMjAwMCwgMTEwMjUsICA4MDAwLCAgNzM1MCwgICAgIDAsICAgICAwLCAgICAgMAogfTsKIAotc3RhdGljIGNvbnN0IHVpbnQzMl90IGFhY19jaGFubmVsc1tdID0KLXsKLSAgMCwgMSwgMiwgMywgNCwgNSwgNiwgOCwKLSAgMCwgMCwgMCwgMCwgMCwgMCwgMCwgMAotfTsKLQogc3RhdGljIGludCBtcDRfc2FtcGxlcmF0ZV90b19pbmRleCh1bnNpZ25lZCBpbnQgc2FtcGxlcmF0ZSkKIHsKICAgdW5zaWduZWQgaW50IGk7Ci0tLSBuZ2lueF9tb2RfaDI2NF9zdHJlYW1pbmctMi4yLjcvc3JjL25neF9odHRwX3N0cmVhbWluZ19tb2R1bGUuYy5vcmlnCTIwMTAtMDUtMjQgMTg6MDQ6NDMuMDAwMDAwMDAwICswNDAwCisrKyBuZ2lueF9tb2RfaDI2NF9zdHJlYW1pbmctMi4yLjcvc3JjL25neF9odHRwX3N0cmVhbWluZ19tb2R1bGUuYwkyMDEwLTA1LTI0IDE4OjA1OjAyLjAwMDAwMDAwMCArMDQwMApAQCAtMTU1LDEwICsxNTUsNiBAQAogICB9CiAKICAgLyogVE9ETzogV2luMzIgKi8KLSAgaWYgKHItPnplcm9faW5fdXJpKQotICB7Ci0gICAgcmV0dXJuIE5HWF9ERUNMSU5FRDsKLSAgfQogCiAgIHJjID0gbmd4X2h0dHBfZGlzY2FyZF9yZXF1ZXN0X2JvZHkocik7CiAKLS0tIG5naW54X21vZF9oMjY0X3N0cmVhbWluZy0yLjIuNy9zcmMvbXA0X3JlYWRlci5jLm9yaWcJMjAxOC0wOC0wMSAxNzoyNDo0Ny4wMDAwMDAwMDAgLTA1MDAKKysrIG5naW54X21vZF9oMjY0X3N0cmVhbWluZy0yLjIuNy9zcmMvbXA0X3JlYWRlci5jCTIwMTgtMDgtMDEgMTc6MjY6MzYuMDAwMDAwMDAwIC0wNTAwCkBAIC0zNzMsOCArMzczLDYgQEAKICAgdW5zaWduZWQgaW50IHRhZzsKICAgdW5zaWduZWQgaW50IGxlbjsKIAotICB1aW50MTZfdCBzdHJlYW1faWQ7Ci0gIHVuc2lnbmVkIGludCBzdHJlYW1fcHJpb3JpdHk7CiAgIHVuc2lnbmVkIGludCBvYmplY3RfdHlwZV9pZDsKICAgdW5zaWduZWQgaW50IHN0cmVhbV90eXBlOwogICB1bnNpZ25lZCBpbnQgYnVmZmVyX3NpemVfZGI7CkBAIC0zOTQsMTQgKzM5MiwxNCBAQAogICB7CiAgICAgbGVuID0gbXA0X3JlYWRfZGVzY19sZW4oJmJ1ZmZlcik7CiAgICAgTVA0X0lORk8oIkVsZW1lbnRhcnkgU3RyZWFtIERlc2NyaXB0b3I6IGxlbj0ldVxuIiwgbGVuKTsKLSAgICBzdHJlYW1faWQgPSByZWFkXzE2KGJ1ZmZlciArIDApOwotICAgIHN0cmVhbV9wcmlvcml0eSA9IHJlYWRfOChidWZmZXIgKyAyKTsKKyAgICByZWFkXzE2KGJ1ZmZlciArIDApOworICAgIHJlYWRfOChidWZmZXIgKyAyKTsKICAgICBidWZmZXIgKz0gMzsKICAgfQogICBlbHNlCiAgIHsKICAgICBNUDRfSU5GTygiRWxlbWVudGFyeSBTdHJlYW0gRGVzY3JpcHRvcjogbGVuPSV1XG4iLCAyKTsKLSAgICBzdHJlYW1faWQgPSByZWFkXzE2KGJ1ZmZlciArIDApOworICAgIHJlYWRfMTYoYnVmZmVyICsgMCk7CiAgICAgYnVmZmVyICs9IDI7CiAgIH0KIApAQCAtNTIzLDE3ICs1MjEsMTMgQEAKICAgICAgIHsKICAgICAgICAgdW5zaWduZWQgaW50IHNlcXVlbmNlX3BhcmFtZXRlcl9zZXRzOwogICAgICAgICB1bnNpZ25lZCBpbnQgcGljdHVyZV9wYXJhbWV0ZXJfc2V0czsKLSAgICAgICAgdW5zaWduZWQgaW50IGNvbmZpZ3VyYXRpb25fdmVyc2lvbjsKLSAgICAgICAgdW5zaWduZWQgaW50IHByb2ZpbGVfaW5kaWNhdGlvbjsKLSAgICAgICAgdW5zaWduZWQgaW50IHByb2ZpbGVfY29tcGF0aWJpbGl0eTsKLSAgICAgICAgdW5zaWduZWQgaW50IGxldmVsX2luZGljYXRpb247CiAKICAgICAgICAgc2FtcGxlX2VudHJ5LT5jb2RlY19wcml2YXRlX2RhdGFfID0gYnVmZmVyOwogCi0gICAgICAgIGNvbmZpZ3VyYXRpb25fdmVyc2lvbiA9IHJlYWRfOChidWZmZXIgKyAwKTsKLSAgICAgICAgcHJvZmlsZV9pbmRpY2F0aW9uID0gcmVhZF84KGJ1ZmZlciArIDEpOwotICAgICAgICBwcm9maWxlX2NvbXBhdGliaWxpdHkgPSByZWFkXzgoYnVmZmVyICsgMik7Ci0gICAgICAgIGxldmVsX2luZGljYXRpb24gPSByZWFkXzgoYnVmZmVyICsgMyk7CisgICAgICAgIHJlYWRfOChidWZmZXIgKyAwKTsKKyAgICAgICAgcmVhZF84KGJ1ZmZlciArIDEpOworICAgICAgICByZWFkXzgoYnVmZmVyICsgMik7CisgICAgICAgIHJlYWRfOChidWZmZXIgKyAzKTsKIAogICAgICAgICBzYW1wbGVfZW50cnktPm5hbF91bml0X2xlbmd0aF8gPSAocmVhZF84KGJ1ZmZlciArIDQpICYgMykgKyAxOwogICAgICAgICBzZXF1ZW5jZV9wYXJhbWV0ZXJfc2V0cyA9IHJlYWRfOChidWZmZXIgKyA1KSAmIDB4MWY7Ci0tLSBuZ2lueF9tb2RfaDI2NF9zdHJlYW1pbmctMi4yLjcvc3JjL291dHB1dF9tcDQuYy5vcmlnCTIwMTgtMDgtMDEgMTc6MzE6NTMuMDAwMDAwMDAwIC0wNTAwCisrKyBuZ2lueF9tb2RfaDI2NF9zdHJlYW1pbmctMi4yLjcvc3JjL291dHB1dF9tcDQuYwkyMDE4LTA4LTAxIDE3OjMyOjIyLjAwMDAwMDAwMCAtMDUwMApAQCAtMzcwLDcgKzM3MCw2IEBACiAgIHsKICAgICBzdHJ1Y3Qgc3Rzc190KiBzdHNzID0gdHJhay0+bWRpYV8tPm1pbmZfLT5zdGJsXy0+c3Rzc187CiAgICAgdW5zaWduZWQgaW50IGVudHJpZXMgPSAwOwotICAgIHVuc2lnbmVkIGludCBzdHNzX3N0YXJ0OwogICAgIHVuc2lnbmVkIGludCBpOwogCiAgICAgZm9yKGkgPSAwOyBpICE9IHN0c3MtPmVudHJpZXNfOyArK2kpCkBAIC0zNzgsNyArMzc3LDYgQEAKICAgICAgIGlmKHN0c3MtPnNhbXBsZV9udW1iZXJzX1tpXSA+PSBzdGFydCArIDEpCiAgICAgICAgIGJyZWFrOwogICAgIH0KLSAgICBzdHNzX3N0YXJ0ID0gaTsKICAgICBmb3IoOyBpICE9IHN0c3MtPmVudHJpZXNfOyArK2kpCiAgICAgewogICAgICAgdW5zaWduZWQgaW50IHN5bmNfc2FtcGxlID0gc3Rzcy0+c2FtcGxlX251bWJlcnNfW2ldOwo=\n====" | uudecode \
  && patch -p1 < patch \
  && cd /usr/src/nginx-$NGINX_VERSION \
  && ./configure $CONFIG --with-debug \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && mv objs/nginx objs/nginx-debug \
  && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
  && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
  && mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
  && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
  && ./configure $CONFIG \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && rm -rf /etc/nginx/html/ \
  && mkdir /etc/nginx/conf.d/ \
  && mkdir -p /usr/share/nginx/html/ \
  && install -m644 html/index.html /usr/share/nginx/html/ \
  && install -m644 html/50x.html /usr/share/nginx/html/ \
  && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
  && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
  && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
  && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
  && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
  && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
  && strip /usr/sbin/nginx* \
  && strip /usr/lib/nginx/modules/*.so \
  && rm -rf /usr/src/nginx-$NGINX_VERSION \
  && rm -rf /usr/src/headers-more-nginx-module-0.33 \
  && rm -rf /usr/src/nginx-push-stream-module-0.5.4 \
  && rm -rf /usr/src/nginx_mod_h264_streaming-2.2.7 \
  \
  # Bring in gettext so we can get `envsubst`, then throw
  # the rest away. To do this, we need to install `gettext`
  # then move `envsubst` out of the way so `gettext` can
  # be deleted completely, then move `envsubst` back.
  && apk add --no-cache --virtual .gettext gettext \
  && mv /usr/bin/envsubst /tmp/ \
  \
  && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )" \
  && apk add --no-cache --virtual .nginx-rundeps $runDeps \
  && apk del .build-deps \
  && apk del .gettext \
  && mv /tmp/envsubst /usr/local/bin/ \
  \
  # Bring in tzdata so users could set the timezones through the environment
  # variables
  && apk add --no-cache tzdata \
  \
  # forward request and error logs to docker log collector
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
