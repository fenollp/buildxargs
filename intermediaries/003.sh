# /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/rustversion-ae69baa7face5565/out/version.expr

docker --debug buildx bake --file=- <<EOF
target "out" {
	context = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustversion-1.0.9"
	contexts = {
		"rust" = "docker-image://docker.io/library/rust:1.69.0-slim@sha256:8b85a8a6bf7ed968e24bab2eae6f390d2c9c8dbed791d3547fef584000f48f9e",
		"input_src_lib_rs--rustversion-1.0.9" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustversion-1.0.9",
		"crate_out" = "/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/rustversion-ae69baa7face5565/out",
	}
	dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS src_lib_rs-proc-macro-rustversion-9d84a325ffa285b4
WORKDIR /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps
ENV LD_LIBRARY_PATH='/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib'
ENV CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo'
ENV CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustversion-1.0.9'
ENV CARGO_PKG_VERSION='1.0.9'
ENV CARGO_PKG_VERSION_MAJOR='1'
ENV CARGO_PKG_VERSION_MINOR='0'
ENV CARGO_PKG_VERSION_PATCH='9'
ENV CARGO_PKG_VERSION_PRE=''
ENV CARGO_PKG_AUTHORS='David Tolnay <dtolnay@gmail.com>'
ENV CARGO_PKG_NAME='rustversion'
ENV CARGO_PKG_DESCRIPTION='Conditional compilation according to rustc compiler version'
ENV CARGO_PKG_HOMEPAGE=''
ENV CARGO_PKG_REPOSITORY='https://github.com/dtolnay/rustversion'
ENV CARGO_PKG_LICENSE='MIT OR Apache-2.0'
ENV CARGO_PKG_LICENSE_FILE=''
ENV CARGO_PKG_RUST_VERSION='1.31'
ENV CARGO_CRATE_NAME='rustversion'
ENV CARGO_BIN_NAME=''
ENV OUT_DIR='/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/rustversion-ae69baa7face5565/out'
WORKDIR /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustversion-1.0.9
RUN \
  --mount=type=bind,from=input_src_lib_rs--rustversion-1.0.9,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustversion-1.0.9 \
  --mount=type=bind,from=crate_out,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/rustversion-ae69baa7face5565/out \
    if ! rustc '--crate-name' 'rustversion' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'proc-macro' '--emit' 'dep-info,link' '-C' 'prefer-dynamic' '-C' 'embed-bitcode=no' '-C' 'metadata=9d84a325ffa285b4' '-C' 'extra-filename=-9d84a325ffa285b4' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustversion-1.0.9/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio
COPY --from=src_lib_rs-proc-macro-rustversion-9d84a325ffa285b4 /stderr /
COPY --from=src_lib_rs-proc-macro-rustversion-9d84a325ffa285b4 /stdout /
FROM scratch AS out
COPY --from=src_lib_rs-proc-macro-rustversion-9d84a325ffa285b4 /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/*-9d84a325ffa285b4* /
DOCKERFILE
	network = "none"
	output = ["/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out"
}
target "stdio" {
	inherits = ["out"]
	output = ["/tmp/tmp.gnzG5Vh3nr"]
	target = "stdio"
}
group "default" { targets = ["out", "stdio"] }
EOF
