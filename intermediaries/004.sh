#19 1.735 {"message":"unresolved import `proc_macro`","code":{"code":"E0432","explanation":"An import was unresolved.\n\nErroneous code example:\n\n```compile_fail,E0432\nuse something::Foo; // error: unresolved import `something::Foo`.\n```\n\nIn Rust 2015, paths in `use` statements are relative to the crate root. To\nimport items relative to the current and parent modules, use the `self::` and\n`super::` prefixes, respectively.\n\nIn Rust 2018 or later, paths in `use` statements are relative to the current\nmodule unless they begin with the name of a crate or a literal `crate::`, in\nwhich case they start from the crate root. As in Rust 2015 code, the `self::`\nand `super::` prefixes refer to the current and parent modules respectively.\n\nAlso verify that you didn't misspell the import name and that the import exists\nin the module from where you tried to import it. Example:\n\n```\nuse self::something::Foo; // Ok.\n\nmod something {\n    pub struct Foo;\n}\n# fn main() {}\n```\n\nIf you tried to use a module from an external crate and are using Rust 2015,\nyou may have missed the `extern crate` declaration (which is usually placed in\nthe crate root):\n\n```edition2015\nextern crate core; // Required to use the `core` crate in Rust 2015.\n\nuse core::any;\n# fn main() {}\n```\n\nSince Rust 2018 the `extern crate` declaration is not required and\nyou can instead just `use` it:\n\n```edition2018\nuse core::any; // No extern crate required in Rust 2018.\n# fn main() {}\n```\n"},"level":"error","spans":[{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0/src/lib.rs","byte_start":4,"byte_end":14,"line_start":1,"line_end":1,"column_start":5,"column_end":15,"is_primary":true,"text":[{"text":"use proc_macro::TokenStream;","highlight_start":5,"highlight_end":15}],"label":"use of undeclared crate or module `proc_macro`","suggested_replacement":null,"suggestion_applicability":null,"expansion":null}],"children":[{"message":"there is a crate or module with a similar name","code":null,"level":"help","spans":[{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0/src/lib.rs","byte_start":4,"byte_end":14,"line_start":1,"line_end":1,"column_start":5,"column_end":15,"is_primary":true,"text":[{"text":"use proc_macro::TokenStream;","highlight_start":5,"highlight_end":15}],"label":null,"suggested_replacement":"proc_macro2","suggestion_applicability":"MaybeIncorrect","expansion":null}],"children":[],"rendered":null}],"rendered":"error[E0432]: unresolved import `proc_macro`\n --> /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0/src/lib.rs:1:5\n  |\n1 | use proc_macro::TokenStream;\n  |     ^^^^^^^^^^ use of undeclared crate or module `proc_macro`\n  |\nhelp: there is a crate or module with a similar name\n  |\n1 | use proc_macro2::TokenStream;\n  |     ~~~~~~~~~~~\n\n"}

rustc \
    --crate-name openssl_macros \
    --edition 2018 \
    --error-format json \
    --json artifacts,future-incompat \
    --diagnostic-width 211 \
    --crate-type proc-macro \
    --emit dep-info,link \
    -C prefer-dynamic \
    -C embed-bitcode=no \
    -C metadata=024d32b3f7af0a4f \
    -C extra-filename=-024d32b3f7af0a4f \
    --out-dir $PWD/target/debug/deps \
    -L dependency=$PWD/target/debug/deps \
    --extern proc_macro2=$PWD/target/debug/deps/libproc_macro2-f0f3215e1fedc347.rlib \
    --extern quote=$PWD/target/debug/deps/libquote-362da28f47bafdea.rlib \
    --extern syn=$PWD/target/debug/deps/libsyn-66dcc2de3ece399a.rlib \
    --cap-lints warn \
    -C link-arg=-Wl,--compress-debug-sections=zlib-gabi \
    $HOME/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0/src/lib.rs

