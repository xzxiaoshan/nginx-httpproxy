# nginx-httpproxy
添加支持http代理模块的nginx

基于 nginx 官网源码编译打包的 nginx 容器，添加了 ngx_http_proxy_connect_module 代理模块。  
使用方法详见： https://github.com/chobits/ngx_http_proxy_connect_module

我制作好的 docker 镜像，可以直接使用，详见：https://hub.docker.com/repository/docker/xzxiaoshan/nginx-httpproxy

如下为 docker-compose.yaml 示例：
```
version: '3.7'
services:

  nginx:
    #image: nginx:1.20.1
    image: xzxiaoshan/nginx-httpproxy:1.22.0
    container_name: nginx-forward
    #network_mode: "host"
    environment:
      TZ: Asia/Shanghai
    restart: always
    ports:
      - 10800:80
      - 10081:81
      - 18443:8443   #正向代理
      - 10443:443
    volumes:
      - /opt/soft/nginx/letsencrypt:/etc/letsencrypt
      - /opt/soft/nginx/conf.d:/etc/nginx/conf.d
      - /opt/soft/nginx/nginx.conf:/usr/local/nginx/conf/nginx.conf
      - /opt/soft/nginx/html:/var/html
      - /opt/soft/nginx/log:/var/log/nginx
    logging:
      driver: "json-file"
      options:
        max-size: "1g"
        max-file: "20"
```

nginx.conf
```
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
#pid        /var/run/nginx.pid;
pid        /usr/local/nginx/nginx.pid;


events {
    worker_connections  1024;
}


http {
    #include       /etc/nginx/mime.types;
    include       /usr/local/nginx/conf/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

conf.d/http-proxy.conf
```
map $http_x_forwarded_proto $real_scheme {
  default $http_x_forwarded_proto;
  ''      $scheme;
}

server {
    listen                         8443;

    # dns resolver used by forward proxying
    resolver                       8.8.8.8;

    # forward proxy for CONNECT request
    proxy_connect;
    proxy_connect_allow            443 563;
    proxy_connect_connect_timeout  10s;
    proxy_connect_read_timeout     10s;
    proxy_connect_send_timeout     10s;

    # forward proxy for non-CONNECT request
    location / {
        #proxy_pass $real_scheme://$host$request_uri;     #设定代理服务器的协议和地址 
        proxy_pass http://$host;
        proxy_set_header Host $host;
    }
 }
```

