#!/bin/bash -eux
# trash _target; shellcheck ./tryin.sh && if ./tryin.sh; then echo YAY; else echo FAILED; fi && \tree _target

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
	local hash=$1; shift
	local dir=${1:-$(basename "$CARGO_TARGET_DIR")}
	h=$(tar -cf- --directory="$PWD" --sort=name --mtime='UTC 2023-04-15' --group=0 --owner=0 --numeric-owner "$dir" | sha256sum)
	[[ "$h" == "$hash  -" ]]
}

rustc() {
	local args=()

	local input=''
	local crate_name=''
	local externs=()
	local extra_filename=''
	local out_dir=''

	local key=''; local val=''; local pair=''
	for arg in "$@"; do
		case "$pair" in
			'' ) pair=S; key=$arg; [[ "$arg" == '--crate-name' ]] || return 4; continue ;;
			'E') pair=S; key=$arg; val=''   ;; # start
			'S') pair=E;           val=$arg ;; # end
		esac
		if [[ "$pair $val" == 'S ' ]] && [[ "$arg" =~ ^--.+=.+ ]]; then
			pair=E; key=${arg%=*}; val=${arg#*=}
		fi

		if [[ "${key:0:1}" == '/' ]]; then
			[[ "$input" != '' ]] && return 4
			input=$key
			pair=E; key=''; val=''
			continue
		fi

		# FIXME: revert
		# strips out local config for now
		if [[ "$key $val" == '-C link-arg=-fuse-ld=/usr/local/bin/mold' ]]; then
			pair=E; key=''; val=''
			continue
		fi
		if [[ "$key $val" == '-C linker=/usr/bin/clang' ]]; then
			pair=E; key=''; val=''
			continue
		fi
		# remove coloring in output for readability during debug
		if [[ "$key $val" == '--json diagnostic-rendered-ansi,artifacts,future-incompat' ]]; then
			val='artifacts,future-incompat'
		fi

		[[ "$val" == '' ]] && continue

		if [[ "$key $val" =~ ^-C.extra-filename= ]]; then
			[[ "$extra_filename" != '' ]] && return 4
			extra_filename=${val#extra-filename=}
		fi

		if [[ "$key $val" =~ ^--cfg.feature=[^\"] ]]; then
			val="feature=\"${val#feature=}\""
		fi

		if [[ "$key" == '--crate-name' ]]; then
			[[ "$crate_name" != '' ]] && return 4
			crate_name=$val
		fi

		if [[ "$key" == '--extern' ]]; then
			externs+=("${val#*=}")
		fi
		# FIXME: report upstream
		# Call to rustc to build quote says its only dep is proc_macro2,
		# however this dep requires a transitive dep called unicode_ident.
		# This call builds IFF that dep is added as an --extern.
		# NOTE: rustc 1.68.2 (9eb3afe9e 2023-03-27) docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094
		# rustc --crate-name quote \
		# 	--edition=2018 \
		# 	"$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26/src/lib.rs \
		# 	--error-format=json \
		# 	--json=diagnostic-rendered-ansi,artifacts,future-incompat \
		# 	--diagnostic-width=211 \
		# 	--crate-type lib \
		# 	--emit=dep-info,metadata,link \
		# 	-C embed-bitcode=no \
		# 	-C debuginfo=2 \
		# 	--cfg feature="default" \
		# 	--cfg feature="proc-macro" \
		# 	-C metadata=74434efe692a445d \
		# 	-C extra-filename=-74434efe692a445d \
		# 	--out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps \
		# 	-C linker=/usr/bin/clang \
		# 	-L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps \
		# 	--extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE"/deps/libproc_macro2-ef119f7eb3ef5720.rmeta \
		# 	--cap-lints allow \
		# 	-C link-arg=-fuse-ld=/usr/local/bin/mold
		if [[ "$key $val" == '--crate-name quote' ]]; then
			args+=(--extern unicode_ident="$CARGO_TARGET_DIR/$PROFILE"/deps/libunicode_ident-417636671c982ef8.rmeta)
			externs+=(                    "$CARGO_TARGET_DIR/$PROFILE"/deps/libunicode_ident-417636671c982ef8.rmeta)
		fi
		# Same for tempfile-018ce729f986d26d:
		# rustc --crate-name tempfile --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/tempfile-3.5.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=018ce729f986d26d -C extra-filename=-018ce729f986d26d --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern cfg_if="$CARGO_TARGET_DIR/$PROFILE"/deps/libcfg_if-305ff6ac5e1cfc5a.rmeta --extern fastrand="$CARGO_TARGET_DIR/$PROFILE"/deps/libfastrand-f39af6f065361be9.rmeta --extern rustix="$CARGO_TARGET_DIR/$PROFILE"/deps/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
		if [[ "$key $val" == '--crate-name tempfile' ]]; then
			# librustix-120609be99d53c6b requires linux_raw_sys-67b8335e06167307
			args+=(--extern linux_raw_sys="$CARGO_TARGET_DIR/$PROFILE"/deps/liblinux_raw_sys-67b8335e06167307.rmeta)
			externs+=(                    "$CARGO_TARGET_DIR/$PROFILE"/deps/liblinux_raw_sys-67b8335e06167307.rmeta)
			# librustix-120609be99d53c6b requires      bitflags-f255a966af175049
			args+=(--extern      bitflags="$CARGO_TARGET_DIR/$PROFILE"/deps/libbitflags-f255a966af175049.rmeta)
			externs+=(                    "$CARGO_TARGET_DIR/$PROFILE"/deps/libbitflags-f255a966af175049.rmeta)
			# librustix-120609be99d53c6b requires  io_lifetimes-36f41602071771e6
			args+=(--extern  io_lifetimes="$CARGO_TARGET_DIR/$PROFILE"/deps/libio_lifetimes-36f41602071771e6.rmeta)
			externs+=(                    "$CARGO_TARGET_DIR/$PROFILE"/deps/libio_lifetimes-36f41602071771e6.rmeta)
			# {"message":"found possibly newer version of crate `libc` which `rustix` depends on","code":{"code":"E0460","explanation":"Found possibly newer version of crate `..` which `..` depends on.\n\nConsider these erroneous files:\n\n`a1.rs`\n```ignore (needs-linkage-with-other-tests)\n#![crate_name = \"a\"]\n\npub fn foo<T>() {}\n```\n\n`a2.rs`\n```ignore (needs-linkage-with-other-tests)\n#![crate_name = \"a\"]\n\npub fn foo<T>() {\n    println!(\"foo<T>()\");\n}\n```\n\n`b.rs`\n```ignore (needs-linkage-with-other-tests)\n#![crate_name = \"b\"]\n\nextern crate a; // linked with `a1.rs`\n\npub fn foo() {\n    a::foo::<isize>();\n}\n```\n\n`main.rs`\n```ignore (needs-linkage-with-other-tests)\nextern crate a; // linked with `a2.rs`\nextern crate b; // error: found possibly newer version of crate `a` which `b`\n                //        depends on\n\nfn main() {}\n```\n\nThe dependency graph of this program can be represented as follows:\n```text\n    crate `main`\n         |\n         +-------------+\n         |             |\n         |             v\ndepends: |         crate `b`\n `a` v1  |             |\n         |             | depends:\n         |             |  `a` v2\n         v             |\n      crate `a` <------+\n```\n\nCrate `main` depends on crate `a` (version 1) and crate `b` which in turn\ndepends on crate `a` (version 2); this discrepancy in versions cannot be\nreconciled. This difference in versions typically occurs when one crate is\ncompiled and linked, then updated and linked to another crate. The crate\n\"version\" is a SVH (Strict Version Hash) of the crate in an\nimplementation-specific way. Note that this error can *only* occur when\ndirectly compiling and linking with `rustc`; [Cargo] automatically resolves\ndependencies, without using the compiler's own dependency management that\ncauses this issue.\n\nThis error can be fixed by:\n * Using [Cargo], the Rust package manager, automatically fixing this issue.\n * Recompiling crate `a` so that both crate `b` and `main` have a uniform\n   version to depend on.\n\n[Cargo]: ../cargo/index.html\n"},"level":"error","spans":[{"file_name":"/home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/tempfile-3.5.0/src/file/imp/unix.rs","byte_start":386,"byte_end":392,"line_start":17,"line_end":17,"column_start":5,"column_end":11,"is_primary":true,"text":[{"text":"use rustix::fs::{cwd, linkat, renameat, unlinkat, AtFlags};","highlight_start":5,"highlight_end":11}],"label":null,"suggested_replacement":null,"suggestion_applicability":null,"expansion":null}],"children":[{"message":"perhaps that crate needs to be recompiled?","code":null,"level":"note","spans":[],"children":[],"rendered":null},{"message":"the following crate versions were found:\ncrate `libc`: /usr/local/rustup/toolchains/1.68.2-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/liblibc-123ffa13a38501db.rlib\ncrate `rustix`: /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/librustix-120609be99d53c6b.rmeta","code":null,"level":"note","spans":[],"children":[],"rendered":null}],"rendered":"error[E0460]: found possibly newer version of crate `libc` which `rustix` depends on\n  --> /home/pete/.cargo/registry/src/github.com-1ecc6299db9ec823/tempfile-3.5.0/src/file/imp/unix.rs:17:5\n   |\n17 | use rustix::fs::{cwd, linkat, renameat, unlinkat, AtFlags};\n   |     ^^^^^^\n   |\n   = note: perhaps that crate needs to be recompiled?\n   = note: the following crate versions were found:\n           crate `libc`: /usr/local/rustup/toolchains/1.68.2-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/liblibc-123ffa13a38501db.rlib\n           crate `rustix`: /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/librustix-120609be99d53c6b.rmeta\n\n"}
			args+=(--extern          libc="$CARGO_TARGET_DIR/$PROFILE"/deps/liblibc-9de7ca31dbbda4df.rmeta)
			externs+=(                    "$CARGO_TARGET_DIR/$PROFILE"/deps/liblibc-9de7ca31dbbda4df.rmeta)
		fi

		if [[ "$key" == '--out-dir' ]]; then
			[[ "$out_dir" != '' ]] && return 4
			out_dir=$val
		fi

		args+=("$key" "$val")
	done

	[[ "$crate_name" == '' ]] && return 4
	[[ "$extra_filename" == '' ]] && return 4
	[[ "$input" == '' ]] && return 4
	[[ "$out_dir" == '' ]] && return 4

	mkdir -p "$out_dir"

	# # shellcheck disable=SC2093
	# exec /home/pete/.cargo/bin/rustc "${args[@]}" "$input"

	# λ input=/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs; echo ${input%/src/lib.rs}
	# /registry/src/github.com-1ecc6299db9ec823/libc-0.2.140
	# λ input=/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs; basename "${input%/src/lib.rs}"
	# libc-0.2.140
	# λ input=/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs; dirname ${input%/src/lib.rs}
	# /registry/src/github.com-1ecc6299db9ec823
	#
	# "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/build.rs \
	local input_mount_name input_mount_target stage_name
	case "$input" in
		*/build.rs)
			input_mount_name=input_build_rs--$(basename "${input%/build.rs}")
			input_mount_target=${input%/build.rs}
			stage_name=build_rs-$(basename "$out_dir")-builder
			;;
		*/src/lib.rs)
			input_mount_name=input_src_lib_rs--$(basename "${input%/src/lib.rs}")
			input_mount_target=${input%/src/lib.rs}
			stage_name=src_lib_rs-$crate_name$extra_filename-builder
			;;
		*) return 4 ;;
	esac

	local 

	local dockerfile
	dockerfile=$(mktemp)
	local backslash="\\"
	cat <<EOF >"$dockerfile"
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS $stage_name
WORKDIR $out_dir
WORKDIR /
RUN $backslash
  --mount=type=bind,from=$input_mount_name,target=$input_mount_target $backslash
EOF
for extern in "${externs[@]}"; do
	cat <<EOF >>"$dockerfile"
  --mount=type=bind,from=deps,source=${extern#"$CARGO_TARGET_DIR/$PROFILE/deps"},target=$extern $backslash
EOF
done

	printf '    ["rustc"' >>"$dockerfile"
	for arg in "${args[@]}"; do
		# shellcheck disable=SC2001
		arg=$(sed 's%"%\\"%g' <<<"$arg")
		printf ', "%s"' "$arg" >>"$dockerfile"
	done
  # shellcheck disable=SC2129
	printf ', "%s"]\n' "$input" >>"$dockerfile"

######
	cat <<EOF >>"$dockerfile"
RUN set -eux && ls -lha $out_dir && ls -lha $out_dir/*$extra_filename.*
EOF

# 	cat <<EOF >>"$dockerfile"
#     set -ux $backslash
#  && echo $backslash
# EOF
# 	for arg in "${args[@]}"; do
# 		# printf " '%s'" "$arg" >>"$dockerfile"
# 		printf ' %s'   "$arg" >>"$dockerfile"
# 	done
#   # shellcheck disable=SC2129
# 	# printf '&& exit 42' >>"$dockerfile" ####
# 	echo "$backslash" >>"$dockerfile" ###
# 	echo >>"$dockerfile"

	cat <<EOF >>"$dockerfile"
FROM scratch
COPY --from=$stage_name $out_dir/*$extra_filename.* /
EOF

	echo ">>>" /home/pete/.cargo/bin/rustc "${args[@]}" "$input" ############
	echo ">>> " && cat "$dockerfile" ###########
	local buildx=()
	# buildx+=(--progress plain) ####
	buildx+=(--output "$out_dir")
	buildx+=(--build-context "$input_mount_name=$input_mount_target")
	if [[ ${#externs[@]} -ne 0 ]]; then
		# TODO: only mount the required files, not the whole deps directory (to maximize cache hits and minimize context sizes)
		buildx+=(--build-context deps="$CARGO_TARGET_DIR/$PROFILE/deps")
	fi
	buildx+=(--build-context rust=docker-image://docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094) # rustc 1.68.2 (9eb3afe9e 2023-03-27)
	buildx+=(--file -)
	buildx+=("$PWD")
	DOCKER_BUILDKIT=1 docker buildx build "${buildx[@]}" <"$dockerfile"
	rm "$dockerfile"

	# ls -lha "$out_dir" && ls -lha "$out_dir"/*"$extra_filename".* #####
}

rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="close" --cfg feature="default" --cfg feature="libc" --cfg feature="windows-sys" -C metadata=5fc4d6e9dda15f11 -C extra-filename=-5fc4d6e9dda15f11 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/io-lifetimes-5fc4d6e9dda15f11 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 3028cbf9c8374af2a50e91169fae14b56acf342873206387b9b6805bc695ab7a "$CARGO_TARGET_DIR/$PROFILE"/build/io-lifetimes-5fc4d6e9dda15f11
rustc --crate-name build_script_build "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="extra_traits" --cfg feature="std" -C metadata=beb72f2d4f0e8864 -C extra-filename=-beb72f2d4f0e8864 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/libc-beb72f2d4f0e8864 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 80797dd3312ac66c489526c7fd01fee60477b88776dc43441f1451393219e40c "$CARGO_TARGET_DIR/$PROFILE"/build/libc-beb72f2d4f0e8864
rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="fs" --cfg feature="io-lifetimes" --cfg feature="libc" --cfg feature="std" --cfg feature="termios" --cfg feature="use-libc-auxv" -C metadata=2a01a00f5bdd1924 -C extra-filename=-2a01a00f5bdd1924 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/rustix-2a01a00f5bdd1924 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure a3bab1bf7d3fb790d3a6e995dbaa15e9ee26cb90942c7245cb1c19b21112d626 "$CARGO_TARGET_DIR/$PROFILE"/build/rustix-2a01a00f5bdd1924
rustc --crate-name bitflags --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/bitflags-1.3.2/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=f255a966af175049 -C extra-filename=-f255a966af175049 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 16e56bbe6cb6d9bc30076df06a3d45b5c35854e733bbfac8cbc66661f818350d "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name linux_raw_sys --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/linux-raw-sys-0.3.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="errno" --cfg feature="general" --cfg feature="ioctl" --cfg feature="no_std" -C metadata=67b8335e06167307 -C extra-filename=-67b8335e06167307 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 9bfe95815a5ae50a0fb0491b771be3c26847bed8b555c854031079c48ec68f5b "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/proc-macro2-1.0.56/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=349a49cf19c07c83 -C extra-filename=-349a49cf19c07c83 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/proc-macro2-349a49cf19c07c83 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure ac18dfc0c8c37cd25536fb9c571f0885cc18ca0d26c6d067bd4dd04cd95efa17 "$CARGO_TARGET_DIR/$PROFILE"/build/proc-macro2-349a49cf19c07c83
rustc --crate-name unicode_ident --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/unicode-ident-1.0.5/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=417636671c982ef8 -C extra-filename=-417636671c982ef8 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure fc70ed028407b36da305610ad84394565b69d777ed1d15f78063b5a6583d4af3 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=de6232726d2cb6c6 -C extra-filename=-de6232726d2cb6c6 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/quote-de6232726d2cb6c6 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 3ef3f9596e194352323833a856c9f1481368be4b59939b01e2ce1e2507c39d7b "$CARGO_TARGET_DIR/$PROFILE"/build/quote-de6232726d2cb6c6
rustc --crate-name utf8parse --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/utf8parse-0.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=951ca9bdc6d60a50 -C extra-filename=-951ca9bdc6d60a50 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 88a8a6d39ae52005e959377c1c94cd03d35c9491bf16f9a30313c9ddf0096a0b "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name anstyle --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/anstyle-0.3.5/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="std" -C metadata=3d9b242388653423 -C extra-filename=-3d9b242388653423 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 25200ca73ed894e3b64c4a67e2984056ad9383406c44b5b6cc5d0f85b148a806 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name anstyle_parse --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/anstyle-parse-0.1.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="utf8" -C metadata=0d4af9095c79189b -C extra-filename=-0d4af9095c79189b --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern utf8parse="$CARGO_TARGET_DIR/$PROFILE"/deps/libutf8parse-951ca9bdc6d60a50.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 91b23180e446b61f0c96dd36eae07ec762f4ea65458016aa7af6b65cc61ae6b5 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name concolor_override --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/concolor-override-1.0.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=305fddcda33650f6 -C extra-filename=-305fddcda33650f6 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 77805ce757bc74a68e63d243ccdfbaf15cbde1080869b3494a103bd395842a68 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name concolor_query --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/concolor-query-0.3.3/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=74e38d373bc944a9 -C extra-filename=-74e38d373bc944a9 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure aa39f03fd8ed6c17846efd8821ff6a9bf7fe8fd76e6d1aa9e9e0231d9241472f "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name strsim "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/strsim-0.10.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=8ed1051e7e58e636 -C extra-filename=-8ed1051e7e58e636 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure dbe2dec0d66fba24f686e93feb613628f23ef23f8458e339b3db76409d9ef68f "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name clap_lex --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap_lex-0.4.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=7dfc2f58447e727e -C extra-filename=-7dfc2f58447e727e --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure fd0294d0f75fea1b28d8c026043210c6d5d20f069d9ab84e6d47f7e673a8cb5a "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name heck --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/heck-0.4.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=cd1cdbedec0a6dc0 -C extra-filename=-cd1cdbedec0a6dc0 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 9cc782096a0bcb7d14965c0d0a5fdd994ace441d3550c845003c8cd966c28a29 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name proc_macro2 --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/proc-macro2-1.0.56/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=ef119f7eb3ef5720 -C extra-filename=-ef119f7eb3ef5720 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern unicode_ident="$CARGO_TARGET_DIR/$PROFILE"/deps/libunicode_ident-417636671c982ef8.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg use_proc_macro --cfg wrap_proc_macro
ensure b6ae1fc65dea5473eb3985fbc05e2a375129ad46bdbce2ddda3cbd442a9695e8 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name libc "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="extra_traits" --cfg feature="std" -C metadata=9de7ca31dbbda4df -C extra-filename=-9de7ca31dbbda4df --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg freebsd11 --cfg libc_priv_mod_use --cfg libc_union --cfg libc_const_size_of --cfg libc_align --cfg libc_int128 --cfg libc_core_cvoid --cfg libc_packedN --cfg libc_cfg_target_vendor --cfg libc_non_exhaustive --cfg libc_long_array --cfg libc_ptr_addr_of --cfg libc_underscore_const_names --cfg libc_const_extern_fn
ensure 2fc6edcdb6cd76b102b02697f535dc5ea6fb5cb0a540d90e7e1407a18e8f5c4e "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name once_cell --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/once_cell-1.15.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="alloc" --cfg feature="default" --cfg feature="race" --cfg feature="std" -C metadata=da1c67e98ff0d3df -C extra-filename=-da1c67e98ff0d3df --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 33c86a8d515fe7f7045cdcec43fd23d4afc6496fcf3acf46f1afc5947071f10a "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name fastrand --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/fastrand-1.8.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=f39af6f065361be9 -C extra-filename=-f39af6f065361be9 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 9dad41506048092cff6b81f1225a5d8897adc61be6acee86310f1ef48ed3e88d "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name shlex "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/shlex-1.1.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="std" -C metadata=df9eb4fba8dd532e -C extra-filename=-df9eb4fba8dd532e --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 1e622ac5e57598a8b2ad85c5257136d37e2d1297f82b7449ae26611b5ef851b2 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name cfg_if --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/cfg-if-1.0.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=305ff6ac5e1cfc5a -C extra-filename=-305ff6ac5e1cfc5a --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 2b7c86c37c8a3695ded552b4c21a76c6d77c35d59c126af693457b75a3d329f6 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name quote --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=74434efe692a445d -C extra-filename=-74434efe692a445d --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE"/deps/libproc_macro2-ef119f7eb3ef5720.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure a0e9898054aa1b464cd632ff001c2c6b12cece69469763bbbca0e1d971f33780 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name syn --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/syn-2.0.13/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="clone-impls" --cfg feature="default" --cfg feature="derive" --cfg feature="full" --cfg feature="parsing" --cfg feature="printing" --cfg feature="proc-macro" --cfg feature="quote" -C metadata=4befa7538c9a9f80 -C extra-filename=-4befa7538c9a9f80 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE"/deps/libproc_macro2-ef119f7eb3ef5720.rmeta --extern quote="$CARGO_TARGET_DIR/$PROFILE"/deps/libquote-74434efe692a445d.rmeta --extern unicode_ident="$CARGO_TARGET_DIR/$PROFILE"/deps/libunicode_ident-417636671c982ef8.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 88413663be82765650e321d999539c8aa05e1e940083a0dfb63cb71e471d6e11 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name io_lifetimes --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="close" --cfg feature="default" --cfg feature="libc" --cfg feature="windows-sys" -C metadata=36f41602071771e6 -C extra-filename=-36f41602071771e6 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern libc="$CARGO_TARGET_DIR/$PROFILE"/deps/liblibc-9de7ca31dbbda4df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg io_safety_is_in_std --cfg panic_in_const_fn
ensure ce834a2f03218f1fbaba78df421a105650c49131c9de27c9e2fc6cea109424d3 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name rustix --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="fs" --cfg feature="io-lifetimes" --cfg feature="libc" --cfg feature="std" --cfg feature="termios" --cfg feature="use-libc-auxv" -C metadata=120609be99d53c6b -C extra-filename=-120609be99d53c6b --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern bitflags="$CARGO_TARGET_DIR/$PROFILE"/deps/libbitflags-f255a966af175049.rmeta --extern io_lifetimes="$CARGO_TARGET_DIR/$PROFILE"/deps/libio_lifetimes-36f41602071771e6.rmeta --extern libc="$CARGO_TARGET_DIR/$PROFILE"/deps/liblibc-9de7ca31dbbda4df.rmeta --extern linux_raw_sys="$CARGO_TARGET_DIR/$PROFILE"/deps/liblinux_raw_sys-67b8335e06167307.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg linux_raw --cfg asm --cfg linux_like
ensure e51d9806788596a834f41c0675904b43295d56c9451c210ba5a2baa218e67a4e "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name tempfile --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/tempfile-3.5.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=018ce729f986d26d -C extra-filename=-018ce729f986d26d --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern cfg_if="$CARGO_TARGET_DIR/$PROFILE"/deps/libcfg_if-305ff6ac5e1cfc5a.rmeta --extern fastrand="$CARGO_TARGET_DIR/$PROFILE"/deps/libfastrand-f39af6f065361be9.rmeta --extern rustix="$CARGO_TARGET_DIR/$PROFILE"/deps/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 4f50e49fc68fe4a34aeaa82080dc1dace2f73f7a3822317ef035c15b0b0d919b "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name is_terminal --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/is-terminal-0.4.7/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=4b94fef286899229 -C extra-filename=-4b94fef286899229 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern io_lifetimes="$CARGO_TARGET_DIR/$PROFILE"/deps/libio_lifetimes-36f41602071771e6.rmeta --extern rustix="$CARGO_TARGET_DIR/$PROFILE"/deps/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name anstream --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/anstream-0.2.6/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="auto" --cfg feature="default" --cfg feature="wincon" -C metadata=47e0535dab3ef0d2 -C extra-filename=-47e0535dab3ef0d2 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern anstyle="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstyle-3d9b242388653423.rmeta --extern anstyle_parse="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstyle_parse-0d4af9095c79189b.rmeta --extern concolor_override="$CARGO_TARGET_DIR/$PROFILE"/deps/libconcolor_override-305fddcda33650f6.rmeta --extern concolor_query="$CARGO_TARGET_DIR/$PROFILE"/deps/libconcolor_query-74e38d373bc944a9.rmeta --extern is_terminal="$CARGO_TARGET_DIR/$PROFILE"/deps/libis_terminal-4b94fef286899229.rmeta --extern utf8parse="$CARGO_TARGET_DIR/$PROFILE"/deps/libutf8parse-951ca9bdc6d60a50.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name clap_builder --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=02591a0046469edd -C extra-filename=-02591a0046469edd --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern anstream="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstream-47e0535dab3ef0d2.rmeta --extern anstyle="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstyle-3d9b242388653423.rmeta --extern bitflags="$CARGO_TARGET_DIR/$PROFILE"/deps/libbitflags-f255a966af175049.rmeta --extern clap_lex="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap_lex-7dfc2f58447e727e.rmeta --extern strsim="$CARGO_TARGET_DIR/$PROFILE"/deps/libstrsim-8ed1051e7e58e636.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name clap_derive --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap_derive-4.2.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type proc-macro --emit=dep-info,link -C prefer-dynamic -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=a4ff03e749cd3808 -C extra-filename=-a4ff03e749cd3808 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern heck="$CARGO_TARGET_DIR/$PROFILE"/deps/libheck-cd1cdbedec0a6dc0.rlib --extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE"/deps/libproc_macro2-ef119f7eb3ef5720.rlib --extern quote="$CARGO_TARGET_DIR/$PROFILE"/deps/libquote-74434efe692a445d.rlib --extern syn="$CARGO_TARGET_DIR/$PROFILE"/deps/libsyn-4befa7538c9a9f80.rlib --extern proc_macro --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name clap --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap-4.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="default" --cfg feature="derive" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=8996e440435cdc93 -C extra-filename=-8996e440435cdc93 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern clap_builder="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap_builder-02591a0046469edd.rmeta --extern clap_derive="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap_derive-a4ff03e749cd3808.so --extern once_cell="$CARGO_TARGET_DIR/$PROFILE"/deps/libonce_cell-da1c67e98ff0d3df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=1052b4790952332f -C extra-filename=-1052b4790952332f --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rmeta --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rmeta --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rmeta -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=4248d2626f765b01 -C extra-filename=-4248d2626f765b01 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=9b4fb3065c88e032 -C extra-filename=-9b4fb3065c88e032 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern buildxargs="$CARGO_TARGET_DIR/$PROFILE"/deps/libbuildxargs-1052b4790952332f.rlib --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps
rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 -C metadata=357a2a97fcd61762 -C extra-filename=-357a2a97fcd61762 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern buildxargs="$CARGO_TARGET_DIR/$PROFILE"/deps/libbuildxargs-1052b4790952332f.rlib --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 42 "$CARGO_TARGET_DIR/$PROFILE"/deps

# # rustc --crate-name libc \
# #   "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs" \
# # 	--error-format=json \
# # 	--json=diagnostic-rendered-ansi,artifacts,future-incompat \
# # 	--diagnostic-width=105 \
# # 	--crate-type lib \
# # 	--emit=dep-info,metadata,link \
# # 	-C embed-bitcode=no \
# # 	-C debuginfo=2 \
# # 	--cfg 'feature="default"' \
# # 	--cfg 'feature="extra_traits"' \
# # 	--cfg 'feature="std"' \
# # 	-C metadata=9de7ca31dbbda4df \
# # 	-C extra-filename=-9de7ca31dbbda4df \
# # 	--out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" \
# # 	-C linker=/usr/bin/clang \
# # 	-L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" \
# # 	--cap-lints allow \
# # 	-C link-arg=-fuse-ld=/usr/local/bin/mold \
# # 	--cfg freebsd11 \
# # 	--cfg libc_priv_mod_use \
# # 	--cfg libc_union \
# # 	--cfg libc_const_size_of \
# # 	--cfg libc_align \
# # 	--cfg libc_int128 \
# # 	--cfg libc_core_cvoid \
# # 	--cfg libc_packedN \
# # 	--cfg libc_cfg_target_vendor \
# # 	--cfg libc_non_exhaustive \
# # 	--cfg libc_long_array \
# # 	--cfg libc_ptr_addr_of \
# # 	--cfg libc_underscore_const_names \
# # 	--cfg libc_const_extern_fn
# # # STDERR:
# # # {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/libc-9de7ca31dbbda4df.d","emit":"dep-info"}
# # # {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/liblibc-9de7ca31dbbda4df.rmeta","emit":"metadata"}
# # # {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/liblibc-9de7ca31dbbda4df.rlib","emit":"link"}
# # #ensure 4f3aa5134e2db0871e050d2916083f84ed02951067ae55137b5df83375edcd13
# # ensure f73d6f56c4855ae07ba0fea87845f9bc8857bfdbdab24def670a7589c2b028b3

# # rustc --crate-name io_lifetimes \
# # 	--edition=2018 \
# # 	"$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs" \
# # 	--error-format=json \
# # 	--json=diagnostic-rendered-ansi,artifacts,future-incompat \
# # 	--diagnostic-width=105 \
# # 	--crate-type lib \
# # 	--emit=dep-info,metadata,link \
# # 	-C embed-bitcode=no \
# # 	-C debuginfo=2 \
# # 	--cfg 'feature="close"' \
# # 	--cfg 'feature="default"' \
# # 	--cfg 'feature="libc"' \
# # 	--cfg 'feature="windows-sys"' \
# # 	-C metadata=36f41602071771e6 \
# # 	-C extra-filename=-36f41602071771e6 \
# # 	--out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" \
# # 	-C linker=/usr/bin/clang \
# # 	-L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" \
# # 	--extern libc="$CARGO_TARGET_DIR/$PROFILE/deps/liblibc-9de7ca31dbbda4df.rmeta" \
# # 	--cap-lints allow \
# # 	-C link-arg=-fuse-ld=/usr/local/bin/mold \
# # 	--cfg io_safety_is_in_std \
# # 	--cfg panic_in_const_fn
# # # STDERR:
# # # {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/io_lifetimes-36f41602071771e6.d","emit":"dep-info"}
# # # {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/libio_lifetimes-36f41602071771e6.rmeta","emit":"metadata"}
# # # {"artifact":"$CARGO_TARGET_DIR/$PROFILE/deps/libio_lifetimes-36f41602071771e6.rlib","emit":"link"}
# # #ensure 4fb9f9adcc1dbfae757bd8c7845c9b89f4565af2a5ecaf881335d6613497f078
# # ensure 013766859a9d98ffefc5a63122d137e10e9ac98f4e6ad794a65b0a29c9bbdcba

# rustc --crate-name libc "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="extra_traits" --cfg feature="std" -C metadata=9de7ca31dbbda4df -C extra-filename=-9de7ca31dbbda4df --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg freebsd11 --cfg libc_priv_mod_use --cfg libc_union --cfg libc_const_size_of --cfg libc_align --cfg libc_int128 --cfg libc_core_cvoid --cfg libc_packedN --cfg libc_cfg_target_vendor --cfg libc_non_exhaustive --cfg libc_long_array --cfg libc_ptr_addr_of --cfg libc_underscore_const_names --cfg libc_const_extern_fn
# ensure f73d6f56c4855ae07ba0fea87845f9bc8857bfdbdab24def670a7589c2b028b3
# rustc --crate-name io_lifetimes --edition=2018 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="close" --cfg feature="default" --cfg feature="libc" --cfg feature="windows-sys" -C metadata=36f41602071771e6 -C extra-filename=-36f41602071771e6 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern libc="$CARGO_TARGET_DIR/$PROFILE"/deps/liblibc-9de7ca31dbbda4df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg io_safety_is_in_std --cfg panic_in_const_fn
# ensure 013766859a9d98ffefc5a63122d137e10e9ac98f4e6ad794a65b0a29c9bbdcba
# rustc --crate-name rustix --edition=2018 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="fs" --cfg feature="io-lifetimes" --cfg feature="libc" --cfg feature="std" --cfg feature="termios" --cfg feature="use-libc-auxv" -C metadata=120609be99d53c6b -C extra-filename=-120609be99d53c6b --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern bitflags="$CARGO_TARGET_DIR/$PROFILE/deps"/libbitflags-f255a966af175049.rmeta --extern io_lifetimes="$CARGO_TARGET_DIR/$PROFILE/deps"/libio_lifetimes-36f41602071771e6.rmeta --extern libc="$CARGO_TARGET_DIR/$PROFILE/deps"/liblibc-9de7ca31dbbda4df.rmeta --extern linux_raw_sys="$CARGO_TARGET_DIR/$PROFILE/deps"/liblinux_raw_sys-67b8335e06167307.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg linux_raw --cfg asm --cfg linux_like
# # rustc  --crate-name rustix --edition=2018 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="fs" --cfg feature="io-lifetimes" --cfg feature="libc" --cfg feature="std" --cfg feature="termios" --cfg feature="use-libc-auxv" -C metadata=120609be99d53c6b -C extra-filename=-120609be99d53c6b --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps"                                                                                        --extern io_lifetimes="$CARGO_TARGET_DIR/$PROFILE/deps"/libio_lifetimes-36f41602071771e6.rmeta --extern libc="$CARGO_TARGET_DIR/$PROFILE/deps"/liblibc-9de7ca31dbbda4df.rmeta                                                                                                  --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg linux_raw --cfg asm --cfg linux_like
# ensure 42
# rustc --crate-name is_terminal --edition=2018 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/is-terminal-0.4.7/src/lib".rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=4b94fef286899229 -C extra-filename=-4b94fef286899229 --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern io_lifetimes="$CARGO_TARGET_DIR/$PROFILE/deps"/libio_lifetimes-36f41602071771e6.rmeta --extern rustix="$CARGO_TARGET_DIR/$PROFILE/deps"/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
# ensure 42
# rustc --crate-name anstream --edition=2021 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/anstream-0.2.6/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="auto" --cfg feature="default" --cfg feature="wincon" -C metadata=47e0535dab3ef0d2 -C extra-filename=-47e0535dab3ef0d2 --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern anstyle="$CARGO_TARGET_DIR/$PROFILE/deps"/libanstyle-3d9b242388653423.rmeta --extern anstyle_parse="$CARGO_TARGET_DIR/$PROFILE/deps"/libanstyle_parse-0d4af9095c79189b.rmeta --extern concolor_override="$CARGO_TARGET_DIR/$PROFILE/deps"/libconcolor_override-305fddcda33650f6.rmeta --extern concolor_query="$CARGO_TARGET_DIR/$PROFILE/deps"/libconcolor_query-74e38d373bc944a9.rmeta --extern is_terminal="$CARGO_TARGET_DIR/$PROFILE/deps"/libis_terminal-4b94fef286899229.rmeta --extern utf8parse="$CARGO_TARGET_DIR/$PROFILE/deps"/libutf8parse-951ca9bdc6d60a50.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
# ensure 42
# rustc --crate-name clap_derive --edition=2021 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/clap_derive-4.2.0/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type proc-macro --emit=dep-info,link -C prefer-dynamic -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=a4ff03e749cd3808 -C extra-filename=-a4ff03e749cd3808 --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern heck="$CARGO_TARGET_DIR/$PROFILE/deps"/libheck-cd1cdbedec0a6dc0.rlib --extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE/deps"/libproc_macro2-ef119f7eb3ef5720.rlib --extern quote="$CARGO_TARGET_DIR/$PROFILE/deps"/libquote-74434efe692a445d.rlib --extern syn="$CARGO_TARGET_DIR/$PROFILE/deps"/libsyn-4befa7538c9a9f80.rlib --extern proc_macro --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
# ensure 42
# rustc --crate-name clap_builder --edition=2021 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=02591a0046469edd -C extra-filename=-02591a0046469edd --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern anstream="$CARGO_TARGET_DIR/$PROFILE/deps"/libanstream-47e0535dab3ef0d2.rmeta --extern anstyle="$CARGO_TARGET_DIR/$PROFILE/deps"/libanstyle-3d9b242388653423.rmeta --extern bitflags="$CARGO_TARGET_DIR/$PROFILE/deps"/libbitflags-f255a966af175049.rmeta --extern clap_lex="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap_lex-7dfc2f58447e727e.rmeta --extern strsim="$CARGO_TARGET_DIR/$PROFILE/deps"/libstrsim-8ed1051e7e58e636.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
# # rustc  --crate-name clap_builder --edition=2021 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=02591a0046469edd -C extra-filename=-02591a0046469edd --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern anstream="$CARGO_TARGET_DIR/$PROFILE/deps"/libanstream-47e0535dab3ef0d2.rmeta --extern anstyle="$CARGO_TARGET_DIR/$PROFILE/deps"/libanstyle-3d9b242388653423.rmeta                                                                                        --extern clap_lex="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap_lex-7dfc2f58447e727e.rmeta --extern strsim="$CARGO_TARGET_DIR/$PROFILE/deps"/libstrsim-8ed1051e7e58e636.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
# ensure 42
# rustc --crate-name tempfile --edition=2018 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/tempfile-3.5.0/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=018ce729f986d26d -C extra-filename=-018ce729f986d26d --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern cfg_if="$CARGO_TARGET_DIR/$PROFILE/deps"/libcfg_if-305ff6ac5e1cfc5a.rmeta --extern fastrand="$CARGO_TARGET_DIR/$PROFILE/deps"/libfastrand-f39af6f065361be9.rmeta --extern rustix="$CARGO_TARGET_DIR/$PROFILE/deps"/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
# ensure 42
# rustc --crate-name clap --edition=2021 "$CARGO_HOME/registry/src/github.com-1ecc6299db9ec823/clap-4.2.1/src/lib.rs" --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="default" --cfg feature="derive" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=8996e440435cdc93 -C extra-filename=-8996e440435cdc93 --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern clap_builder="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap_builder-02591a0046469edd.rmeta --extern clap_derive="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap_derive-a4ff03e749cd3808.so --extern once_cell="$CARGO_TARGET_DIR/$PROFILE/deps"/libonce_cell-da1c67e98ff0d3df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
# ensure 42
# ##rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=1052b4790952332f -C extra-filename=-1052b4790952332f --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE/incremental" -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern clap="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap-8996e440435cdc93.rmeta --extern shlex="$CARGO_TARGET_DIR/$PROFILE/deps"/libshlex-df9eb4fba8dd532e.rmeta --extern tempfile="$CARGO_TARGET_DIR/$PROFILE/deps"/libtempfile-018ce729f986d26d.rmeta -C link-arg=-fuse-ld=/usr/local/bin/mold
# ##rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=4248d2626f765b01 -C extra-filename=-4248d2626f765b01 --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE/incremental" -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern clap="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE/deps"/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE/deps"/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
# ##rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 -C metadata=357a2a97fcd61762 -C extra-filename=-357a2a97fcd61762 --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE/incremental" -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern buildxargs="$CARGO_TARGET_DIR/$PROFILE/deps"/libbuildxargs-1052b4790952332f.rlib --extern clap="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE/deps"/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE/deps"/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
# ##rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=105 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=9b4fb3065c88e032 -C extra-filename=-9b4fb3065c88e032 --out-dir "$CARGO_TARGET_DIR/$PROFILE/deps" -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE/incremental" -L dependency="$CARGO_TARGET_DIR/$PROFILE/deps" --extern buildxargs="$CARGO_TARGET_DIR/$PROFILE/deps"/libbuildxargs-1052b4790952332f.rlib --extern clap="$CARGO_TARGET_DIR/$PROFILE/deps"/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE/deps"/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE/deps"/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
