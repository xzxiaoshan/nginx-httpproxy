FROM alpine:latest
LABEL maintainer="365384722@qq.com"

ENV NGINX_VERSION=1.22.0
ENV HTTP_PROXY_VERSION=0.0.3

WORKDIR /usr/local/nginx

RUN set -x \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps gcc g++ make busybox-extras curl tzdata pcre pcre-dev openssl openssl-dev zlib zlib-dev \
	   patch shadow linux-headers libxml2 libxml2-dev libxslt libxslt-dev gd gd-dev geoip-dev \
    && curl -LSs http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O \
    && tar -xvf nginx-${NGINX_VERSION}.tar.gz && cd nginx-${NGINX_VERSION} \
    #&& curl -LSs https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/tags/v${HTTP_PROXY_VERSION}.tar.gz -O \
    && curl -LSs https://github.91chi.fun//https://github.com//chobits/ngx_http_proxy_connect_module/archive/refs/tags/v${HTTP_PROXY_VERSION}.tar.gz -O \
    && tar -xvf v${HTTP_PROXY_VERSION}.tar.gz \
	&& mv ngx_http_proxy_connect_module-${HTTP_PROXY_VERSION} ngx_http_proxy_connect_module \
    && patch -p1 < ./ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch \
    && useradd -M -s /sbin/nologin nginx \
    && ./configure \
       --user=nginx \
       --group=nginx \
       --prefix=/usr/local/nginx \
       --with-file-aio \
       --with-http_ssl_module \
       --with-http_realip_module \
       --with-http_addition_module \
       --with-http_xslt_module=dynamic \
       --with-http_image_filter_module \
       --with-http_geoip_module \
       --with-http_sub_module \
       --with-http_dav_module \
       --with-http_flv_module \
       --with-http_mp4_module \
       --with-http_gunzip_module \
       --with-http_gzip_static_module \
       --with-http_auth_request_module \
       --with-http_random_index_module \
       --with-http_secure_link_module \
       --with-http_degradation_module \
       --with-http_stub_status_module \
       --with-pcre \
       --add-module=./ngx_http_proxy_connect_module \
    && make -j $(nproc) \
    && make install \
    && rm -rf /tmp/* \
    && cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && ln -s /usr/local/nginx/sbin/nginx /sbin/nginx 

CMD ["/usr/local/nginx/sbin/nginx","-g","daemon off;"]
