#!/bin/bash -eux
# trash _target; shellcheck ./tryin.sh && ./tryin.sh && \tree _target

PROFILE=${PROFILE:-debug}
CARGO_HOME=${CARGO_HOME:-$HOME/.cargo}
CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-$PWD/_target}

mkdir -p "$CARGO_HOME/git/db"
mkdir -p "$CARGO_HOME/git/checkouts"
mkdir -p "$CARGO_HOME/registry/index"
mkdir -p "$CARGO_HOME/registry/cache"
mkdir -p "$CARGO_HOME/registry/src"
mkdir -p "$CARGO_TARGET_DIR/$PROFILE/deps"

ensure() {
	h=$(tar -cf- --directory="$PWD" --sort=name --mtime='UTC 2023-04-15' --group=0 --owner=0 --numeric-owner "$(basename "$CARGO_TARGET_DIR")" | sha256sum)
	[[ "$h" = "$1  -" ]]
}

rustc() {
	local args=()
	local src
	local key=''; local val=''; local pair=''
	for arg in "$@"; do
		case "$pair" in
			'' ) pair=S; key=$arg; [[ "$arg" = '--crate-name' ]] || exit 4 ;;
			'E') pair=S; key=$arg; val=''   ;; # start
			'S') pair=E;           val=$arg ;; # end
		esac
		if [[ "$pair $val" = 'S ' ]] && [[ "$arg" =~ --.+=.+ ]]; then
			pair=E; key=${arg%=*}; val=${arg#*=}
		fi
		if [[ "${key:0:1}" = '/' ]]; then
			src=$key
			pair=E; key=''; val=''
			continue
		fi

		if [[ "$key $val" = '-C link-arg=-fuse-ld=/usr/local/bin/mold' ]]; then
			pair=E; key=''; val=''
			continue
		fi

		[[ -z "$val" ]] && continue
		args+=("$key" "$val")
	done

	[[ -z "${src:-}" ]] && exit 4
	/home/pete/.cargo/bin/rustc "${args[@]}" "$src"
}

rustc --crate-name libc \
  "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs" \
	--error-format=json \
	--json=diagnostic-rendered-ansi,artifacts,future-incompat \
	--diagnostic-width=105 \
	--crate-type lib \
	--emit=dep-info,metadata,link \
	-C embed-bitcode=no \
	-C debuginfo=2 \
	--cfg 'feature="default"' \
	--cfg 'feature="extra_traits"' \
	--cfg 'feature="std"' \
	-C metadata=9de7ca31dbbda4df \
	-C extra-filename=-9de7ca31dbbda4df \
	--out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" \
	-C linker=/usr/bin/clang \
	-L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" \
	--cap-lints allow \
	-C link-arg=-fuse-ld=/usr/local/bin/mold \
	--cfg freebsd11 \
	--cfg libc_priv_mod_use \
	--cfg libc_union \
	--cfg libc_const_size_of \
	--cfg libc_align \
	--cfg libc_int128 \
	--cfg libc_core_cvoid \
	--cfg libc_packedN \
	--cfg libc_cfg_target_vendor \
	--cfg libc_non_exhaustive \
	--cfg libc_long_array \
	--cfg libc_ptr_addr_of \
	--cfg libc_underscore_const_names \
	--cfg libc_const_extern_fn
# STDERR:
# {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/libc-9de7ca31dbbda4df.d","emit":"dep-info"}
# {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/liblibc-9de7ca31dbbda4df.rmeta","emit":"metadata"}
# {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/liblibc-9de7ca31dbbda4df.rlib","emit":"link"}
ensure 4f3aa5134e2db0871e050d2916083f84ed02951067ae55137b5df83375edcd13

rustc --crate-name io_lifetimes \
	--edition=2018 \
	"$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs" \
	--error-format=json \
	--json=diagnostic-rendered-ansi,artifacts,future-incompat \
	--diagnostic-width=105 \
	--crate-type lib \
	--emit=dep-info,metadata,link \
	-C embed-bitcode=no \
	-C debuginfo=2 \
	--cfg 'feature="close"' \
	--cfg 'feature="default"' \
	--cfg 'feature="libc"' \
	--cfg 'feature="windows-sys"' \
	-C metadata=36f41602071771e6 \
	-C extra-filename=-36f41602071771e6 \
	--out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" \
	-C linker=/usr/bin/clang \
	-L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" \
	--extern libc="$CARGO_TARGET_DIR/$PROFILE/deps/liblibc-9de7ca31dbbda4df.rmeta" \
	--cap-lints allow \
	-C link-arg=-fuse-ld=/usr/local/bin/mold \
	--cfg io_safety_is_in_std \
	--cfg panic_in_const_fn
# STDERR:
# {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/io_lifetimes-36f41602071771e6.d","emit":"dep-info"}
# {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/libio_lifetimes-36f41602071771e6.rmeta","emit":"metadata"}
# {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/libio_lifetimes-36f41602071771e6.rlib","emit":"link"}
ensure 4fb9f9adcc1dbfae757bd8c7845c9b89f4565af2a5ecaf881335d6613497f078

