# buildxargs ~ `xargs` for BuildKit with `docker buildx bake`

An efficient way of running multiple concurrent `docker build` jobs on the [BuildKit](https://github.com/moby/buildkit) toolkit.

```shell
# export DOCKER_HOST=ssh://...
❯ buildxargs <<EOF
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=Hj7LwZqTflc' --output=/home/pete/ https://github.com/fenollp/dockerhost-tools--yt-dlp.git#main
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=dMT9PVmwW70' --output=/home/pete/ https://github.com/fenollp/dockerhost-tools--yt-dlp.git#main
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=kZ8E_lDQm-g' --output=/home/pete/ https://github.com/fenollp/dockerhost-tools--yt-dlp.git#main
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=NgZeYxl3aL8' --output=/home/pete/ https://github.com/fenollp/dockerhost-tools--yt-dlp.git#main
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=3XK-xhpAbIM' --output=/home/pete/ https://github.com/fenollp/dockerhost-tools--yt-dlp.git#main
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=iw3EdKNvm_g' --output=/home/pete/ https://github.com/fenollp/dockerhost-tools--yt-dlp.git#main
EOF
```

This is equivalent to executing the following
```shell
❯ export DOCKER_BUILDKIT=1
❯ xargs -P0 -o -I{} {} <<EOF
docker build ...
docker build ...
...
docker build ...
EOF
```

## Usage

```
--print
```

## Installing

```shell
cargo install --git https://github.com/fenollp/buildxargs
# also: install Docker ≥ 18.09
```

## See also

Related posts:
* My [vi`xargs`](https://fenollp.github.io/vixargs-visual-xargs) tool
* [`fmtd`](https://fenollp.github.io/a_simple_framework_for_universal_tools) and *a lib for piping data in & out of `docker build` tasks*
