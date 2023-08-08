```shell
docker --debug buildx bake out-0d4af9095c79189b stdio-0d4af9095c79189b --file=/home/pete/wefwefwef/buildxargs.git/_target/debug/utf8parse-951ca9bdc6d60a50.hcl --file=/home/pete/wefwefwef/buildxargs.git/_target/debug/anstyle_parse-0d4af9095c79189b.hcl
```

## utf8parse-951ca9bdc6d60a50.hcl
```py
target "out-951ca9bdc6d60a50" {
	contexts = {
		"input_src_lib_rs--utf8parse-0.2.1" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/utf8parse-0.2.1",
		"rust" = "docker-image://docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094",
	}
	dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14
FROM rust AS src_lib_rs-lib-utf8parse-951ca9bdc6d60a50
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--utf8parse-0.2.1,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/utf8parse-0.2.1 \
    export LD_LIBRARY_PATH='' && \
    export CARGO='' && \
    export CARGO_MANIFEST_DIR='' && \
    export CARGO_PKG_VERSION='"1.2.0"' && \
    export CARGO_PKG_VERSION_MAJOR='' && \
    export CARGO_PKG_VERSION_MINOR='' && \
    export CARGO_PKG_VERSION_PATCH='' && \
    export CARGO_PKG_VERSION_PRE='' && \
    export CARGO_PKG_AUTHORS='["Pierre Fenoll <pierrefenoll@gmail.com>"]' && \
    export CARGO_PKG_NAME='' && \
    export CARGO_PKG_DESCRIPTION='"xargs for BuildKit with docker buildx bake"' && \
    export CARGO_PKG_HOMEPAGE='' && \
    export CARGO_PKG_REPOSITORY='' && \
    export CARGO_PKG_LICENSE='' && \
    export CARGO_PKG_LICENSE_FILE='' && \
    export CARGO_PKG_RUST_VERSION='' && \
    export CARGO_CRATE_NAME='' && \
    export CARGO_BIN_NAME='' && \
    export OUT_DIR='' && \
    if ! rustc '--crate-name' 'utf8parse' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '-C' 'metadata=951ca9bdc6d60a50' '-C' 'extra-filename=-951ca9bdc6d60a50' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/utf8parse-0.2.1/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-951ca9bdc6d60a50
COPY --from=src_lib_rs-lib-utf8parse-951ca9bdc6d60a50 /stderr /
COPY --from=src_lib_rs-lib-utf8parse-951ca9bdc6d60a50 /stdout /
FROM scratch AS out-951ca9bdc6d60a50
COPY --from=src_lib_rs-lib-utf8parse-951ca9bdc6d60a50 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-951ca9bdc6d60a50* /
DOCKERFILE
	network = "none"
	output = ["/home/pete/wefwefwef/buildxargs.git/_target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out-951ca9bdc6d60a50"
}
target "stdio-951ca9bdc6d60a50" {
	inherits = ["out-951ca9bdc6d60a50"]
	output = ["/tmp/tmp.dGRZ2CxdP4"]
	target = "stdio-951ca9bdc6d60a50"
}
```

## anstyle_parse-0d4af9095c79189b.hcl
```py
target "out-0d4af9095c79189b" {
	contexts = {
		"input_src_lib_rs--anstyle-parse-0.1.1" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstyle-parse-0.1.1",
		"rust" = "docker-image://docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094",
	}
	dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14
FROM rust AS src_lib_rs-lib-anstyle_parse-0d4af9095c79189b
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--anstyle-parse-0.1.1,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstyle-parse-0.1.1 \
  --mount=type=bind,from=out-951ca9bdc6d60a50,source=/libutf8parse-951ca9bdc6d60a50.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libutf8parse-951ca9bdc6d60a50.rmeta \
    export LD_LIBRARY_PATH='' && \
    export CARGO='' && \
    export CARGO_MANIFEST_DIR='' && \
    export CARGO_PKG_VERSION='"1.2.0"' && \
    export CARGO_PKG_VERSION_MAJOR='' && \
    export CARGO_PKG_VERSION_MINOR='' && \
    export CARGO_PKG_VERSION_PATCH='' && \
    export CARGO_PKG_VERSION_PRE='' && \
    export CARGO_PKG_AUTHORS='["Pierre Fenoll <pierrefenoll@gmail.com>"]' && \
    export CARGO_PKG_NAME='' && \
    export CARGO_PKG_DESCRIPTION='"xargs for BuildKit with docker buildx bake"' && \
    export CARGO_PKG_HOMEPAGE='' && \
    export CARGO_PKG_REPOSITORY='' && \
    export CARGO_PKG_LICENSE='' && \
    export CARGO_PKG_LICENSE_FILE='' && \
    export CARGO_PKG_RUST_VERSION='' && \
    export CARGO_CRATE_NAME='' && \
    export CARGO_BIN_NAME='' && \
    export OUT_DIR='' && \
    if ! rustc '--crate-name' 'anstyle_parse' '--edition' '2021' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '--cfg' 'feature="utf8"' '-C' 'metadata=0d4af9095c79189b' '-C' 'extra-filename=-0d4af9095c79189b' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--extern' 'utf8parse=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libutf8parse-951ca9bdc6d60a50.rmeta' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstyle-parse-0.1.1/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-0d4af9095c79189b
COPY --from=src_lib_rs-lib-anstyle_parse-0d4af9095c79189b /stderr /
COPY --from=src_lib_rs-lib-anstyle_parse-0d4af9095c79189b /stdout /
FROM scratch AS out-0d4af9095c79189b
COPY --from=src_lib_rs-lib-anstyle_parse-0d4af9095c79189b /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-0d4af9095c79189b* /
DOCKERFILE
	network = "none"
	output = ["/home/pete/wefwefwef/buildxargs.git/_target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out-0d4af9095c79189b"
}
target "stdio-0d4af9095c79189b" {
	inherits = ["out-0d4af9095c79189b"]
	output = ["/tmp/tmp.NddcdFgyUM"]
	target = "stdio-0d4af9095c79189b"
}
```
