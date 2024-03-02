# music-player-docker-build
在线音乐播放器docker镜像构建

本项目基于[Vue-mmPlayer](https://github.com/maomao1996/Vue-mmPlayer) & [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi) 开源项目构建

# build
```bash
# docker build -t lxg20082008/mmplayer .
```

# run
```bash
# docker run --name mm_player --restart always -dit -p 80:80 -v /mnt/music:/data lxg20082008/mmplayer:main
```
# version
1.3
