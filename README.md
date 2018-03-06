# Nginx Image Server
[![Docker Repository](https://hub.docker.com/r/maiz9088/nginx-image-server/)]

Docker Image for [Nginx](http://nginx.org/) server for image processing with [ngx_small_light](https://github.com/cubicdaiya/ngx_small_light).
It supports resizing/cropping/formatting (...etc) of images stored in local storages or AWS S3.

Please see https://github.com/cubicdaiya/ngx_small_light for more information about image processing.

## SUPPORTED TAGS

* `latest`

## HOW TO USE

```bash
# Get the docker image
$ docker pull maiz9088/nginx-image-server

# Fetch an example image to try image-processing local image
$ curl -L https://raw.githubusercontent.com/maiz9088/nginx-image-server/master/examples/example.jpg > \
    /tmp/example.jpg

# Start the image server
$ docker run \
    --rm \
    -it \
    --name nginx-image-server \
    -p 80:80 \
    -p 8090:8090 \
    -v /tmp/example.jpg:/var/www/nginx/images/example.jpg \
    -e "SERVER_NAME=image.example.com" \
    -e "S3_HOST=<YOUR-BUCKET-NAME>.s3.amazonaws.com" \
    maiz9088/nginx-image-server:latest
```

Then you can try image-processing by accessing

* **Images in S3**: `http://<YOUR-SERVER.com>/small_light(dh=400,da=l,ds=s)/<PATH-TO-IMAGE-IN-S3>`
* **Images in Local**: `http://<YOUR-SERVER.com>/local/small_light(dh=400,da=l,ds=s)/images/example.jpg`

for more information,ref to:
https://github.com/wantedly/nginx-image-server
http://nginx.org/en/docs/
https://www.nginx.com/resources/wiki/modules/
https://www.vultr.com/docs/how-to-compile-nginx-from-source-on-ubuntu-16-04

## LICENSE
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
