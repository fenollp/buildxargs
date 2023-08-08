docker --debug buildx bake --file=- out-02591a0046469edd <<BAKEFILE
target "out-02591a0046469edd" {
  contexts = {
    "input_src_lib_rs--anstyle-parse-0.1.1" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstyle-parse-0.1.1",
    "input_src_lib_rs--anstream-0.2.6" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstream-0.2.6",
    "input_src_lib_rs--libc-0.2.140" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140",
    "input_src_lib_rs--rustix-0.37.6" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6",
    "input_src_lib_rs--is-terminal-0.4.7" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/is-terminal-0.4.7",
    "input_src_lib_rs--io-lifetimes-1.0.3" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3",
    "input_src_lib_rs--utf8parse-0.2.1" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/utf8parse-0.2.1",
    "input_src_lib_rs--linux-raw-sys-0.3.1" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/linux-raw-sys-0.3.1",
    "input_src_lib_rs--concolor-override-1.0.0" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/concolor-override-1.0.0",
    "input_src_lib_rs--bitflags-1.3.2" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/bitflags-1.3.2",
    "input_src_lib_rs--clap_builder-4.2.1" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1",
    "input_src_lib_rs--clap_lex-0.4.1" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_lex-0.4.1",
    "input_src_lib_rs--concolor-query-0.3.3" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/concolor-query-0.3.3",
    "input_src_lib_rs--anstyle-0.3.5" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstyle-0.3.5",
    "rust" = "docker-image://docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094",
    "input_src_lib_rs--strsim-0.10.0" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/strsim-0.10.0",
  }
  dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS src_lib_rs-lib-libc-9de7ca31dbbda4df
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--libc-0.2.140,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140 \
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
    if ! rustc '--crate-name' 'libc' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '--cfg' 'feature="extra_traits"' '--cfg' 'feature="std"' '-C' 'metadata=9de7ca31dbbda4df' '-C' 'extra-filename=-9de7ca31dbbda4df' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' '--cfg' 'freebsd11' '--cfg' 'libc_priv_mod_use' '--cfg' 'libc_union' '--cfg' 'libc_const_size_of' '--cfg' 'libc_align' '--cfg' 'libc_int128' '--cfg' 'libc_core_cvoid' '--cfg' 'libc_packedN' '--cfg' 'libc_cfg_target_vendor' '--cfg' 'libc_non_exhaustive' '--cfg' 'libc_long_array' '--cfg' 'libc_ptr_addr_of' '--cfg' 'libc_underscore_const_names' '--cfg' 'libc_const_extern_fn' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-9de7ca31dbbda4df
COPY --from=src_lib_rs-lib-libc-9de7ca31dbbda4df /stderr /
COPY --from=src_lib_rs-lib-libc-9de7ca31dbbda4df /stdout /
FROM scratch AS out-9de7ca31dbbda4df
COPY --from=src_lib_rs-lib-libc-9de7ca31dbbda4df /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-9de7ca31dbbda4df* /

FROM rust AS src_lib_rs-lib-clap_lex-7dfc2f58447e727e
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--clap_lex-0.4.1,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_lex-0.4.1 \
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
    if ! rustc '--crate-name' 'clap_lex' '--edition' '2021' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=7dfc2f58447e727e' '-C' 'extra-filename=-7dfc2f58447e727e' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_lex-0.4.1/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-7dfc2f58447e727e
COPY --from=src_lib_rs-lib-clap_lex-7dfc2f58447e727e /stderr /
COPY --from=src_lib_rs-lib-clap_lex-7dfc2f58447e727e /stdout /
FROM scratch AS out-7dfc2f58447e727e
COPY --from=src_lib_rs-lib-clap_lex-7dfc2f58447e727e /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-7dfc2f58447e727e* /

FROM rust AS src_lib_rs-lib-linux_raw_sys-67b8335e06167307
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--linux-raw-sys-0.3.1,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/linux-raw-sys-0.3.1 \
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
    if ! rustc '--crate-name' 'linux_raw_sys' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="errno"' '--cfg' 'feature="general"' '--cfg' 'feature="ioctl"' '--cfg' 'feature="no_std"' '-C' 'metadata=67b8335e06167307' '-C' 'extra-filename=-67b8335e06167307' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/linux-raw-sys-0.3.1/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-67b8335e06167307
COPY --from=src_lib_rs-lib-linux_raw_sys-67b8335e06167307 /stderr /
COPY --from=src_lib_rs-lib-linux_raw_sys-67b8335e06167307 /stdout /
FROM scratch AS out-67b8335e06167307
COPY --from=src_lib_rs-lib-linux_raw_sys-67b8335e06167307 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-67b8335e06167307* /

FROM rust AS src_lib_rs-lib-concolor_query-74e38d373bc944a9
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--concolor-query-0.3.3,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/concolor-query-0.3.3 \
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
    if ! rustc '--crate-name' 'concolor_query' '--edition' '2021' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=74e38d373bc944a9' '-C' 'extra-filename=-74e38d373bc944a9' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/concolor-query-0.3.3/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-74e38d373bc944a9
COPY --from=src_lib_rs-lib-concolor_query-74e38d373bc944a9 /stderr /
COPY --from=src_lib_rs-lib-concolor_query-74e38d373bc944a9 /stdout /
FROM scratch AS out-74e38d373bc944a9
COPY --from=src_lib_rs-lib-concolor_query-74e38d373bc944a9 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-74e38d373bc944a9* /

FROM rust AS src_lib_rs-lib-bitflags-f255a966af175049
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--bitflags-1.3.2,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/bitflags-1.3.2 \
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
    if ! rustc '--crate-name' 'bitflags' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '-C' 'metadata=f255a966af175049' '-C' 'extra-filename=-f255a966af175049' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/bitflags-1.3.2/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-f255a966af175049
COPY --from=src_lib_rs-lib-bitflags-f255a966af175049 /stderr /
COPY --from=src_lib_rs-lib-bitflags-f255a966af175049 /stdout /
FROM scratch AS out-f255a966af175049
COPY --from=src_lib_rs-lib-bitflags-f255a966af175049 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-f255a966af175049* /

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

FROM rust AS src_lib_rs-lib-concolor_override-305fddcda33650f6
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--concolor-override-1.0.0,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/concolor-override-1.0.0 \
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
    if ! rustc '--crate-name' 'concolor_override' '--edition' '2021' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=305fddcda33650f6' '-C' 'extra-filename=-305fddcda33650f6' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/concolor-override-1.0.0/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-305fddcda33650f6
COPY --from=src_lib_rs-lib-concolor_override-305fddcda33650f6 /stderr /
COPY --from=src_lib_rs-lib-concolor_override-305fddcda33650f6 /stdout /
FROM scratch AS out-305fddcda33650f6
COPY --from=src_lib_rs-lib-concolor_override-305fddcda33650f6 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-305fddcda33650f6* /

FROM rust AS src_lib_rs-lib-strsim-8ed1051e7e58e636
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--strsim-0.10.0,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/strsim-0.10.0 \
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
    if ! rustc '--crate-name' 'strsim' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=8ed1051e7e58e636' '-C' 'extra-filename=-8ed1051e7e58e636' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/strsim-0.10.0/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-8ed1051e7e58e636
COPY --from=src_lib_rs-lib-strsim-8ed1051e7e58e636 /stderr /
COPY --from=src_lib_rs-lib-strsim-8ed1051e7e58e636 /stdout /
FROM scratch AS out-8ed1051e7e58e636
COPY --from=src_lib_rs-lib-strsim-8ed1051e7e58e636 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-8ed1051e7e58e636* /

FROM rust AS src_lib_rs-lib-anstyle-3d9b242388653423
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--anstyle-0.3.5,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstyle-0.3.5 \
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
    if ! rustc '--crate-name' 'anstyle' '--edition' '2021' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '--cfg' 'feature="std"' '-C' 'metadata=3d9b242388653423' '-C' 'extra-filename=-3d9b242388653423' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstyle-0.3.5/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-3d9b242388653423
COPY --from=src_lib_rs-lib-anstyle-3d9b242388653423 /stderr /
COPY --from=src_lib_rs-lib-anstyle-3d9b242388653423 /stdout /
FROM scratch AS out-3d9b242388653423
COPY --from=src_lib_rs-lib-anstyle-3d9b242388653423 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-3d9b242388653423* /

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

FROM rust AS src_lib_rs-lib-io_lifetimes-36f41602071771e6
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--io-lifetimes-1.0.3,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3 \
  --mount=type=bind,from=out-9de7ca31dbbda4df,source=/liblibc-9de7ca31dbbda4df.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta \
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
    if ! rustc '--crate-name' 'io_lifetimes' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="close"' '--cfg' 'feature="default"' '--cfg' 'feature="libc"' '--cfg' 'feature="windows-sys"' '-C' 'metadata=36f41602071771e6' '-C' 'extra-filename=-36f41602071771e6' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta' '--cap-lints' 'allow' '--cfg' 'io_safety_is_in_std' '--cfg' 'panic_in_const_fn' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-36f41602071771e6
COPY --from=src_lib_rs-lib-io_lifetimes-36f41602071771e6 /stderr /
COPY --from=src_lib_rs-lib-io_lifetimes-36f41602071771e6 /stdout /
FROM scratch AS out-36f41602071771e6
COPY --from=src_lib_rs-lib-io_lifetimes-36f41602071771e6 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-36f41602071771e6* /

FROM rust AS src_lib_rs-lib-rustix-120609be99d53c6b
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--rustix-0.37.6,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6 \
  --mount=type=bind,from=out-f255a966af175049,source=/libbitflags-f255a966af175049.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libbitflags-f255a966af175049.rmeta \
  --mount=type=bind,from=out-36f41602071771e6,source=/libio_lifetimes-36f41602071771e6.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libio_lifetimes-36f41602071771e6.rmeta \
  --mount=type=bind,from=out-9de7ca31dbbda4df,source=/liblibc-9de7ca31dbbda4df.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta \
  --mount=type=bind,from=out-67b8335e06167307,source=/liblinux_raw_sys-67b8335e06167307.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblinux_raw_sys-67b8335e06167307.rmeta \
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
    if ! rustc '--crate-name' 'rustix' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="default"' '--cfg' 'feature="fs"' '--cfg' 'feature="io-lifetimes"' '--cfg' 'feature="libc"' '--cfg' 'feature="std"' '--cfg' 'feature="termios"' '--cfg' 'feature="use-libc-auxv"' '-C' 'metadata=120609be99d53c6b' '-C' 'extra-filename=-120609be99d53c6b' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--extern' 'bitflags=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libbitflags-f255a966af175049.rmeta' '--extern' 'io_lifetimes=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libio_lifetimes-36f41602071771e6.rmeta' '--extern' 'libc=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta' '--extern' 'linux_raw_sys=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblinux_raw_sys-67b8335e06167307.rmeta' '--cap-lints' 'allow' '--cfg' 'linux_raw' '--cfg' 'asm' '--cfg' 'linux_like' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-120609be99d53c6b
COPY --from=src_lib_rs-lib-rustix-120609be99d53c6b /stderr /
COPY --from=src_lib_rs-lib-rustix-120609be99d53c6b /stdout /
FROM scratch AS out-120609be99d53c6b
COPY --from=src_lib_rs-lib-rustix-120609be99d53c6b /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-120609be99d53c6b* /

FROM rust AS src_lib_rs-lib-is_terminal-4b94fef286899229
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--is-terminal-0.4.7,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/is-terminal-0.4.7 \
  --mount=type=bind,from=out-f255a966af175049,source=/libbitflags-f255a966af175049.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libbitflags-f255a966af175049.rmeta \
  --mount=type=bind,from=out-36f41602071771e6,source=/libio_lifetimes-36f41602071771e6.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libio_lifetimes-36f41602071771e6.rmeta \
  --mount=type=bind,from=out-9de7ca31dbbda4df,source=/liblibc-9de7ca31dbbda4df.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta \
  --mount=type=bind,from=out-67b8335e06167307,source=/liblinux_raw_sys-67b8335e06167307.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblinux_raw_sys-67b8335e06167307.rmeta \
  --mount=type=bind,from=out-120609be99d53c6b,source=/librustix-120609be99d53c6b.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/librustix-120609be99d53c6b.rmeta \
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
    if ! rustc '--crate-name' 'is_terminal' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=4b94fef286899229' '-C' 'extra-filename=-4b94fef286899229' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--extern' 'io_lifetimes=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libio_lifetimes-36f41602071771e6.rmeta' '--extern' 'rustix=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/librustix-120609be99d53c6b.rmeta' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/is-terminal-0.4.7/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-4b94fef286899229
COPY --from=src_lib_rs-lib-is_terminal-4b94fef286899229 /stderr /
COPY --from=src_lib_rs-lib-is_terminal-4b94fef286899229 /stdout /
FROM scratch AS out-4b94fef286899229
COPY --from=src_lib_rs-lib-is_terminal-4b94fef286899229 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-4b94fef286899229* /

FROM rust AS src_lib_rs-lib-clap_builder-02591a0046469edd
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
WORKDIR /home/pete/wefwefwef/buildxargs.git
RUN \
  --mount=type=bind,from=input_src_lib_rs--clap_builder-4.2.1,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1 \
  --mount=type=bind,from=out-47e0535dab3ef0d2,source=/libanstream-47e0535dab3ef0d2.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libanstream-47e0535dab3ef0d2.rmeta \
  --mount=type=bind,from=out-3d9b242388653423,source=/libanstyle-3d9b242388653423.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libanstyle-3d9b242388653423.rmeta \
  --mount=type=bind,from=out-0d4af9095c79189b,source=/libanstyle_parse-0d4af9095c79189b.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libanstyle_parse-0d4af9095c79189b.rmeta \
  --mount=type=bind,from=out-f255a966af175049,source=/libbitflags-f255a966af175049.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libbitflags-f255a966af175049.rmeta \
  --mount=type=bind,from=out-7dfc2f58447e727e,source=/libclap_lex-7dfc2f58447e727e.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libclap_lex-7dfc2f58447e727e.rmeta \
  --mount=type=bind,from=out-305fddcda33650f6,source=/libconcolor_override-305fddcda33650f6.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libconcolor_override-305fddcda33650f6.rmeta \
  --mount=type=bind,from=out-74e38d373bc944a9,source=/libconcolor_query-74e38d373bc944a9.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libconcolor_query-74e38d373bc944a9.rmeta \
  --mount=type=bind,from=out-36f41602071771e6,source=/libio_lifetimes-36f41602071771e6.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libio_lifetimes-36f41602071771e6.rmeta \
  --mount=type=bind,from=out-4b94fef286899229,source=/libis_terminal-4b94fef286899229.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libis_terminal-4b94fef286899229.rmeta \
  --mount=type=bind,from=out-9de7ca31dbbda4df,source=/liblibc-9de7ca31dbbda4df.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta \
  --mount=type=bind,from=out-67b8335e06167307,source=/liblinux_raw_sys-67b8335e06167307.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/liblinux_raw_sys-67b8335e06167307.rmeta \
  --mount=type=bind,from=out-120609be99d53c6b,source=/librustix-120609be99d53c6b.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/librustix-120609be99d53c6b.rmeta \
  --mount=type=bind,from=out-8ed1051e7e58e636,source=/libstrsim-8ed1051e7e58e636.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libstrsim-8ed1051e7e58e636.rmeta \
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
    if ! rustc '--crate-name' 'clap_builder' '--edition' '2021' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="color"' '--cfg' 'feature="error-context"' '--cfg' 'feature="help"' '--cfg' 'feature="std"' '--cfg' 'feature="suggestions"' '--cfg' 'feature="usage"' '-C' 'metadata=02591a0046469edd' '-C' 'extra-filename=-02591a0046469edd' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps' '--extern' 'anstream=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libanstream-47e0535dab3ef0d2.rmeta' '--extern' 'anstyle=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libanstyle-3d9b242388653423.rmeta' '--extern' 'bitflags=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libbitflags-f255a966af175049.rmeta' '--extern' 'clap_lex=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libclap_lex-7dfc2f58447e727e.rmeta' '--extern' 'strsim=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libstrsim-8ed1051e7e58e636.rmeta' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-02591a0046469edd
COPY --from=src_lib_rs-lib-clap_builder-02591a0046469edd /stderr /
COPY --from=src_lib_rs-lib-clap_builder-02591a0046469edd /stdout /
FROM scratch AS out-02591a0046469edd
COPY --from=src_lib_rs-lib-clap_builder-02591a0046469edd /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-02591a0046469edd* /
DOCKERFILE
  network = "none"
  output = ["/home/pete/wefwefwef/buildxargs.git/_target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
  platforms = ["local"]
  target = "out-02591a0046469edd"
}
target "stdio-02591a0046469edd" {
  inherits = ["out-02591a0046469edd"]
  output = ["/tmp/tmp.mn92GdgcQn"]
  target = "stdio-02591a0046469edd"
}
BAKEFILE
