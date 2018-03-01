FROM ubuntu:16.04

ENV NGINX_VERSION 1.13.9
ENV PCRE_VERSION 8.41
ENV ZLIB_VERSION 1.2.11
ENV NGX_SMALL_LIGHT_VERSION 0.9.2

# Install dependency packages
# NGINX is a program written in C, so we need to install the C compiler (GCC)
# apt-get install build-essential -y
# wget to fetch source files
# apt-get install wget -y
# NGINX depends on 3 libraries: PCRE, zlib and OpenSSL.
# They can be installed to system or quoted while nginx configure
# apt-get install -y openssl libssl-dev
# Module ngx_small_light depends on PRCE\ImageMagick
# apt-get install -y libmagickwand-dev imagemagick pkg-config
#
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
      build-essential \
      wget \
      openssl \
      libssl-dev \
      libmagickwand-dev \
      imagemagick \
      pkg-config

# Mkdir tmp directories
#
RUN mkdir -p /tmp/nginx && \
    mkdir -p /tmp/ngx_small_light

# Fetch-unarchive-setup ngx_small_light module
#
RUN cd /tmp/ngx_small_light && \
    wget --no-check-certificate https://github.com/cubicdaiya/ngx_small_light/archive/v${NGX_SMALL_LIGHT_VERSION}.tar.gz && tar zxvf v${NGX_SMALL_LIGHT_VERSION}.tar.gz && \
    cd /tmp/ngx_small_light/ngx_small_light-${NGX_SMALL_LIGHT_VERSION} && \
    ./setup


# Fetch-unarchive-setup nginx
RUN cd /tmp/nginx && \
    wget --no-check-certificate https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
    wget --no-check-certificate https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz && tar xzvf pcre-${PCRE_VERSION}.tar.gz && \
    wget --no-check-certificate http://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz && tar xzvf zlib-${ZLIB_VERSION}.tar.gz && \
    cd /tmp/nginx/nginx-${NGINX_VERSION} && \
    ./configure --prefix=/usr/share/nginx \
                --sbin-path=/usr/sbin/nginx \
                --modules-path=/usr/lib/nginx/modules \
                --conf-path=/etc/nginx/nginx.conf \
                --error-log-path=/var/log/nginx/error.log \
                --http-log-path=/var/log/nginx/access.log \
                --pid-path=/run/nginx.pid \
                --lock-path=/var/lock/nginx.lock \
                --user=www-data \
                --group=www-data \
                --build=Ubuntu \
                --http-client-body-temp-path=/var/lib/nginx/body \
                --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
                --http-proxy-temp-path=/var/lib/nginx/proxy \
                --http-scgi-temp-path=/var/lib/nginx/scgi \
                --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
                --with-pcre=../pcre-${PCRE_VERSION} \
                --with-zlib=../zlib-${ZLIB_VERSION} \
                --with-compat \
                --with-file-aio \
                --with-threads \
                --with-http_addition_module \
                --with-http_auth_request_module \
                --with-http_dav_module \
                --with-http_flv_module \
                --with-http_gunzip_module \
                --with-http_gzip_static_module \
                --with-http_mp4_module \
                --with-http_random_index_module \
                --with-http_realip_module \
                --with-http_slice_module \
                --with-http_ssl_module \
                --with-http_sub_module \
                --with-http_stub_status_module \
                --with-http_v2_module \
                --with-http_secure_link_module \
                --with-mail \
                --with-mail_ssl_module \
                --with-stream \
                --with-stream_realip_module \
                --with-stream_ssl_module \
                --with-stream_ssl_preread_module \
                --add-module=/tmp/ngx_small_light/ngx_small_light-${NGX_SMALL_LIGHT_VERSION} && \
    make && \
    make install

# Nginx -t needs:
#
RUN mkdir -p /var/lib/nginx


# Remove all .tar.gz files. We don't need them anymore
#
RUN rm -rf /tmp/nginx && \
    rm -rf /tmp/ngx_small_light && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



EXPOSE 80 8090

CMD ["nginx", "-g", "daemon off;"]
