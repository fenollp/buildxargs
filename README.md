# buildxargs ~ `xargs` for BuildKit with `docker buildx bake`

An efficient way of running multiple concurrent `docker build` jobs on the [BuildKit](https://github.com/moby/buildkit) toolkit.

```shell
# export DOCKER_HOST=ssh://...
❯ buildxargs <<EOF
docker build --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=Hj7LwZqTflc' --output=~/Videos https://github.com/fenollp/dockerhost-tools.git
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
...docker buildx bake's --help...

--

xargs for BuildKit with docker buildx bake

Usage: buildxargs [BAKE OPTIONS] [OPTIONS]

Options:
      --retry <RETRY>        Retry each failed build at most this many times [default: 3]
      --help                 Print help
  -V, --version              Print version

Try:
  buildxargs <<EOF
docker build --platform=local -o . https://github.com/docker/buildx.git
docker build --tag my-image:latest https://github.com/bojand/ghz.git
EOF
```

## Installing

```shell
cargo install --locked --git https://github.com/fenollp/buildxargs
# also: install Docker ≥ 18.09
```

## See also

My [blog post about this](https://fenollp.github.io/buildxargs_xargs_for_buildkit).

Related:
* My [vi[sual]`xargs`](https://fenollp.github.io/vixargs-visual-xargs) tool
* [`fmtd`](https://fenollp.github.io/a_simple_framework_for_universal_tools) and *a lib for piping data in & out of `docker build` tasks*

## TODO

* Spawn tasks in background, attach to display logs, cancel.
```shell
OPTIONS:
        --attach ssh HOST -t /usr/bin/htop + replay daemon logs
        --background Spawns calls using bg daemon and logs text back for log replain
```
