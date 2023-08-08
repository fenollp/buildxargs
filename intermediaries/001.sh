docker --debug buildx bake --file=- <<EOF
target "out" {
  context = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3"
  contexts = {
    "deps" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/target/debug/deps",
    "input_src_lib_rs--io-lifetimes-1.0.3" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3",
    "rust" = "docker-image://docker.io/library/rust:1.69.0-slim@sha256:8b85a8a6bf7ed968e24bab2eae6f390d2c9c8dbed791d3547fef584000f48f9e",
  }
  dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS src_lib_rs-lib-io_lifetimes-0b17ea65ba6847a5
WORKDIR /home/pete/wefwefwef/buildxargs.git/target/debug/deps
WORKDIR /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3
RUN \
  --mount=type=bind,from=input_src_lib_rs--io-lifetimes-1.0.3,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3 \
  --mount=type=bind,from=deps,source=/liblibc-b3921bff615d742a.rmeta,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/target/debug/deps/liblibc-b3921bff615d742a.rmeta \
    if ! rustc '--crate-name' 'io_lifetimes' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '318' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="close"' '--cfg' 'feature="default"' '--cfg' 'feature="libc"' '--cfg' 'feature="windows-sys"' '-C' 'metadata=0b17ea65ba6847a5' '-C' 'extra-filename=-0b17ea65ba6847a5' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/liblibc-b3921bff615d742a.rmeta' '--cap-lints' 'allow' '--cfg' 'io_safety_is_in_std' '--cfg' 'panic_in_const_fn' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio
COPY --from=src_lib_rs-lib-io_lifetimes-0b17ea65ba6847a5 /stderr /
COPY --from=src_lib_rs-lib-io_lifetimes-0b17ea65ba6847a5 /stdout /
FROM scratch AS out
COPY --from=src_lib_rs-lib-io_lifetimes-0b17ea65ba6847a5 /home/pete/wefwefwef/buildxargs.git/target/debug/deps/*-0b17ea65ba6847a5* /
DOCKERFILE
  network = "none"
  output = ["/home/pete/wefwefwef/buildxargs.git/target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
  platforms = ["local"]
  target = "out"
}
target "stdio" {
  inherits = ["out"]
  output = ["/tmp/tmp.Q1sS648ZuM"]
  target = "stdio"
}
group "default" { targets = ["out", "stdio"] }
EOF



#17 [out src_lib_rs-lib-io_lifetimes-0b17ea65ba6847a5 3/4] RUN   --mount=type=bind,from=input_src_lib_rs--io-lifetimes-1.0.3,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3   --mount=type=bind,from=deps,source=/liblibc-b3921bff615d742a.rmeta,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/target/debug/deps/liblibc-b3921bff615d742a.rmeta     if ! rustc '--crate-name' 'io_lifetimes' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '318' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="close"' '--cfg' 'feature="default"' '--cfg' 'feature="libc"' '--cfg' 'feature="windows-sys"' '-C' 'metadata=0b17ea65ba6847a5' '-C' 'extra-filename=-0b17ea65ba6847a5' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/liblibc-b3921bff615d742a.rmeta' '--cap-lints' 'allow' '--cfg' 'io_safety_is_in_std' '--cfg' 'panic_in_const_fn' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
#17 ERROR: failed to calculate checksum of ref moby::yb4w3ulwhlggwupxc5cmh9p5j: "/liblibc-b3921bff615d742a.rmeta": not found

#18 [stdio context input_src_lib_rs--io-lifetimes-1.0.3] load from client
#18 transferring input_src_lib_rs--io-lifetimes-1.0.3: 472B done
#18 ERROR: rpc error: code = Unavailable desc = error reading from server: read unix /run/docker.sock->@: read: connection reset by peer

#19 [stdio context deps] load from client
#19 transferring deps: 2B done
#19 DONE 0.0s
------
 > [stdio context input_src_lib_rs--io-lifetimes-1.0.3] load from client:
------
------
 > [out src_lib_rs-lib-io_lifetimes-0b17ea65ba6847a5 3/4] RUN   --mount=type=bind,from=input_src_lib_rs--io-lifetimes-1.0.3,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3   --mount=type=bind,from=deps,source=/liblibc-b3921bff615d742a.rmeta,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/target/debug/deps/liblibc-b3921bff615d742a.rmeta     if ! rustc '--crate-name' 'io_lifetimes' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '318' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="close"' '--cfg' 'feature="default"' '--cfg' 'feature="libc"' '--cfg' 'feature="windows-sys"' '-C' 'metadata=0b17ea65ba6847a5' '-C' 'extra-filename=-0b17ea65ba6847a5' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/liblibc-b3921bff615d742a.rmeta' '--cap-lints' 'allow' '--cfg' 'io_safety_is_in_std' '--cfg' 'panic_in_const_fn' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi:
------
Dockerfile:6
--------------------
   5 |     WORKDIR /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3
   6 | >>> RUN \
   7 | >>>   --mount=type=bind,from=input_src_lib_rs--io-lifetimes-1.0.3,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3 \
   8 | >>>   --mount=type=bind,from=deps,source=/liblibc-b3921bff615d742a.rmeta,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/target/debug/deps/liblibc-b3921bff615d742a.rmeta \
   9 | >>>     if ! rustc '--crate-name' 'io_lifetimes' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '318' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="close"' '--cfg' 'feature="default"' '--cfg' 'feature="libc"' '--cfg' 'feature="windows-sys"' '-C' 'metadata=0b17ea65ba6847a5' '-C' 'extra-filename=-0b17ea65ba6847a5' '--out-dir' '/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/liblibc-b3921bff615d742a.rmeta' '--cap-lints' 'allow' '--cfg' 'io_safety_is_in_std' '--cfg' 'panic_in_const_fn' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
  10 |     FROM scratch AS stdio
--------------------
ERROR: failed to solve: failed to compute cache key: failed to calculate checksum of ref moby::yb4w3ulwhlggwupxc5cmh9p5j: "/liblibc-b3921bff615d742a.rmeta": not found
2861  /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
github.com/docker/docker/vendor/github.com/moby/buildkit/cache/contenthash.init
  /go/src/github.com/docker/docker/vendor/github.com/moby/buildkit/cache/contenthash/checksum.go:27
runtime.doInit
  /usr/local/go/src/runtime/proc.go:6329
runtime.doInit
  /usr/local/go/src/runtime/proc.go:6306
runtime.doInit
  /usr/local/go/src/runtime/proc.go:6306
runtime.doInit
  /usr/local/go/src/runtime/proc.go:6306
