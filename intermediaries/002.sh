		'-L' 'native=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out' \


docker --debug buildx bake --file=- <<EOF
target "out" {
	context = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20"
	contexts = {
		"deps" = "/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps",
		"input_src_lib_rs--ring-0.16.20" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20",
		"rust" = "docker-image://docker.io/library/rust:1.69.0-slim@sha256:8b85a8a6bf7ed968e24bab2eae6f390d2c9c8dbed791d3547fef584000f48f9e",
		"l_native" = "/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out",
	}
	dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS src_lib_rs-lib-ring-72f79beb1ea63933
WORKDIR /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps
ENV LD_LIBRARY_PATH='/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib'
ENV CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo'
ENV CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20'
ENV CARGO_PKG_VERSION='0.16.20'
ENV CARGO_PKG_VERSION_MAJOR='0'
ENV CARGO_PKG_VERSION_MINOR='16'
ENV CARGO_PKG_VERSION_PATCH='20'
ENV CARGO_PKG_VERSION_PRE=''
ENV CARGO_PKG_AUTHORS='Brian Smith <brian@briansmith.org>'
ENV CARGO_PKG_NAME='ring'
ENV CARGO_PKG_DESCRIPTION='Safe, fast, small crypto using Rust.'
ENV CARGO_PKG_HOMEPAGE=''
ENV CARGO_PKG_REPOSITORY='https://github.com/briansmith/ring'
ENV CARGO_PKG_LICENSE=''
ENV CARGO_PKG_LICENSE_FILE='LICENSE'
ENV CARGO_PKG_RUST_VERSION=''
ENV CARGO_CRATE_NAME='ring'
ENV CARGO_BIN_NAME=''
WORKDIR /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20
RUN \
  --mount=type=bind,from=l_native,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out \
    ls -lha /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704
RUN \
  --mount=type=bind,from=input_src_lib_rs--ring-0.16.20,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20 \
  --mount=type=bind,from=deps,source=/liblibc-5b5816ccdaf2f5f3.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta \
  --mount=type=bind,from=deps,source=/libonce_cell-385e74d8868073fc.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta \
  --mount=type=bind,from=deps,source=/libspin-ba7f384cfb4b159f.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta \
  --mount=type=bind,from=deps,source=/libuntrusted-ec41ab00ed225515.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta \
  --mount=type=bind,from=l_native,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out \
    if ! rustc '--crate-name' 'ring' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="alloc"' '--cfg' 'feature="default"' '--cfg' 'feature="dev_urandom_fallback"' '--cfg' 'feature="once_cell"' '-C' 'metadata=72f79beb1ea63933' '-C' 'extra-filename=-72f79beb1ea63933' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta' '--extern' 'once_cell=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta' '--extern' 'spin=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta' '--extern' 'untrusted=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' '-L' 'native=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out' '-l' 'static=ring-core' '-l' 'static=ring-test' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio
COPY --from=src_lib_rs-lib-ring-72f79beb1ea63933 /stderr /
COPY --from=src_lib_rs-lib-ring-72f79beb1ea63933 /stdout /
FROM scratch AS out
COPY --from=src_lib_rs-lib-ring-72f79beb1ea63933 /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/*-72f79beb1ea63933* /
DOCKERFILE
	network = "none"
	output = ["/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out"
}
target "stdio" {
	inherits = ["out"]
	output = ["/tmp/tmp.puywvCmcI5"]
	target = "stdio"
}
group "default" { targets = ["out", "stdio"] }
EOF


#13 DONE 1.8s

#17 [stdio context deps] load from client
#17 transferring deps: 181.11MB 1.5s done
#17 DONE 1.5s

#19 [out src_lib_rs-lib-ring-72f79beb1ea63933 3/4] RUN   --mount=type=bind,from=input_src_lib_rs--ring-0.16.20,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20   --mount=type=bind,from=deps,source=/liblibc-5b5816ccdaf2f5f3.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta   --mount=type=bind,from=deps,source=/libonce_cell-385e74d8868073fc.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta   --mount=type=bind,from=deps,source=/libspin-ba7f384cfb4b159f.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta   --mount=type=bind,from=deps,source=/libuntrusted-ec41ab00ed225515.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta     if ! rustc '--crate-name' 'ring' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="alloc"' '--cfg' 'feature="default"' '--cfg' 'feature="dev_urandom_fallback"' '--cfg' 'feature="once_cell"' '-C' 'metadata=72f79beb1ea63933' '-C' 'extra-filename=-72f79beb1ea63933' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta' '--extern' 'once_cell=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta' '--extern' 'spin=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta' '--extern' 'untrusted=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' '-L' 'native=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out' '-l' 'static=ring-core' '-l' 'static=ring-test' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
info: syncing channel updates for '1.69.0-x86_64-unknown-linux-gnu'
info: latest update on 2023-04-20, rust version 1.69.0 (84c898d65 2023-04-16)
info: downloading component 'rust-src'
info: installing component 'rust-src'
#19 1.668 ==> /stderr <==
#19 1.668 {"message":"unused doc comment","code":{"code":"unused_doc_comments","explanation":null},"level":"warning","spans":[{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/aead/chacha.rs","byte_start":3762,"byte_end":3989,"line_start":112,"line_end":120,"column_start":9,"column_end":10,"is_primary":false,"text":[{"text":"        extern \"C\" {","highlight_start":9,"highlight_end":21},{"text":"            fn GFp_ChaCha20_ctr32(","highlight_start":1,"highlight_end":35},{"text":"                out: *mut u8,","highlight_start":1,"highlight_end":30},{"text":"                in_: *const u8,","highlight_start":1,"highlight_end":32},{"text":"                in_len: c::size_t,","highlight_start":1,"highlight_end":35},{"text":"                key: &Key,","highlight_start":1,"highlight_end":27},{"text":"                first_iv: &Iv,","highlight_start":1,"highlight_end":31},{"text":"            );","highlight_start":1,"highlight_end":15},{"text":"        }","highlight_start":1,"highlight_end":10}],"label":"rustdoc does not generate documentation for extern blocks","suggested_replacement":null,"suggestion_applicability":null,"expansion":null},{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/aead/chacha.rs","byte_start":3664,"byte_end":3753,"line_start":110,"line_end":111,"column_start":9,"column_end":23,"is_primary":true,"text":[{"text":"        /// XXX: Although this takes an `Iv`, this actually uses it like a","highlight_start":9,"highlight_end":75},{"text":"        /// `Counter`.","highlight_start":1,"highlight_end":23}],"label":null,"suggested_replacement":null,"suggestion_applicability":null,"expansion":null}],"children":[{"message":"use `//` for a plain comment","code":null,"level":"help","spans":[],"children":[],"rendered":null},{"message":"`#[warn(unused_doc_comments)]` on by default","code":null,"level":"note","spans":[],"children":[],"rendered":null}],"rendered":"warning: unused doc comment\n   --> /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/aead/chacha.rs:110:9\n    |\n110 | /         /// XXX: Although this takes an `Iv`, this actually uses it like a\n111 | |         /// `Counter`.\n    | |______________________^\n112 | /         extern \"C\" {\n113 | |             fn GFp_ChaCha20_ctr32(\n114 | |                 out: *mut u8,\n115 | |                 in_: *const u8,\n...   |\n119 | |             );\n120 | |         }\n    | |_________- rustdoc does not generate documentation for extern blocks\n    |\n    = help: use `//` for a plain comment\n    = note: `#[warn(unused_doc_comments)]` on by default\n\n"}
#19 1.668 {"artifact":"/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/ring-72f79beb1ea63933.d","emit":"dep-info"}
#19 1.668 {"message":"field `cpu_features` is never read","code":{"code":"dead_code","explanation":null},"level":"warning","spans":[{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/digest.rs","byte_start":1507,"byte_end":1519,"line_start":38,"line_end":38,"column_start":19,"column_end":31,"is_primary":false,"text":[{"text":"pub(crate) struct BlockContext {","highlight_start":19,"highlight_end":31}],"label":"field in this struct","suggested_replacement":null,"suggestion_applicability":null,"expansion":null},{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/digest.rs","byte_start":1850,"byte_end":1862,"line_start":49,"line_end":49,"column_start":5,"column_end":17,"is_primary":true,"text":[{"text":"    cpu_features: cpu::Features,","highlight_start":5,"highlight_end":17}],"label":null,"suggested_replacement":null,"suggestion_applicability":null,"expansion":null}],"children":[{"message":"`BlockContext` has a derived impl for the trait `Clone`, but this is intentionally ignored during dead code analysis","code":null,"level":"note","spans":[],"children":[],"rendered":null},{"message":"`#[warn(dead_code)]` on by default","code":null,"level":"note","spans":[],"children":[],"rendered":null}],"rendered":"warning: field `cpu_features` is never read\n  --> /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/digest.rs:49:5\n   |\n38 | pub(crate) struct BlockContext {\n   |                   ------------ field in this struct\n...\n49 |     cpu_features: cpu::Features,\n   |     ^^^^^^^^^^^^\n   |\n   = note: `BlockContext` has a derived impl for the trait `Clone`, but this is intentionally ignored during dead code analysis\n   = note: `#[warn(dead_code)]` on by default\n\n"}
#19 1.668 {"artifact":"/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libring-72f79beb1ea63933.rmeta","emit":"metadata"}
#19 1.668 {"message":"could not find native static library `ring-core`, perhaps an -L flag is missing?","code":null,"level":"error","spans":[],"children":[],"rendered":"error: could not find native static library `ring-core`, perhaps an -L flag is missing?\n\n"}
#19 1.668 {"message":"aborting due to previous error; 2 warnings emitted","code":null,"level":"error","spans":[],"children":[],"rendered":"error: aborting due to previous error; 2 warnings emitted\n\n"}
#19 1.668 
#19 1.668 ==> /stdout <==
#19 ERROR: process "/bin/sh -c if ! rustc '--crate-name' 'ring' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature=\"alloc\"' '--cfg' 'feature=\"default\"' '--cfg' 'feature=\"dev_urandom_fallback\"' '--cfg' 'feature=\"once_cell\"' '-C' 'metadata=72f79beb1ea63933' '-C' 'extra-filename=-72f79beb1ea63933' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta' '--extern' 'once_cell=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta' '--extern' 'spin=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta' '--extern' 'untrusted=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' '-L' 'native=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out' '-l' 'static=ring-core' '-l' 'static=ring-test' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi" did not complete successfully: exit code: 1
------
 > [out src_lib_rs-lib-ring-72f79beb1ea63933 3/4] RUN   --mount=type=bind,from=input_src_lib_rs--ring-0.16.20,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20   --mount=type=bind,from=deps,source=/liblibc-5b5816ccdaf2f5f3.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta   --mount=type=bind,from=deps,source=/libonce_cell-385e74d8868073fc.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta   --mount=type=bind,from=deps,source=/libspin-ba7f384cfb4b159f.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta   --mount=type=bind,from=deps,source=/libuntrusted-ec41ab00ed225515.rmeta,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta     if ! rustc '--crate-name' 'ring' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature="alloc"' '--cfg' 'feature="default"' '--cfg' 'feature="dev_urandom_fallback"' '--cfg' 'feature="once_cell"' '-C' 'metadata=72f79beb1ea63933' '-C' 'extra-filename=-72f79beb1ea63933' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta' '--extern' 'once_cell=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta' '--extern' 'spin=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta' '--extern' 'untrusted=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' '-L' 'native=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out' '-l' 'static=ring-core' '-l' 'static=ring-test' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi:
#19 1.668 ==> /stderr <==
#19 1.668 {"message":"unused doc comment","code":{"code":"unused_doc_comments","explanation":null},"level":"warning","spans":[{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/aead/chacha.rs","byte_start":3762,"byte_end":3989,"line_start":112,"line_end":120,"column_start":9,"column_end":10,"is_primary":false,"text":[{"text":"        extern \"C\" {","highlight_start":9,"highlight_end":21},{"text":"            fn GFp_ChaCha20_ctr32(","highlight_start":1,"highlight_end":35},{"text":"                out: *mut u8,","highlight_start":1,"highlight_end":30},{"text":"                in_: *const u8,","highlight_start":1,"highlight_end":32},{"text":"                in_len: c::size_t,","highlight_start":1,"highlight_end":35},{"text":"                key: &Key,","highlight_start":1,"highlight_end":27},{"text":"                first_iv: &Iv,","highlight_start":1,"highlight_end":31},{"text":"            );","highlight_start":1,"highlight_end":15},{"text":"        }","highlight_start":1,"highlight_end":10}],"label":"rustdoc does not generate documentation for extern blocks","suggested_replacement":null,"suggestion_applicability":null,"expansion":null},{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/aead/chacha.rs","byte_start":3664,"byte_end":3753,"line_start":110,"line_end":111,"column_start":9,"column_end":23,"is_primary":true,"text":[{"text":"        /// XXX: Although this takes an `Iv`, this actually uses it like a","highlight_start":9,"highlight_end":75},{"text":"        /// `Counter`.","highlight_start":1,"highlight_end":23}],"label":null,"suggested_replacement":null,"suggestion_applicability":null,"expansion":null}],"children":[{"message":"use `//` for a plain comment","code":null,"level":"help","spans":[],"children":[],"rendered":null},{"message":"`#[warn(unused_doc_comments)]` on by default","code":null,"level":"note","spans":[],"children":[],"rendered":null}],"rendered":"warning: unused doc comment\n   --> /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/aead/chacha.rs:110:9\n    |\n110 | /         /// XXX: Although this takes an `Iv`, this actually uses it like a\n111 | |         /// `Counter`.\n    | |______________________^\n112 | /         extern \"C\" {\n113 | |             fn GFp_ChaCha20_ctr32(\n114 | |                 out: *mut u8,\n115 | |                 in_: *const u8,\n...   |\n119 | |             );\n120 | |         }\n    | |_________- rustdoc does not generate documentation for extern blocks\n    |\n    = help: use `//` for a plain comment\n    = note: `#[warn(unused_doc_comments)]` on by default\n\n"}
#19 1.668 {"artifact":"/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/ring-72f79beb1ea63933.d","emit":"dep-info"}
#19 1.668 {"message":"field `cpu_features` is never read","code":{"code":"dead_code","explanation":null},"level":"warning","spans":[{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/digest.rs","byte_start":1507,"byte_end":1519,"line_start":38,"line_end":38,"column_start":19,"column_end":31,"is_primary":false,"text":[{"text":"pub(crate) struct BlockContext {","highlight_start":19,"highlight_end":31}],"label":"field in this struct","suggested_replacement":null,"suggestion_applicability":null,"expansion":null},{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/digest.rs","byte_start":1850,"byte_end":1862,"line_start":49,"line_end":49,"column_start":5,"column_end":17,"is_primary":true,"text":[{"text":"    cpu_features: cpu::Features,","highlight_start":5,"highlight_end":17}],"label":null,"suggested_replacement":null,"suggestion_applicability":null,"expansion":null}],"children":[{"message":"`BlockContext` has a derived impl for the trait `Clone`, but this is intentionally ignored during dead code analysis","code":null,"level":"note","spans":[],"children":[],"rendered":null},{"message":"`#[warn(dead_code)]` on by default","code":null,"level":"note","spans":[],"children":[],"rendered":null}],"rendered":"warning: field `cpu_features` is never read\n  --> /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/digest.rs:49:5\n   |\n38 | pub(crate) struct BlockContext {\n   |                   ------------ field in this struct\n...\n49 |     cpu_features: cpu::Features,\n   |     ^^^^^^^^^^^^\n   |\n   = note: `BlockContext` has a derived impl for the trait `Clone`, but this is intentionally ignored during dead code analysis\n   = note: `#[warn(dead_code)]` on by default\n\n"}
#19 1.668 {"artifact":"/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libring-72f79beb1ea63933.rmeta","emit":"metadata"}
#19 1.668 {"message":"could not find native static library `ring-core`, perhaps an -L flag is missing?","code":null,"level":"error","spans":[],"children":[],"rendered":"error: could not find native static library `ring-core`, perhaps an -L flag is missing?\n\n"}
#19 1.668 {"message":"aborting due to previous error; 2 warnings emitted","code":null,"level":"error","spans":[],"children":[],"rendered":"error: aborting due to previous error; 2 warnings emitted\n\n"}
#19 1.668 
#19 1.668 ==> /stdout <==
------
ERROR: failed to solve: process "/bin/sh -c if ! rustc '--crate-name' 'ring' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'lib' '--emit' 'dep-info,metadata,link' '-C' 'embed-bitcode=no' '-C' 'debuginfo=2' '--cfg' 'feature=\"alloc\"' '--cfg' 'feature=\"default\"' '--cfg' 'feature=\"dev_urandom_fallback\"' '--cfg' 'feature=\"once_cell\"' '-C' 'metadata=72f79beb1ea63933' '-C' 'extra-filename=-72f79beb1ea63933' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '--extern' 'libc=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta' '--extern' 'once_cell=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta' '--extern' 'spin=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta' '--extern' 'untrusted=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' '-L' 'native=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out' '-l' 'static=ring-core' '-l' 'static=ring-test' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi" did not complete successfully: exit code: 1
2108  /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
github.com/docker/docker/vendor/github.com/moby/buildkit/executor/runcexecutor.exitError
	/go/src/github.com/docker/docker/vendor/github.com/moby/buildkit/executor/runcexecutor/executor.go:360
github.com/docker/docker/vendor/github.com/moby/buildkit/executor/runcexecutor.(*runcExecutor).Run

could not find native static library `ring-core`, perhaps an -L flag is missing?
code":null,"level":"error","spans":[],"children":[],"rendered":"
error: could not find native static library `ring-core`, perhaps an -L flag is missing?\n\n"}

101 0s ipam.git try-diesel-2 λ l target/debug/build/ring-8e0695998d44f704/out
total 3.2M
-rw-rw-r-- 1 pete pete 6.9K May  6 16:46 aesni-gcm-x86_64-elf.o
-rw-rw-r-- 1 pete pete 8.6K May  6 16:46 aesni-x86_64-elf.o
-rw-rw-r-- 1 pete pete 104K May  6 16:46 aes_nohw.o
-rw-rw-r-- 1 pete pete  51K May  6 16:46 chacha20_poly1305_x86_64-elf.o
-rw-rw-r-- 1 pete pete  12K May  6 16:46 chacha-x86_64-elf.o
-rw-rw-r-- 1 pete pete  66K May  6 16:46 constant_time_test.o
-rw-rw-r-- 1 pete pete  62K May  6 16:46 cpu-intel.o
-rw-rw-r-- 1 pete pete  58K May  6 16:46 crypto.o
-rw-rw-r-- 1 pete pete 218K May  6 16:46 curve25519.o
-rw-rw-r-- 1 pete pete 226K May  6 16:46 ecp_nistz256.o
-rw-rw-r-- 1 pete pete  61K May  6 16:46 ecp_nistz.o
-rw-rw-r-- 1 pete pete  62K May  6 16:46 gfp_p256.o
-rw-rw-r-- 1 pete pete  98K May  6 16:46 gfp_p384.o
-rw-rw-r-- 1 pete pete 8.5K May  6 16:46 ghash-x86_64-elf.o
-rw-rw-r-- 1 pete pete 1.6M May  6 16:46 libring-core.a  ############################
-rw-rw-r-- 1 pete pete  66K May  6 16:46 libring-test.a
-rw-rw-r-- 1 pete pete  85K May  6 16:46 limbs.o
-rw-rw-r-- 1 pete pete  55K May  6 16:46 mem.o
-rw-rw-r-- 1 pete pete  61K May  6 16:46 montgomery_inv.o
-rw-rw-r-- 1 pete pete  66K May  6 16:46 montgomery.o
-rw-rw-r-- 1 pete pete  26K May  6 16:46 p256-x86_64-asm-elf.o
-rw-rw-r-- 1 pete pete  58K May  6 16:46 poly1305.o
-rw-rw-r-- 1 pete pete 150K May  6 16:46 poly1305_vec.o
-rw-rw-r-- 1 pete pete  19K May  6 16:46 sha256-x86_64-elf.o
-rw-rw-r-- 1 pete pete  16K May  6 16:46 sha512-x86_64-elf.o
-rw-rw-r-- 1 pete pete 6.3K May  6 16:46 vpaes-x86_64-elf.o
-rw-rw-r-- 1 pete pete  21K May  6 16:46 x86_64-mont5-elf.o
-rw-rw-r-- 1 pete pete 8.1K May  6 16:46 x86_64-mont-elf.o

rustc \
	'--crate-name' 'ring' \
	'--edition' '2018' \
	'--error-format' 'json' \
	'--json' 'artifacts,future-incompat' \
	'--diagnostic-width' '211' \
	'--crate-type' 'lib' \
	'--emit' 'dep-info,metadata,link' \
		'-C' 'embed-bitcode=no' \
		'-C' 'debuginfo=2' \
	'--cfg' 'feature="alloc"' \
	'--cfg' 'feature="default"' \
	'--cfg' 'feature="dev_urandom_fallback"' \
	'--cfg' 'feature="once_cell"' \
		'-C' 'metadata=72f79beb1ea63933' \
		'-C' 'extra-filename=-72f79beb1ea63933' \
	'--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' \
		'-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' \
	'--extern' 'libc=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/liblibc-5b5816ccdaf2f5f3.rmeta' \
	'--extern' 'once_cell=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libonce_cell-385e74d8868073fc.rmeta' \
	'--extern' 'spin=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libspin-ba7f384cfb4b159f.rmeta' \
	'--extern' 'untrusted=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libuntrusted-ec41ab00ed225515.rmeta' \
	'--cap-lints' 'warn' \
		'-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' \
		'-L' 'native=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/build/ring-8e0695998d44f704/out' \
		'-l' 'static=ring-core' \
		'-l' 'static=ring-test' \
	/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/ring-0.16.20/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