docker --debug buildx bake --file=- <<EOF
target "out" {
	context = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0"
	contexts = {
		"input_src_lib_rs--openssl-macros-0.1.0" = "/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0",
		"deps" = "/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps",
		"rust" = "docker-image://docker.io/library/rust:1.69.0-slim@sha256:8b85a8a6bf7ed968e24bab2eae6f390d2c9c8dbed791d3547fef584000f48f9e",
	}
	dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS src_lib_rs-proc-macro-openssl_macros-024d32b3f7af0a4f
WORKDIR /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps
ENV LD_LIBRARY_PATH='/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib'
ENV CARGO='/home/pete/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/cargo'
ENV CARGO_MANIFEST_DIR='/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0'
ENV CARGO_PKG_VERSION='0.1.0'
ENV CARGO_PKG_VERSION_MAJOR='0'
ENV CARGO_PKG_VERSION_MINOR='1'
ENV CARGO_PKG_VERSION_PATCH='0'
ENV CARGO_PKG_VERSION_PRE=''
ENV CARGO_PKG_AUTHORS=''
ENV CARGO_PKG_NAME='openssl-macros'
ENV CARGO_PKG_DESCRIPTION='Internal macros used by the openssl crate.'
ENV CARGO_PKG_HOMEPAGE=''
ENV CARGO_PKG_REPOSITORY=''
ENV CARGO_PKG_LICENSE='MIT/Apache-2.0'
ENV CARGO_PKG_LICENSE_FILE=''
ENV CARGO_PKG_RUST_VERSION=''
ENV CARGO_CRATE_NAME='openssl_macros'
ENV CARGO_BIN_NAME=''
ENV OUT_DIR=''
WORKDIR /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0
RUN \
  --mount=type=bind,from=input_src_lib_rs--openssl-macros-0.1.0,target=/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0 \
  --mount=type=bind,from=deps,source=/libproc_macro2-f0f3215e1fedc347.rlib,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libproc_macro2-f0f3215e1fedc347.rlib \
  --mount=type=bind,from=deps,source=/libquote-362da28f47bafdea.rlib,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libquote-362da28f47bafdea.rlib \
  --mount=type=bind,from=deps,source=/libsyn-66dcc2de3ece399a.rlib,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libsyn-66dcc2de3ece399a.rlib \
  --mount=type=bind,from=deps,source=/libunicode_ident-2ce671412240cc57.rlib,target=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libunicode_ident-2ce671412240cc57.rlib \
    if ! rustc '--crate-name' 'openssl_macros' '--edition' '2018' '--error-format' 'json' '--json' 'artifacts,future-incompat' '--diagnostic-width' '211' '--crate-type' 'proc-macro' --extern proc_macro '--emit' 'dep-info,link' '-C' 'prefer-dynamic' '-C' 'embed-bitcode=no' '-C' 'metadata=024d32b3f7af0a4f' '-C' 'extra-filename=-024d32b3f7af0a4f' '--out-dir' '/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '-L' 'dependency=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps' '--extern' 'proc_macro2=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libproc_macro2-f0f3215e1fedc347.rlib' '--extern' 'quote=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libquote-362da28f47bafdea.rlib' '--extern' 'syn=/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/libsyn-66dcc2de3ece399a.rlib' '--cap-lints' 'warn' '-C' 'link-arg=-Wl,--compress-debug-sections=zlib-gabi' /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/openssl-macros-0.1.0/src/lib.rs >/stdout 2>/stderr; then head /std???; exit 1; fi
FROM scratch AS stdio
COPY --from=src_lib_rs-proc-macro-openssl_macros-024d32b3f7af0a4f /stderr /
COPY --from=src_lib_rs-proc-macro-openssl_macros-024d32b3f7af0a4f /stdout /
FROM scratch AS out
COPY --from=src_lib_rs-proc-macro-openssl_macros-024d32b3f7af0a4f /home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps/*-024d32b3f7af0a4f* /
DOCKERFILE
	network = "none"
	output = ["/home/pete/wefwefwef/network_products/ipam/ipam.git/target/debug/deps"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out"
}
target "stdio" {
	inherits = ["out"]
	output = ["/tmp/tmp.2p7W3b3m39"]
	target = "stdio"
}
group "default" { targets = ["out", "stdio"] }
EOF
