## # Stage 1: Build the Vue.js application
# 基础镜像使用 Node.js 官方的 LTS (长期支持版本) Alpine 镜像
FROM node:lts-alpine as mmPlayer_builder

# 安装所需的软件包，包括 wget、curl、git 和 zip
RUN apk update && apk add --no-cache wget curl git zip

# 设置工作目录
WORKDIR /app

# 克隆 Vue-mmPlayer 项目的代码仓库，包括子模块, generating a dist.zip file.
RUN git clone --recurse-submodules https://github.com/lxg20082008/Vue-mmPlayer.git

RUN cd Vue-mmPlayer \
	&& echo 'VUE_APP_BASE_API_URL = /api' > .env \
	&& npm install  \
	&& npm run build \
        && zip -r dist.zip dist

### Stage 2: Build the final Docker image
# 使用 node:lts-alpine 作为基础镜像，用于构建最终的 Docker 镜像。
FROM node:lts-alpine

# 在镜像中安装所需的软件包，包括 bash、wget、curl、git、nginx 和 unzip。
RUN apk update && apk add --no-cache bash wget curl git nginx unzip

WORKDIR /app

# 从上一阶段构建的镜像中复制 dist.zip 文件到当前阶段的工作目录中，并使用 RUN 指令解压缩 dist.zip 文件并删除原始文件。
COPY --from=mmPlayer_builder /app/Vue-mmPlayer/dist.zip ./
RUN unzip dist.zip && rm -rf dist.zip

# 将 default.conf 文件复制到镜像中的 /etc/nginx/http.d/ 目录下，用于配置 nginx 服务器。
COPY default.conf /etc/nginx/http.d/

# 克隆NeteaseCloudMusicApi项目的代码仓库，并进入 NeteaseCloudMusicApi 目录。
WORKDIR /app
RUN git clone https://github.com/lxg20082008/NeteaseCloudMusicApi.git
# RUN git clone https://${{ secrets.MY_GITHUB_USERNAME }}:${{ secrets.MY_GITHUB_TOKEN }}@github.com/lxg20082008/NeteaseCloudMusicApi.git
# 清空 npm 缓存，设置 npm 仓库地址，并分别使用 --production 和 --loglevel verbose 选项安装依赖包
# 安装 npm 和 husky，最后再次使用 --production 选项安装依赖包。
WORKDIR /app/NeteaseCloudMusicApi
RUN npm config set registry "https://registry.npmmirror.com/"
RUN npm install -g npm husky
RUN npm cache clean --force
RUN rm -rf node_modules
RUN npm install --production

WORKDIR /app/NeteaseCloudMusicApi

# 将 docker-entrypoint.sh 和 check.sh 两个脚本文件复制到镜像中的当前工作目录下。
COPY docker-entrypoint.sh ./
COPY check.sh ./

# 为当前工作目录下的所有 .sh 脚本文件添加执行权限。
RUN chmod +x /app/NeteaseCloudMusicApi/*.sh

# 声明容器在运行时监听的端口号，包括 80、443 和 5001。
# EXPOSE 80 443 5001
EXPOSE 80 443 32100

# 设置容器启动时运行的命令，即 docker-entrypoint.sh 脚本。
ENTRYPOINT ["./docker-entrypoint.sh"]
