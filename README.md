# buildxargs ~ `xargs` for BuildKit with `docker buildx bake`

An efficient way of running multiple concurrent `docker build` jobs on the [BuildKit](https://github.com/moby/buildkit) toolkit.

```shell
# export DOCKER_HOST=ssh://...
❯ buildxargs <<EOF
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=Hj7LwZqTflc' --output=$HOME https://github.com/fenollp/dockerhost-tools--yt-dlp.git
docker build -o=. --platform=local --build-arg PREBUILT=1 https://github.com/FuzzyMonkeyCo/monkey.git
docker build --platform=local -o . https://github.com/docker/buildx.git
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

```shell
buildxargs 1.0.0
Pierre Fenoll <pierrefenoll@gmail.com>
xargs for BuildKit with docker buildx bake

USAGE:
    buildxargs [OPTIONS]

OPTIONS:
        --attach
        --background
        --debug                  Print more things
    -f, --file <FILE>            Read commands from file [default: -]
    -h, --help                   Print help information
        --no-cache               Do not use cache when building the image
        --print                  Print the options without building
        --progress <PROGRESS>    Set type of progress output ("plain", "tty") [default: auto]
        --pull                   Always attempt to pull all referenced images
    -V, --version                Print version information
```

## Installing

```shell
cargo install --git https://github.com/fenollp/buildxargs
# also: install Docker ≥ 18.09
```

## See also

My [blog post about this](https://fenollp.github.io/buildxargs_xargs_for_buildkit).

Related:
* My [vi[sual]`xargs`](https://fenollp.github.io/vixargs-visual-xargs) tool
* [`fmtd`](https://fenollp.github.io/a_simple_framework_for_universal_tools) and *a lib for piping data in & out of `docker build` tasks*
