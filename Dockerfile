FROM node:lts-alpine as mmPlayer_builder

# Maintainer
LABEL maintainer="Crazyrico Open Source Software <crazyrico@qq.com>"

# install dependencies and build tools
RUN apk update && apk add --no-cache wget curl git zip

WORKDIR /app

RUN git clone --recurse-submodules https://github.com/lxg20082008/Vue-mmPlayer.git

RUN cd Vue-mmPlayer \
	&& echo 'VUE_APP_BASE_API_URL = /api' > .env \
	&& npm install  \
	&& npm run build \
        && zip -r dist.zip dist


FROM node:lts-alpine

RUN apk update && apk add --no-cache bash wget curl git nginx unzip

WORKDIR /app

COPY --from=mmPlayer_builder /app/Vue-mmPlayer/dist.zip ./
RUN unzip dist.zip && rm -rf dist.zip

ADD default.conf /etc/nginx/http.d/

RUN cd /app && git clone https://github.com/lxg20082008/NeteaseCloudMusicApi.git

RUN cd NeteaseCloudMusicApi \
	&& npm config set registry "https://registry.npmmirror.com/" \
	&& npm install -g npm husky \
	&& npm install --production

WORKDIR /app/NeteaseCloudMusicApi

ADD docker-entrypoint.sh ./
ADD check.sh ./

RUN chmod +x /app/NeteaseCloudMusicApi/*.sh

EXPOSE 80 443 5001

ENTRYPOINT ["./docker-entrypoint.sh"]
