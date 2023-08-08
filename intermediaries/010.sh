docker --debug buildx bake --file=- out-3a3c4c4e240ecd05 <<BAKEFILE
target "out-3a3c4c4e240ecd05" {
	contexts = {
		"input_src_lib_rs--unicode-ident-1.0.5" = "/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/unicode-ident-1.0.5",
		"input_src_lib_rs--proc-macro2-1.0.56" = "/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/proc-macro2-1.0.56",
		"input_src_lib_rs--quote-1.0.26" = "/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/quote-1.0.26",
		"input_src_lib_rs--syn-2.0.13" = "/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/syn-2.0.13",
		"rust" = "docker-image://docker.io/library/rust:1.69.0-slim@sha256:8b85a8a6bf7ed968e24bab2eae6f390d2c9c8dbed791d3547fef584000f48f9e",
	}
	dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS src_lib_rs-lib-unicode_ident-c5ad04ff65641340
WORKDIR /home/pete/wefwefwef/buildxargs.git/target/debug/deps
WORKDIR /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/unicode-ident-1.0.5
RUN \
  --mount=type=bind,from=input_src_lib_rs--unicode-ident-1.0.5,target=/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/unicode-ident-1.0.5 \
    export LD_LIBRARY_PATH='/home/pete/wefwefwef/buildxargs.git/target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib' && \
    export CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo' && \
    export CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/unicode-ident-1.0.5' && \
    export CARGO_PKG_VERSION='1.0.5' && \
    export CARGO_PKG_VERSION_MAJOR='1' && \
    export CARGO_PKG_VERSION_MINOR='0' && \
    export CARGO_PKG_VERSION_PATCH='5' && \
    export CARGO_PKG_VERSION_PRE='' && \
    export CARGO_PKG_AUTHORS='David Tolnay <dtolnay@gmail.com>' && \
    export CARGO_PKG_NAME='unicode-ident' && \
    export CARGO_PKG_DESCRIPTION='Determine whether characters have the XID_Start or XID_Continue properties according to Unicode Standard Annex #31' && \
    export CARGO_PKG_HOMEPAGE='' && \
    export CARGO_PKG_REPOSITORY='https://github.com/dtolnay/unicode-ident' && \
    export CARGO_PKG_LICENSE='(MIT OR Apache-2.0) AND Unicode-DFS-2016' && \
    export CARGO_PKG_LICENSE_FILE='' && \
    export CARGO_PKG_RUST_VERSION='1.31' && \
    export CARGO_CRATE_NAME='unicode_ident' && \
    export CARGO_BIN_NAME='' && \
    export OUT_DIR='' && \
    if ! rustc '--crate-name' 'unicode_ident' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'metadata=c5ad04ff65641340' '-C' 'extra-filename=-c5ad04ff65641340' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/unicode-ident-1.0.5/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-c5ad04ff65641340
COPY --from=src_lib_rs-lib-unicode_ident-c5ad04ff65641340 /stderr /
COPY --from=src_lib_rs-lib-unicode_ident-c5ad04ff65641340 /stdout /
FROM scratch AS out-c5ad04ff65641340
COPY --from=src_lib_rs-lib-unicode_ident-c5ad04ff65641340 /home/pete/wefwefwef/buildxargs.git/target/debug/deps/*-c5ad04ff65641340* /

FROM rust AS src_lib_rs-lib-proc_macro2-ca5962e8ac7c3b7d
WORKDIR /home/pete/wefwefwef/buildxargs.git/target/debug/deps
WORKDIR /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/proc-macro2-1.0.56
RUN \
  --mount=type=bind,from=input_src_lib_rs--proc-macro2-1.0.56,target=/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/proc-macro2-1.0.56 \
  --mount=type=bind,from=crate-out,target=/home/pete/wefwefwef/buildxargs.git/target/debug/build/proc-macro2-e1ec23146614cd4a/out \
  --mount=type=bind,from=out-c5ad04ff65641340,source=/libunicode_ident-c5ad04ff65641340.rmeta,target=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libunicode_ident-c5ad04ff65641340.rmeta \
    export LD_LIBRARY_PATH='/home/pete/wefwefwef/buildxargs.git/target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib' && \
    export CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo' && \
    export CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/proc-macro2-1.0.56' && \
    export CARGO_PKG_VERSION='1.0.56' && \
    export CARGO_PKG_VERSION_MAJOR='1' && \
    export CARGO_PKG_VERSION_MINOR='0' && \
    export CARGO_PKG_VERSION_PATCH='56' && \
    export CARGO_PKG_VERSION_PRE='' && \
    export CARGO_PKG_AUTHORS='David Tolnay <dtolnay@gmail.com>:Alex Crichton <alex@alexcrichton.com>' && \
    export CARGO_PKG_NAME='proc-macro2' && \
    export CARGO_PKG_DESCRIPTION='A substitute implementation of the compilers proc_macro API to decouple token-based libraries from the procedural macro use case.' && \
    export CARGO_PKG_HOMEPAGE='' && \
    export CARGO_PKG_REPOSITORY='https://github.com/dtolnay/proc-macro2' && \
    export CARGO_PKG_LICENSE='MIT OR Apache-2.0' && \
    export CARGO_PKG_LICENSE_FILE='' && \
    export CARGO_PKG_RUST_VERSION='1.31' && \
    export CARGO_CRATE_NAME='proc_macro2' && \
    export CARGO_BIN_NAME='' && \
    export OUT_DIR='/home/pete/wefwefwef/buildxargs.git/target/debug/build/proc-macro2-e1ec23146614cd4a/out' && \
    if ! rustc '--crate-name' 'proc_macro2' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '--cfg' 'feature="default"' '--cfg' 'feature="proc-macro"' '-C' 'metadata=ca5962e8ac7c3b7d' '-C' 'extra-filename=-ca5962e8ac7c3b7d' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--extern' 'unicode_ident=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libunicode_ident-c5ad04ff65641340.rmeta' '--cap-lints' 'allow' '--cfg' 'use_proc_macro' '--cfg' 'wrap_proc_macro' /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/proc-macro2-1.0.56/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-ca5962e8ac7c3b7d
COPY --from=src_lib_rs-lib-proc_macro2-ca5962e8ac7c3b7d /stderr /
COPY --from=src_lib_rs-lib-proc_macro2-ca5962e8ac7c3b7d /stdout /
FROM scratch AS out-ca5962e8ac7c3b7d
COPY --from=src_lib_rs-lib-proc_macro2-ca5962e8ac7c3b7d /home/pete/wefwefwef/buildxargs.git/target/debug/deps/*-ca5962e8ac7c3b7d* /

FROM rust AS src_lib_rs-lib-quote-ccc7b91213ce76b5
WORKDIR /home/pete/wefwefwef/buildxargs.git/target/debug/deps
WORKDIR /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/quote-1.0.26
RUN \
  --mount=type=bind,from=input_src_lib_rs--quote-1.0.26,target=/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/quote-1.0.26 \
  --mount=type=bind,from=crate-out,target=/home/pete/wefwefwef/buildxargs.git/target/debug/build/quote-adce79444856d618/out \
  --mount=type=bind,from=out-ca5962e8ac7c3b7d,source=/libproc_macro2-ca5962e8ac7c3b7d.rmeta,target=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libproc_macro2-ca5962e8ac7c3b7d.rmeta \
  --mount=type=bind,from=out-c5ad04ff65641340,source=/libunicode_ident-c5ad04ff65641340.rmeta,target=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libunicode_ident-c5ad04ff65641340.rmeta \
    export LD_LIBRARY_PATH='/home/pete/wefwefwef/buildxargs.git/target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib' && \
    export CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo' && \
    export CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/quote-1.0.26' && \
    export CARGO_PKG_VERSION='1.0.26' && \
    export CARGO_PKG_VERSION_MAJOR='1' && \
    export CARGO_PKG_VERSION_MINOR='0' && \
    export CARGO_PKG_VERSION_PATCH='26' && \
    export CARGO_PKG_VERSION_PRE='' && \
    export CARGO_PKG_AUTHORS='David Tolnay <dtolnay@gmail.com>' && \
    export CARGO_PKG_NAME='quote' && \
    export CARGO_PKG_DESCRIPTION='Quasi-quoting macro quote!(...)' && \
    export CARGO_PKG_HOMEPAGE='' && \
    export CARGO_PKG_REPOSITORY='https://github.com/dtolnay/quote' && \
    export CARGO_PKG_LICENSE='MIT OR Apache-2.0' && \
    export CARGO_PKG_LICENSE_FILE='' && \
    export CARGO_PKG_RUST_VERSION='1.31' && \
    export CARGO_CRATE_NAME='quote' && \
    export CARGO_BIN_NAME='' && \
    export OUT_DIR='/home/pete/wefwefwef/buildxargs.git/target/debug/build/quote-adce79444856d618/out' && \
    if ! rustc '--crate-name' 'quote' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '--cfg' 'feature="default"' '--cfg' 'feature="proc-macro"' '-C' 'metadata=ccc7b91213ce76b5' '-C' 'extra-filename=-ccc7b91213ce76b5' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--extern' 'proc_macro2=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libproc_macro2-ca5962e8ac7c3b7d.rmeta' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/quote-1.0.26/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-ccc7b91213ce76b5
COPY --from=src_lib_rs-lib-quote-ccc7b91213ce76b5 /stderr /
COPY --from=src_lib_rs-lib-quote-ccc7b91213ce76b5 /stdout /
FROM scratch AS out-ccc7b91213ce76b5
COPY --from=src_lib_rs-lib-quote-ccc7b91213ce76b5 /home/pete/wefwefwef/buildxargs.git/target/debug/deps/*-ccc7b91213ce76b5* /

FROM rust AS src_lib_rs-lib-syn-3a3c4c4e240ecd05
WORKDIR /home/pete/wefwefwef/buildxargs.git/target/debug/deps
WORKDIR /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/syn-2.0.13
RUN \
  --mount=type=bind,from=input_src_lib_rs--syn-2.0.13,target=/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/syn-2.0.13 \
  --mount=type=bind,from=out-ca5962e8ac7c3b7d,source=/libproc_macro2-ca5962e8ac7c3b7d.rmeta,target=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libproc_macro2-ca5962e8ac7c3b7d.rmeta \
  --mount=type=bind,from=out-ccc7b91213ce76b5,source=/libquote-ccc7b91213ce76b5.rmeta,target=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libquote-ccc7b91213ce76b5.rmeta \
  --mount=type=bind,from=out-c5ad04ff65641340,source=/libunicode_ident-c5ad04ff65641340.rmeta,target=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libunicode_ident-c5ad04ff65641340.rmeta \
    export LD_LIBRARY_PATH='/home/pete/wefwefwef/buildxargs.git/target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib' && \
    export CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo' && \
    export CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/syn-2.0.13' && \
    export CARGO_PKG_VERSION='2.0.13' && \
    export CARGO_PKG_VERSION_MAJOR='2' && \
    export CARGO_PKG_VERSION_MINOR='0' && \
    export CARGO_PKG_VERSION_PATCH='13' && \
    export CARGO_PKG_VERSION_PRE='' && \
    export CARGO_PKG_AUTHORS='David Tolnay <dtolnay@gmail.com>' && \
    export CARGO_PKG_NAME='syn' && \
    export CARGO_PKG_DESCRIPTION='Parser for Rust source code' && \
    export CARGO_PKG_HOMEPAGE='' && \
    export CARGO_PKG_REPOSITORY='https://github.com/dtolnay/syn' && \
    export CARGO_PKG_LICENSE='MIT OR Apache-2.0' && \
    export CARGO_PKG_LICENSE_FILE='' && \
    export CARGO_PKG_RUST_VERSION='1.56' && \
    export CARGO_CRATE_NAME='syn' && \
    export CARGO_BIN_NAME='' && \
    export OUT_DIR='' && \
    if ! rustc '--crate-name' 'syn' '--edition' '2021' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '--cfg' 'feature="clone-impls"' '--cfg' 'feature="default"' '--cfg' 'feature="derive"' '--cfg' 'feature="full"' '--cfg' 'feature="parsing"' '--cfg' 'feature="printing"' '--cfg' 'feature="proc-macro"' '--cfg' 'feature="quote"' '-C' 'metadata=3a3c4c4e240ecd05' '-C' 'extra-filename=-3a3c4c4e240ecd05' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--extern' 'proc_macro2=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libproc_macro2-ca5962e8ac7c3b7d.rmeta' '--extern' 'quote=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libquote-ccc7b91213ce76b5.rmeta' '--extern' 'unicode_ident=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libunicode_ident-c5ad04ff65641340.rmeta' '--cap-lints' 'allow' /home/pete/.cargo/registry/src/index.crates.io-6f17d22bba15001f/syn-2.0.13/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-3a3c4c4e240ecd05
COPY --from=src_lib_rs-lib-syn-3a3c4c4e240ecd05 /stderr /
COPY --from=src_lib_rs-lib-syn-3a3c4c4e240ecd05 /stdout /
FROM scratch AS out-3a3c4c4e240ecd05
COPY --from=src_lib_rs-lib-syn-3a3c4c4e240ecd05 /home/pete/wefwefwef/buildxargs.git/target/debug/deps/*-3a3c4c4e240ecd05* /
DOCKERFILE
	network = "none"
	output = ["/home/pete/wefwefwef/buildxargs.git/target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out-3a3c4c4e240ecd05"
}
target "stdio-3a3c4c4e240ecd05" {
	inherits = ["out-3a3c4c4e240ecd05"]
	output = ["/tmp/tmp.rV7ia6Lwlz"]
	target = "stdio-3a3c4c4e240ecd05"
}
BAKEFILE