# rustc --crate-name libc /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="extra_traits" --cfg feature="std" -C metadata=9de7ca31dbbda4df -C extra-filename=-9de7ca31dbbda4df --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg freebsd11 --cfg libc_priv_mod_use --cfg libc_union --cfg libc_const_size_of --cfg libc_align --cfg libc_int128 --cfg libc_core_cvoid --cfg libc_packedN --cfg libc_cfg_target_vendor --cfg libc_non_exhaustive --cfg libc_long_array --cfg libc_ptr_addr_of --cfg libc_underscore_const_names --cfg libc_const_extern_fn
# rustc --crate-name io_lifetimes --edition=2018 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="close" --cfg feature="default" --cfg feature="libc" --cfg feature="windows-sys" -C metadata=36f41602071771e6 -C extra-filename=-36f41602071771e6 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern libc=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg io_safety_is_in_std --cfg panic_in_const_fn
##rustc --crate-name rustix --edition=2018 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="fs" --cfg feature="io-lifetimes" --cfg feature="libc" --cfg feature="std" --cfg feature="termios" --cfg feature="use-libc-auxv" -C metadata=120609be99d53c6b -C extra-filename=-120609be99d53c6b --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern bitflags=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libbitflags-f255a966af175049.rmeta --extern io_lifetimes=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libio_lifetimes-36f41602071771e6.rmeta --extern libc=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/liblibc-9de7ca31dbbda4df.rmeta --extern linux_raw_sys=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/liblinux_raw_sys-67b8335e06167307.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg linux_raw --cfg asm --cfg linux_like
##rustc --crate-name is_terminal --edition=2018 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/is-terminal-0.4.7/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=4b94fef286899229 -C extra-filename=-4b94fef286899229 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern io_lifetimes=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libio_lifetimes-36f41602071771e6.rmeta --extern rustix=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name anstream --edition=2021 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/anstream-0.2.6/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="auto" --cfg feature="default" --cfg feature="wincon" -C metadata=47e0535dab3ef0d2 -C extra-filename=-47e0535dab3ef0d2 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern anstyle=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libanstyle-3d9b242388653423.rmeta --extern anstyle_parse=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libanstyle_parse-0d4af9095c79189b.rmeta --extern concolor_override=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libconcolor_override-305fddcda33650f6.rmeta --extern concolor_query=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libconcolor_query-74e38d373bc944a9.rmeta --extern is_terminal=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libis_terminal-4b94fef286899229.rmeta --extern utf8parse=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libutf8parse-951ca9bdc6d60a50.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name clap_derive --edition=2021 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_derive-4.2.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type proc-macro --emit=dep-info,link -C prefer-dynamic -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=a4ff03e749cd3808 -C extra-filename=-a4ff03e749cd3808 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern heck=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libheck-cd1cdbedec0a6dc0.rlib --extern proc_macro2=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libproc_macro2-ef119f7eb3ef5720.rlib --extern quote=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libquote-74434efe692a445d.rlib --extern syn=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libsyn-4befa7538c9a9f80.rlib --extern proc_macro --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name clap_builder --edition=2021 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=02591a0046469edd -C extra-filename=-02591a0046469edd --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern anstream=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libanstream-47e0535dab3ef0d2.rmeta --extern anstyle=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libanstyle-3d9b242388653423.rmeta --extern bitflags=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libbitflags-f255a966af175049.rmeta --extern clap_lex=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libclap_lex-7dfc2f58447e727e.rmeta --extern strsim=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libstrsim-8ed1051e7e58e636.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name tempfile --edition=2018 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/tempfile-3.5.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=018ce729f986d26d -C extra-filename=-018ce729f986d26d --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern cfg_if=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libcfg_if-305ff6ac5e1cfc5a.rmeta --extern fastrand=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libfastrand-f39af6f065361be9.rmeta --extern rustix=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name clap --edition=2021 /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/clap-4.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="default" --cfg feature="derive" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=8996e440435cdc93 -C extra-filename=-8996e440435cdc93 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern clap_builder=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libclap_builder-02591a0046469edd.rmeta --extern clap_derive=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libclap_derive-a4ff03e749cd3808.so --extern once_cell=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libonce_cell-da1c67e98ff0d3df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=1052b4790952332f -C extra-filename=-1052b4790952332f --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -C incremental=/home/pete/wefwefwef/buildxargs.git/target/debug/incremental -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern clap=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libclap-8996e440435cdc93.rmeta --extern shlex=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libshlex-df9eb4fba8dd532e.rmeta --extern tempfile=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libtempfile-018ce729f986d26d.rmeta -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=4248d2626f765b01 -C extra-filename=-4248d2626f765b01 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -C incremental=/home/pete/wefwefwef/buildxargs.git/target/debug/incremental -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern clap=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libclap-8996e440435cdc93.rlib --extern shlex=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 -C metadata=357a2a97fcd61762 -C extra-filename=-357a2a97fcd61762 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -C incremental=/home/pete/wefwefwef/buildxargs.git/target/debug/incremental -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern buildxargs=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libbuildxargs-1052b4790952332f.rlib --extern clap=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libclap-8996e440435cdc93.rlib --extern shlex=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
##rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=9b4fb3065c88e032 -C extra-filename=-9b4fb3065c88e032 --out-dir /home/pete/wefwefwef/buildxargs.git/target/debug/deps -C linker=/usr/bin/clang -C incremental=/home/pete/wefwefwef/buildxargs.git/target/debug/incremental -L dependency=/home/pete/wefwefwef/buildxargs.git/target/debug/deps --extern buildxargs=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libbuildxargs-1052b4790952332f.rlib --extern clap=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libclap-8996e440435cdc93.rlib --extern shlex=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile=/home/pete/wefwefwef/buildxargs.git/target/debug/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
