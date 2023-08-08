docker --debug buildx bake -f- out-74434efe692a445d <<BAKEFILE
target "out-74434efe692a445d" {
  contexts = {
    "input_src_lib_rs--unicode-ident-1.0.5" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/unicode-ident-1.0.5",
    "input_src_lib_rs--proc-macro2-1.0.56" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/proc-macro2-1.0.56",
    "input_src_lib_rs--quote-1.0.26" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26",
    "rust" = "docker-image://docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094",
  }
  dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14



FROM rust AS src_lib_rs-lib-unicode_ident-417636671c982ef8
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--unicode-ident-1.0.5,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/unicode-ident-1.0.5 \
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
    if ! rustc '--crate-name' 'unicode_ident' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=417636671c982ef8' '-C' 'extra-filename=-417636671c982ef8' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/unicode-ident-1.0.5/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-417636671c982ef8
COPY --from=src_lib_rs-lib-unicode_ident-417636671c982ef8 /stderr /
COPY --from=src_lib_rs-lib-unicode_ident-417636671c982ef8 /stdout /
FROM scratch AS out-417636671c982ef8
COPY --from=src_lib_rs-lib-unicode_ident-417636671c982ef8 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-417636671c982ef8* /

FROM rust AS src_lib_rs-lib-proc_macro2-ef119f7eb3ef5720
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--proc-macro2-1.0.56,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/proc-macro2-1.0.56 \
  --mount=type=bind,from=out-417636671c982ef8,source=/libunicode_ident-417636671c982ef8.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libunicode_ident-417636671c982ef8.rmeta \
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
    if ! rustc '--crate-name' 'proc_macro2' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '--cfg' 'feature="proc-macro"' '-C' 'metadata=ef119f7eb3ef5720' '-C' 'extra-filename=-ef119f7eb3ef5720' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--extern' 'unicode_ident=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libunicode_ident-417636671c982ef8.rmeta' '--cap-lints' 'allow' '--cfg' 'use_proc_macro' '--cfg' 'wrap_proc_macro' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/proc-macro2-1.0.56/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-ef119f7eb3ef5720
COPY --from=src_lib_rs-lib-proc_macro2-ef119f7eb3ef5720 /stderr /
COPY --from=src_lib_rs-lib-proc_macro2-ef119f7eb3ef5720 /stdout /
FROM scratch AS out-ef119f7eb3ef5720
COPY --from=src_lib_rs-lib-proc_macro2-ef119f7eb3ef5720 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-ef119f7eb3ef5720* /


# FROM rust AS src_lib_rs-lib-unicode_ident-417636671c982ef8
# WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
# WORKDIR /home/pete/wefwefwef/buildxargs.git
# RUN \
#   --mount=type=bind,from=input_src_lib_rs--unicode-ident-1.0.5,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/unicode-ident-1.0.5 \
#     export LD_LIBRARY_PATH='' && \
#     export CARGO='' && \
#     export CARGO_MANIFEST_DIR='' && \
#     export CARGO_PKG_VERSION='"1.2.0"' && \
#     export CARGO_PKG_VERSION_MAJOR='' && \
#     export CARGO_PKG_VERSION_MINOR='' && \
#     export CARGO_PKG_VERSION_PATCH='' && \
#     export CARGO_PKG_VERSION_PRE='' && \
#     export CARGO_PKG_AUTHORS='["Pierre Fenoll <pierrefenoll@gmail.com>"]' && \
#     export CARGO_PKG_NAME='' && \
#     export CARGO_PKG_DESCRIPTION='"xargs for BuildKit with docker buildx bake"' && \
#     export CARGO_PKG_HOMEPAGE='' && \
#     export CARGO_PKG_REPOSITORY='' && \
#     export CARGO_PKG_LICENSE='' && \
#     export CARGO_PKG_LICENSE_FILE='' && \
#     export CARGO_PKG_RUST_VERSION='' && \
#     export CARGO_CRATE_NAME='' && \
#     export CARGO_BIN_NAME='' && \
#     export OUT_DIR='' && \
#     if ! rustc '--crate-name' 'unicode_ident' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=417636671c982ef8' '-C' 'extra-filename=-417636671c982ef8' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/unicode-ident-1.0.5/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
# FROM scratch AS stdio-417636671c982ef8
# COPY --from=src_lib_rs-lib-unicode_ident-417636671c982ef8 /stderr /
# COPY --from=src_lib_rs-lib-unicode_ident-417636671c982ef8 /stdout /
# FROM scratch AS out-417636671c982ef8
# COPY --from=src_lib_rs-lib-unicode_ident-417636671c982ef8 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-417636671c982ef8* /

FROM rust AS src_lib_rs-lib-quote-74434efe692a445d
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--quote-1.0.26,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26 \
  --mount=type=bind,from=out-ef119f7eb3ef5720,source=/libproc_macro2-ef119f7eb3ef5720.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libproc_macro2-ef119f7eb3ef5720.rmeta \
  --mount=type=bind,from=out-417636671c982ef8,source=/libunicode_ident-417636671c982ef8.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libunicode_ident-417636671c982ef8.rmeta \
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
    if ! rustc '--crate-name' 'quote' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '--cfg' 'feature="proc-macro"' '-C' 'metadata=74434efe692a445d' '-C' 'extra-filename=-74434efe692a445d' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--extern' 'proc_macro2=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libproc_macro2-ef119f7eb3ef5720.rmeta' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-74434efe692a445d
COPY --from=src_lib_rs-lib-quote-74434efe692a445d /stderr /
COPY --from=src_lib_rs-lib-quote-74434efe692a445d /stdout /
FROM scratch AS out-74434efe692a445d
COPY --from=src_lib_rs-lib-quote-74434efe692a445d /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-74434efe692a445d* /
DOCKERFILE
  network = "none"
  output = ["/home/pete/wefwefwef/buildxargs.git/_target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
  platforms = ["local"]
  target = "out-74434efe692a445d"
}
target "stdio-74434efe692a445d" {
  inherits = ["out-74434efe692a445d"]
  output = ["/tmp/tmp.gA2hdmND81"]
  target = "stdio-74434efe692a445d"
}
BAKEFILE
