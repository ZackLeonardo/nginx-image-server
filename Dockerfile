FROM ubuntu:16.04

ENV NGX_VERSION 1.13.9
ENV PCRE_VERSION 8.41
ENV ZLIB_VERSION 1.2.11
ENV NGX_SMALL_LIGHT_VERSION 0.9.2
ENV NGX_UPLOAD_MODULE_VERSION 2.255
ENV MYSQL_VERSION 5.7
ENV NODE_VERSION latest

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
      libperl-dev \
      libmagickwand-dev \
      imagemagick \
      pkg-config \
      unzip \
      nodejs \
      npm

RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password password 123456'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 123456'"]
RUN apt-get install --no-install-recommends --no-install-suggests -y mysql-server

# Mkdir tmp directories
#
RUN mkdir -p /tmp/nginx && \
    mkdir -p /tmp/ngx_small_light && \
    mkdir -p /tmp/nginx_upload_module

# Fetch-unarchive-setup ngx_small_light module
#
RUN cd /tmp/ngx_small_light && \
    wget --no-check-certificate https://github.com/cubicdaiya/ngx_small_light/archive/v${NGX_SMALL_LIGHT_VERSION}.tar.gz && tar zxvf v${NGX_SMALL_LIGHT_VERSION}.tar.gz && \
    cd /tmp/ngx_small_light/ngx_small_light-${NGX_SMALL_LIGHT_VERSION} && \
    ./setup

# Fetch-unarchive nginx
#
RUN cd /tmp/nginx && \
    wget --no-check-certificate https://nginx.org/download/nginx-${NGX_VERSION}.tar.gz && tar zxvf nginx-${NGX_VERSION}.tar.gz && \
    wget --no-check-certificate https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz && tar xzvf pcre-${PCRE_VERSION}.tar.gz && \
    wget --no-check-certificate http://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz && tar xzvf zlib-${ZLIB_VERSION}.tar.gz

# Fetch-unarchive nginx_upload_module
#
RUN cd /tmp/nginx_upload_module && \
    wget --no-check-certificate -O nginx_upload_module.zip https://codeload.github.com/vkholodkov/nginx-upload-module/zip/${NGX_UPLOAD_MODULE_VERSION} && \
    unzip nginx_upload_module.zip

# Setup nginx
#
RUN cd /tmp/nginx/nginx-${NGX_VERSION} && \
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
                --with-http_stub_status_module \
                --with-http_perl_module \
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
                --add-module=/tmp/ngx_small_light/ngx_small_light-${NGX_SMALL_LIGHT_VERSION} \
                --add-module=/tmp/nginx_upload_module/nginx-upload-module-${NGX_UPLOAD_MODULE_VERSION} && \
    make && \
    make install

# Nginx -t && nginx_upload_module needs:
#
RUN mkdir -p /var/lib/nginx && \
    mkdir -p /tmp/0 && \
    mkdir -p /tmp/1 && \
    mkdir -p /tmp/2 && \
    mkdir -p /tmp/3 && \
    mkdir -p /tmp/4 && \
    mkdir -p /tmp/5 && \
    mkdir -p /tmp/6 && \
    mkdir -p /tmp/7 && \
    mkdir -p /tmp/8 && \
    mkdir -p /tmp/9 && \
    chown www-data:root /tmp/*

# install n and update node
#
RUN npm install -g n && \
    n ${NODE_VERSION}

# Copy node express app
#
#RUN mkdir -p ~/nodeAPPs
#COPY files/image-server ~/nodeAPPs/image-server


# install node packages express and so on
#



# Remove all .tar.gz files. We don't need them anymore
#
RUN rm -rf /tmp/nginx && \
    rm -rf /tmp/ngx_small_light && \
    rm -rf /tmp/nginx_upload_module && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add config files
#
RUN mkdir -p /usr/share/nginx/perl/lib
COPY files/nginx.conf   /etc/nginx/nginx.conf
COPY files/mime.types   /etc/nginx/mime.types
COPY files/validator.pm /usr/share/nginx/perl/lib/validator.pm

EXPOSE 80 8080 8090

CMD ["nginx"]
