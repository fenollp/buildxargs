docker --debug buildx bake --file=- out-43c37df2a93a7b76 stdio-43c37df2a93a7b76 <<EOF
target "out-43c37df2a93a7b76" {
	contexts = {
		"input_src_lib_rs--dashmap-5.4.0" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/dashmap-5.4.0",
		"tmpdeps" = "/tmp/tmp.3uszkWIVcM",
		"rust" = "docker-image://rustc_with_libs",
	}
	dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14
FROM rust AS toolchain-43c37df2a93a7b76
RUN rustup default | cut -d- -f1 >/rustup-toolchain
FROM rust AS src_lib_rs-lib-dashmap-43c37df2a93a7b76
WORKDIR /home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps
WORKDIR /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/dashmap-5.4.0
RUN \
  --mount=type=bind,from=input_src_lib_rs--dashmap-5.4.0,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/dashmap-5.4.0 \
  --mount=type=bind,from=toolchain-43c37df2a93a7b76,source=/rustup-toolchain,target=/rustup-toolchain \
  --mount=type=bind,from=tmpdeps,source=/libahash-f7805a3913c4351f.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libahash-f7805a3913c4351f.rmeta \
  --mount=type=bind,from=tmpdeps,source=/libcfg_if-e5e118dd7d121aaa.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libcfg_if-e5e118dd7d121aaa.rmeta \
  --mount=type=bind,from=tmpdeps,source=/libgetrandom-348636e17225792a.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libgetrandom-348636e17225792a.rmeta \
  --mount=type=bind,from=tmpdeps,source=/libhashbrown-95c6b3600ac95da2.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libhashbrown-95c6b3600ac95da2.rmeta \
  --mount=type=bind,from=tmpdeps,source=/liblibc-5b5816ccdaf2f5f3.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta \
  --mount=type=bind,from=tmpdeps,source=/liblock_api-68f9f4627da435ce.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/liblock_api-68f9f4627da435ce.rmeta \
  --mount=type=bind,from=tmpdeps,source=/libonce_cell-385e74d8868073fc.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libonce_cell-385e74d8868073fc.rmeta \
  --mount=type=bind,from=tmpdeps,source=/libparking_lot_core-3f57645370573b1a.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libparking_lot_core-3f57645370573b1a.rmeta \
  --mount=type=bind,from=tmpdeps,source=/libscopeguard-f471875f675163b5.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libscopeguard-f471875f675163b5.rmeta \
  --mount=type=bind,from=tmpdeps,source=/libsmallvec-22f2447eab0ca59b.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libsmallvec-22f2447eab0ca59b.rmeta \
    export LD_LIBRARY_PATH='/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib' && \
    export CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo' && \
    export CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/dashmap-5.4.0' && \
    export CARGO_PKG_VERSION='5.4.0' && \
    export CARGO_PKG_VERSION_MAJOR='5' && \
    export CARGO_PKG_VERSION_MINOR='4' && \
    export CARGO_PKG_VERSION_PATCH='0' && \
    export CARGO_PKG_VERSION_PRE='' && \
    export CARGO_PKG_AUTHORS='Acrimon <joel.wejdenstal@gmail.com>' && \
    export CARGO_PKG_NAME='dashmap' && \
    export CARGO_PKG_DESCRIPTION='Blazing fast concurrent HashMap for Rust.' && \
    export CARGO_PKG_HOMEPAGE='https://github.com/xacrimon/dashmap' && \
    export CARGO_PKG_REPOSITORY='https://github.com/xacrimon/dashmap' && \
    export CARGO_PKG_LICENSE='MIT' && \
    export CARGO_PKG_LICENSE_FILE='' && \
    export CARGO_PKG_RUST_VERSION='1.59' && \
    export CARGO_CRATE_NAME='dashmap' && \
    export CARGO_BIN_NAME='' && \
    export OUT_DIR='' && \
    export RUSTUP_TOOLCHAIN="$(cat /rustup-toolchain)" && \
    if ! rustc '--crate-name' 'dashmap' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '-C' 'metadata=43c37df2a93a7b76' '-C' 'extra-filename=-43c37df2a93a7b76' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps' '--extern' 'cfg_if=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libcfg_if-e5e118dd7d121aaa.rmeta' '--extern' 'hashbrown=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libhashbrown-95c6b3600ac95da2.rmeta' '--extern' 'lock_api=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/liblock_api-68f9f4627da435ce.rmeta' '--extern' 'once_cell=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libonce_cell-385e74d8868073fc.rmeta' '--extern' 'parking_lot_core=/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/libparking_lot_core-3f57645370573b1a.rmeta' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/dashmap-5.4.0/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio-43c37df2a93a7b76
COPY --from=src_lib_rs-lib-dashmap-43c37df2a93a7b76 /stderr /
COPY --from=src_lib_rs-lib-dashmap-43c37df2a93a7b76 /stdout /
FROM scratch AS out-43c37df2a93a7b76
COPY --from=src_lib_rs-lib-dashmap-43c37df2a93a7b76 /home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps/*-43c37df2a93a7b76* /
DOCKERFILE
	network = "none"
	output = ["/home/pete/wefwefwef/network_products/ipam/ipam.git/_target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out-43c37df2a93a7b76"
}
target "stdio-43c37df2a93a7b76" {
	inherits = ["out-43c37df2a93a7b76"]
	output = ["/tmp/tmp.fECKLbQpty"]
	target = "stdio-43c37df2a93a7b76"
}
EOF
