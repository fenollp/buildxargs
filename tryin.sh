#!/bin/bash -eu

if [[ "${DEBUG:-}" == '1' ]]; then
	set -x
fi

PROFILE=${PROFILE:-debug}
CARGO_HOME=${CARGO_HOME:-$HOME/.cargo}
CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-$PWD/_target}

mkdir -p "$CARGO_HOME/git/db"
mkdir -p "$CARGO_HOME/git/checkouts"
mkdir -p "$CARGO_HOME/registry/index"
mkdir -p "$CARGO_HOME/registry/cache"
mkdir -p "$CARGO_HOME/registry/src"
mkdir -p "$CARGO_TARGET_DIR/$PROFILE/deps"

r_ext() {
	case "$1" in
	lib) echo 'rmeta' ;;
	bin|proc-macro|test) echo 'rlib' ;;
	*) return 4 ;;
	esac
}

_rustc() {
	local args=()

	local crate_name=''
	local crate_type=''
	local externs=()
	local extra_filename=''
	local incremental=''
	local input=''
	local out_dir=''

	local deps_path="$CARGO_TARGET_DIR/$PROFILE/deps"

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

		case "$key" in /*|src/lib.rs|src/main.rs)
			[[ "$input" != '' ]] && return 4
			input=$key
			pair=E; key=''; val=''
			continue ;;
		esac

		if [[ "$pair $key $val" == 'S --test ' ]]; then
			[[ "$crate_type" != '' ]] && return 4
			crate_type='test' # Not a real `--crate-type`
			pair=E; key=''; val=''
			args+=('--test')
			continue
		fi

		# FIXME: revert
		case "$key $val" in
		# strips out local config for now
		'-C link-arg=-fuse-ld=/usr/local/bin/mold')
			pair=E; key=''; val=''
			continue ;;
		'-C linker=/usr/bin/clang')
			pair=E; key=''; val=''
			continue ;;
		# remove coloring in output for readability during debug
		'--json diagnostic-rendered-ansi,artifacts,future-incompat')
			val='artifacts,future-incompat'
			;;
		esac

		[[ "$val" == '' ]] && continue

		if [[ "$key $val" =~ ^-C.extra-filename= ]]; then
			[[ "$extra_filename" != '' ]] && return 4
			extra_filename=${val#extra-filename=}
		fi

		if [[ "$key $val" =~ ^-C.incremental= ]]; then
			[[ "$incremental" != '' ]] && return 4
			incremental=${val#incremental=}
		fi

		if [[ "$key $val" =~ ^--cfg.feature=[^\"] ]]; then
			val="feature=\\\"${val#feature=}\\\""
		fi

		case "$key" in
		'--crate-name')
			[[ "$crate_name" != '' ]] && return 4
			crate_name=$val
			;;

		'--crate-type')
			[[ "$crate_type" != '' ]] && return 4
			case "$val" in bin|lib|proc-macro) ;; *) return 4;; esac
			crate_type=$val
			;;

		'--extern')
			# Sysroot crates (e.g. https://doc.rust-lang.org/proc_macro)
			case "$val" in alloc|core|proc_macro|std|test) continue ;; esac
			local extern=${val#*=}
			case "$extern" in "$deps_path"/*) ;; *) return 4 ;; esac
			externs+=("${extern#"$deps_path"/}")
			;;

		'--out-dir')
			[[ "$out_dir" != '' ]] && return 4
			out_dir=$val
			;;
		esac

		args+=("$key" "$val")
	done

	[[ "$crate_name" == '' ]] && return 4
	[[ "$crate_type" == '' ]] && return 4
	[[ "$extra_filename" == '' ]] && return 4
	# [[ "$incremental" == '' ]] && return 4 MAY be unset: only set on last calls
	[[ "$input" == '' ]] && return 4
	[[ "$out_dir" == '' ]] && return 4

	local full_crate_id
	full_crate_id=$crate_type-$crate_name$extra_filename

	# https://github.com/rust-lang/rust/issues/68417#issuecomment-576809886
	all_externs=()
	local crate_externs=$CARGO_TARGET_DIR/$PROFILE/externs_$crate_name$extra_filename
	if ! [[ -s "$crate_externs" ]]; then
		for extern in "${externs[@]}"; do
			all_externs+=("$extern")

			case "$extern" in lib*) ;; *) return 4 ;; esac
			extern=${extern#lib}
			case "$extern" in
			*.rlib) extern=${extern%.rlib} ;;
			*.rmeta) extern=${extern%.rmeta} ;;
			*.so) extern=${extern%.so} ;;
			*) return 4 ;;
			esac
			echo "$extern" >>"$crate_externs"

			extern_crate_externs="$CARGO_TARGET_DIR/$PROFILE/externs_$extern"
			if [[ -s "$extern_crate_externs" ]]; then
				# echo ">>> $extern" ; cat "$extern_crate_externs" || true
				while read -r transitive; do
					if [[ "$transitive" == 'clap_derive-a4ff03e749cd3808' ]]; then
						all_externs+=("lib${transitive}.so") ############ FIXME
					else
						all_externs+=("lib${transitive}.$(r_ext "$crate_type")")
					fi

					echo "$transitive" >>"$crate_externs"
				done <"$extern_crate_externs"
			fi
		done
		# if ! diff -q <(cat "$crate_externs") <(sort -u "$crate_externs"); then
		# 	return 4
		# fi
		if [[ -s "$crate_externs" ]]; then
			sort -u "$crate_externs" >"$crate_externs"~
			mv "$crate_externs"~ "$crate_externs"
		fi
	fi

	mkdir -p "$out_dir"
	[[ "$incremental" != '' ]] && mkdir -p "$incremental"

	local input_mount_name input_mount_target stage_name
	case "$input" in
	*/build.rs)
		input_mount_name=input_build_rs--$(basename "${input%/build.rs}")
		input_mount_target=${input%/build.rs}
		stage_name=build_rs-$full_crate_id
		;;
	*/src/lib.rs)
		input_mount_name=input_src_lib_rs--$(basename "${input%/src/lib.rs}")
		input_mount_target=${input%/src/lib.rs}
		stage_name=src_lib_rs-$full_crate_id
		;;
	src/lib.rs)
		input_mount_name=''
		input_mount_target=''
		stage_name=final-$full_crate_id
		;;
	src/main.rs)
		input_mount_name=''
		input_mount_target=''
		stage_name=final-$full_crate_id
		;;
	*) return 4 ;;
	esac

	local backslash="\\"

	local dockerfile
	dockerfile=$(mktemp)
	cat <<EOF >"$dockerfile"
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14

FROM rust AS $stage_name
WORKDIR $out_dir
EOF

	if [[ "$incremental" != '' ]]; then
		cat <<EOF >>"$dockerfile"
WORKDIR $incremental
EOF
	fi

	if [[ "$crate_type $input" == 'bin src/main.rs' ]] || [[ "$crate_type $input" == 'test src/main.rs' ]]; then
		# {"message":"cannot derive `author` from Cargo.toml\n\n= note: `CARGO_PKG_AUTHORS` environment variable is not set\n\n= help: use `author = \"...\"` to set author manually\n\n","code":null,"level":"error","spans":[{"file_name":"src/main.rs","byte_start":318,"byte_end":324,"line_start":11,"line_end":11,"column_start":8,"column_end":14,"is_primary":true,"text":[{"text":"#[clap(author, version, about, long_about=None)]","highlight_start":8,"highlight_end":14}],"label":null,"suggested_replacement":null,"suggestion_applicability":null,"expansion":null}],"children":[],"rendered":"error: cannot derive `author` from Cargo.toml\n       \n       = note: `CARGO_PKG_AUTHORS` environment variable is not set\n       \n       = help: use `author = \"...\"` to set author manually\n       \n  --> src/main.rs:11:8\n   |\n11 | #[clap(author, version, about, long_about=None)]\n   |        ^^^^^^\n\n"}
		case "-${CARGO_PKG_AUTHORS:-}-${CARGO_PKG_VERSION:-}-${CARGO_PKG_DESCRIPTION:-}-" in
		'----') ;;
		*) return 4 ;;
		esac
		toml() {
			local prefix=$1; shift
			grep -F "$prefix" Cargo.toml | head -n1 | cut -c$((1 + ${#prefix}))-
		}
		cat <<EOF >>"$dockerfile"
ENV CARGO_PKG_AUTHORS='$(toml 'authors = ')'
ENV CARGO_PKG_VERSION='$(toml 'version = ')'
ENV CARGO_PKG_DESCRIPTION='$(toml 'description = ')'
EOF
	fi

	if [[ "${input_mount_name:-}" == '' ]]; then
		if [[ -d "$PWD"/.git ]]; then
			cat <<EOF >>"$dockerfile"
WORKDIR $PWD
EOF
			while read -r f; do
			cat <<EOF >>"$dockerfile"
COPY $f $(dirname "$f")/
EOF
			done < <(git ls-files "$PWD" | sort)
			cat <<EOF >>"$dockerfile"
RUN $backslash
EOF
		else
			cat <<EOF >>"$dockerfile"
WORKDIR $PWD
COPY . .
RUN $backslash
EOF
		fi
	else
		cat <<EOF >>"$dockerfile"
WORKDIR $PWD
RUN $backslash
  --mount=type=bind,from=$input_mount_name,target=$input_mount_target $backslash
EOF
	fi

	for extern in "${all_externs[@]}"; do
		cat <<EOF >>"$dockerfile"
  --mount=type=bind,from=deps,source=/$extern,target=$deps_path/$extern $backslash
EOF
	done

	printf '    ["rustc"' >>"$dockerfile"
	for arg in "${args[@]}"; do
		printf ', "%s"' "$arg" >>"$dockerfile"
	done
	printf ', "%s"]\n' "$input" >>"$dockerfile"

	if [[ "$incremental" != '' ]]; then
		cat <<EOF >>"$dockerfile"
FROM scratch AS incremental
COPY --from=$stage_name $incremental /
EOF
	fi
	cat <<EOF >>"$dockerfile"
FROM scratch AS out
COPY --from=$stage_name $out_dir/*$extra_filename.* /
EOF

	declare -A contexts
	if [[ "${input_mount_name:-}" != '' ]]; then
		contexts["$input_mount_name"]=$input_mount_target
	fi
	if [[ ${#all_externs[@]} -ne 0 ]]; then
		# TODO: check if gains are possible (we're binding a directory growing in size)
		contexts['deps']=$deps_path
	fi
	contexts['rust']=docker-image://docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094 # rustc 1.68.2 (9eb3afe9e 2023-03-27)

	local bake_hcl
	bake_hcl=$(mktemp)
	cat <<EOF >"$bake_hcl"
target "out" {
	context = "$PWD"
	contexts = {
$(for name in "${!contexts[@]}"; do
	printf '\t\t"%s" = "%s",\n' "$name" "${contexts[$name]}"
done)
	}
	dockerfile-inline = <<DOCKERFILE
$(cat "$dockerfile")
DOCKERFILE
	network = "none"
	output = ["$out_dir"] # https://github.com/moby/buildkit/issues/1224
	platforms = ["local"]
	target = "out"
}
EOF
	rm "$dockerfile"

	if [[ "$incremental" == '' ]]; then
		cat <<EOF >>"$bake_hcl"
group "default" { targets = ["out"] }
EOF
	else
		cat <<EOF >>"$bake_hcl"
group "default" { targets = ["out", "incremental"] }
target "incremental" {
	inherits = ["out"]
	output = ["$incremental"]
	target = "incremental"
}
EOF
	fi

	err=0
	set +e
	if [[ "${DEBUG:-}" == '1' ]]; then
		cat "$bake_hcl" >&2
		docker --debug buildx bake --file=- <"$bake_hcl" >&2
	else
		docker         buildx bake --file=- <"$bake_hcl" >/dev/null 2>&1
	fi
	err=$?
	set -e
	rm "$bake_hcl"
	if [[ $err -ne 0 ]]; then
		# for extern in "${all_externs[@]}"; do
		# 	echo ">>> $extern"
		# done
		# echo ">>>" ; cat "$crate_externs" || true
		args=()
		for arg in "$@"; do
			if [[ "$arg" =~ ^feature= ]]; then
				arg="feature=\"${arg#feature=}\""
			fi
			args+=("$arg")
		done
		# Bubble up actual error & outputs
		rustc "${args[@]}"
		echo "Found a bug in this script!" 1>&2
		return
	fi
}

if [[ $# -ne 0 ]]; then
	_rustc "$@"
	exit
fi


# Reproduce a working build: (main @ db53336) (docker buildx version: github.com/docker/buildx v0.10.4 c513d34) linux/amd64
# trash _target >/dev/null 2>&1; shellcheck ./tryin.sh && if ./tryin.sh; then echo YAY; else echo FAILED && tree _target; fi

ensure() {
	local hash=$1; shift
	local dir=${1:-$(basename "$CARGO_TARGET_DIR")}
	h=$(tar -cf- --directory="$PWD" --sort=name --mtime='UTC 2023-04-15' --group=0 --owner=0 --numeric-owner "$dir" 2>/dev/null | sha256sum)
	[[ "$h" == "$hash  -" ]]
}

_rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="close" --cfg feature="default" --cfg feature="libc" --cfg feature="windows-sys" -C metadata=5fc4d6e9dda15f11 -C extra-filename=-5fc4d6e9dda15f11 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/io-lifetimes-5fc4d6e9dda15f11 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 3028cbf9c8374af2a50e91169fae14b56acf342873206387b9b6805bc695ab7a "$CARGO_TARGET_DIR/$PROFILE"/build/io-lifetimes-5fc4d6e9dda15f11
_rustc --crate-name build_script_build "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="extra_traits" --cfg feature="std" -C metadata=beb72f2d4f0e8864 -C extra-filename=-beb72f2d4f0e8864 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/libc-beb72f2d4f0e8864 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 80797dd3312ac66c489526c7fd01fee60477b88776dc43441f1451393219e40c "$CARGO_TARGET_DIR/$PROFILE"/build/libc-beb72f2d4f0e8864
_rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="fs" --cfg feature="io-lifetimes" --cfg feature="libc" --cfg feature="std" --cfg feature="termios" --cfg feature="use-libc-auxv" -C metadata=2a01a00f5bdd1924 -C extra-filename=-2a01a00f5bdd1924 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/rustix-2a01a00f5bdd1924 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure a3bab1bf7d3fb790d3a6e995dbaa15e9ee26cb90942c7245cb1c19b21112d626 "$CARGO_TARGET_DIR/$PROFILE"/build/rustix-2a01a00f5bdd1924
_rustc --crate-name bitflags --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/bitflags-1.3.2/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=f255a966af175049 -C extra-filename=-f255a966af175049 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 8663ccfb69487ac1594fb52a3d1083489a7c161f674fba1cbbdde0284288ae71 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name linux_raw_sys --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/linux-raw-sys-0.3.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="errno" --cfg feature="general" --cfg feature="ioctl" --cfg feature="no_std" -C metadata=67b8335e06167307 -C extra-filename=-67b8335e06167307 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure febac1d2841ecb1a329f56925ac841aed0e31ccf2a47e5141c13c053f090eb61 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/proc-macro2-1.0.56/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=349a49cf19c07c83 -C extra-filename=-349a49cf19c07c83 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/proc-macro2-349a49cf19c07c83 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure ac18dfc0c8c37cd25536fb9c571f0885cc18ca0d26c6d067bd4dd04cd95efa17 "$CARGO_TARGET_DIR/$PROFILE"/build/proc-macro2-349a49cf19c07c83
_rustc --crate-name unicode_ident --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/unicode-ident-1.0.5/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=417636671c982ef8 -C extra-filename=-417636671c982ef8 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 63debee9e52e3f92c21060c264b7cfa277623245d4312595b76a05ae7de9fe18 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=de6232726d2cb6c6 -C extra-filename=-de6232726d2cb6c6 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/quote-de6232726d2cb6c6 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 3ef3f9596e194352323833a856c9f1481368be4b59939b01e2ce1e2507c39d7b "$CARGO_TARGET_DIR/$PROFILE"/build/quote-de6232726d2cb6c6
_rustc --crate-name utf8parse --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/utf8parse-0.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=951ca9bdc6d60a50 -C extra-filename=-951ca9bdc6d60a50 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 3a9d88dcc4808ec4a6613fca714f98cc0cefc96a4b81ed9007e7e6f3ab19e446 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name anstyle --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/anstyle-0.3.5/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="std" -C metadata=3d9b242388653423 -C extra-filename=-3d9b242388653423 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 515ebdbaea4523d75db0f98b38fa07c353834c6af3fdfdd1fce1f76157dccb41 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name anstyle_parse --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/anstyle-parse-0.1.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="utf8" -C metadata=0d4af9095c79189b -C extra-filename=-0d4af9095c79189b --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern utf8parse="$CARGO_TARGET_DIR/$PROFILE"/deps/libutf8parse-951ca9bdc6d60a50.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 59c82c7d16960ea23be7db27c69d632a54a1faa9def5f7bf4b9e631f5e8b5025 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name concolor_override --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/concolor-override-1.0.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=305fddcda33650f6 -C extra-filename=-305fddcda33650f6 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 242e5eefd61963ac190559f7061228a18a5e1820f75062354d6c3aac7adb9c8d "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name concolor_query --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/concolor-query-0.3.3/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=74e38d373bc944a9 -C extra-filename=-74e38d373bc944a9 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 80b4cf0c70fba99090291a5a9f18996b89d7c48d34fe47a7b7654260f9061d93 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name strsim "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/strsim-0.10.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=8ed1051e7e58e636 -C extra-filename=-8ed1051e7e58e636 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 7d0ab51edc54d1fba6562eba15c2d50b006d8b1d26c7caaa4835ca842b32e6bd "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name clap_lex --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap_lex-0.4.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=7dfc2f58447e727e -C extra-filename=-7dfc2f58447e727e --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 102ebf5186bfb97efed2644993b22c8eba60f758a24f8ca0795da74196afb3d5 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name heck --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/heck-0.4.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=cd1cdbedec0a6dc0 -C extra-filename=-cd1cdbedec0a6dc0 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure fc9fd4659e849560714e36514cfc6024d3ba3bf9356806479aaeb46417f24b06 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name proc_macro2 --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/proc-macro2-1.0.56/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=ef119f7eb3ef5720 -C extra-filename=-ef119f7eb3ef5720 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern unicode_ident="$CARGO_TARGET_DIR/$PROFILE"/deps/libunicode_ident-417636671c982ef8.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg use_proc_macro --cfg wrap_proc_macro
ensure b7382060b42396c1cef74ce8573fffb7bc13cb4ad97d07c0aa3e6367275135a7 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name libc "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/libc-0.2.140/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="extra_traits" --cfg feature="std" -C metadata=9de7ca31dbbda4df -C extra-filename=-9de7ca31dbbda4df --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg freebsd11 --cfg libc_priv_mod_use --cfg libc_union --cfg libc_const_size_of --cfg libc_align --cfg libc_int128 --cfg libc_core_cvoid --cfg libc_packedN --cfg libc_cfg_target_vendor --cfg libc_non_exhaustive --cfg libc_long_array --cfg libc_ptr_addr_of --cfg libc_underscore_const_names --cfg libc_const_extern_fn
ensure aca31b437a30b41437831eb55833d4a603cd17b1bf14bf61c22fd597cc85f591 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name once_cell --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/once_cell-1.15.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="alloc" --cfg feature="default" --cfg feature="race" --cfg feature="std" -C metadata=da1c67e98ff0d3df -C extra-filename=-da1c67e98ff0d3df --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 681724646da3eeff1fc4eac763657069367f2eca3063541d6210267af9516c8b "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name fastrand --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/fastrand-1.8.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=f39af6f065361be9 -C extra-filename=-f39af6f065361be9 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure a96b56af7d56ecc76ba33d69c403e79d35ad219f4cf33534c7de79dcd869a418 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name shlex "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/shlex-1.1.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="std" -C metadata=df9eb4fba8dd532e -C extra-filename=-df9eb4fba8dd532e --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 8e7d662c23280112c77833c899c60295549f40cef9c30d44fa3ee5f2cae9c70c "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name cfg_if --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/cfg-if-1.0.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=305ff6ac5e1cfc5a -C extra-filename=-305ff6ac5e1cfc5a --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 5b338fbcc1fa1566b2700d106204b426c2914d8ae9dd73a6caa8b54600940acb "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name quote --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/quote-1.0.26/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="proc-macro" -C metadata=74434efe692a445d -C extra-filename=-74434efe692a445d --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE"/deps/libproc_macro2-ef119f7eb3ef5720.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure ddb97c0389c55493bea292d9853dcada9d9f4207dbe7bad52d217b086e3706bc "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name syn --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/syn-2.0.13/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="clone-impls" --cfg feature="default" --cfg feature="derive" --cfg feature="full" --cfg feature="parsing" --cfg feature="printing" --cfg feature="proc-macro" --cfg feature="quote" -C metadata=4befa7538c9a9f80 -C extra-filename=-4befa7538c9a9f80 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE"/deps/libproc_macro2-ef119f7eb3ef5720.rmeta --extern quote="$CARGO_TARGET_DIR/$PROFILE"/deps/libquote-74434efe692a445d.rmeta --extern unicode_ident="$CARGO_TARGET_DIR/$PROFILE"/deps/libunicode_ident-417636671c982ef8.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 935c4792b4e7e86fae13917aebbdccbf3a05c26856f5b09dcfa5386bd52bde6e "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name io_lifetimes --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="close" --cfg feature="default" --cfg feature="libc" --cfg feature="windows-sys" -C metadata=36f41602071771e6 -C extra-filename=-36f41602071771e6 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern libc="$CARGO_TARGET_DIR/$PROFILE"/deps/liblibc-9de7ca31dbbda4df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg io_safety_is_in_std --cfg panic_in_const_fn
ensure 112d5c4bc459c38843f5ce37369ce675069018518aa5fa458664e1b535ed21e5 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name rustix --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/rustix-0.37.6/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" --cfg feature="fs" --cfg feature="io-lifetimes" --cfg feature="libc" --cfg feature="std" --cfg feature="termios" --cfg feature="use-libc-auxv" -C metadata=120609be99d53c6b -C extra-filename=-120609be99d53c6b --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern bitflags="$CARGO_TARGET_DIR/$PROFILE"/deps/libbitflags-f255a966af175049.rmeta --extern io_lifetimes="$CARGO_TARGET_DIR/$PROFILE"/deps/libio_lifetimes-36f41602071771e6.rmeta --extern libc="$CARGO_TARGET_DIR/$PROFILE"/deps/liblibc-9de7ca31dbbda4df.rmeta --extern linux_raw_sys="$CARGO_TARGET_DIR/$PROFILE"/deps/liblinux_raw_sys-67b8335e06167307.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold --cfg linux_raw --cfg asm --cfg linux_like
ensure 9bb7a1fc562b237a662b413a3d21e79bce55a868b4349ff12539c6820bbf3824 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name tempfile --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/tempfile-3.5.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=018ce729f986d26d -C extra-filename=-018ce729f986d26d --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern cfg_if="$CARGO_TARGET_DIR/$PROFILE"/deps/libcfg_if-305ff6ac5e1cfc5a.rmeta --extern fastrand="$CARGO_TARGET_DIR/$PROFILE"/deps/libfastrand-f39af6f065361be9.rmeta --extern rustix="$CARGO_TARGET_DIR/$PROFILE"/deps/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 7e07d230803dec87e97701ec18626446659c84cd451986d727c83844520fc7f8 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name is_terminal --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/is-terminal-0.4.7/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=4b94fef286899229 -C extra-filename=-4b94fef286899229 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern io_lifetimes="$CARGO_TARGET_DIR/$PROFILE"/deps/libio_lifetimes-36f41602071771e6.rmeta --extern rustix="$CARGO_TARGET_DIR/$PROFILE"/deps/librustix-120609be99d53c6b.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 15bdbb8397e2cbcd7a1df2589fc4f1bc1c53dbe0bee28d5bd86a99e003ce72b5 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name anstream --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/anstream-0.2.6/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="auto" --cfg feature="default" --cfg feature="wincon" -C metadata=47e0535dab3ef0d2 -C extra-filename=-47e0535dab3ef0d2 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern anstyle="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstyle-3d9b242388653423.rmeta --extern anstyle_parse="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstyle_parse-0d4af9095c79189b.rmeta --extern concolor_override="$CARGO_TARGET_DIR/$PROFILE"/deps/libconcolor_override-305fddcda33650f6.rmeta --extern concolor_query="$CARGO_TARGET_DIR/$PROFILE"/deps/libconcolor_query-74e38d373bc944a9.rmeta --extern is_terminal="$CARGO_TARGET_DIR/$PROFILE"/deps/libis_terminal-4b94fef286899229.rmeta --extern utf8parse="$CARGO_TARGET_DIR/$PROFILE"/deps/libutf8parse-951ca9bdc6d60a50.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure fe77f7f8efbf78a44e9e2dc25b2b2af3823a48cb22b200c29300ddc38a701abc "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name clap_builder --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap_builder-4.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=02591a0046469edd -C extra-filename=-02591a0046469edd --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern anstream="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstream-47e0535dab3ef0d2.rmeta --extern anstyle="$CARGO_TARGET_DIR/$PROFILE"/deps/libanstyle-3d9b242388653423.rmeta --extern bitflags="$CARGO_TARGET_DIR/$PROFILE"/deps/libbitflags-f255a966af175049.rmeta --extern clap_lex="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap_lex-7dfc2f58447e727e.rmeta --extern strsim="$CARGO_TARGET_DIR/$PROFILE"/deps/libstrsim-8ed1051e7e58e636.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure abc761d7e43bb11db79e0823f549a1942df01d89bfa782b26fe06073c8948156 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name clap_derive --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap_derive-4.2.0/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type proc-macro --emit=dep-info,link -C prefer-dynamic -C embed-bitcode=no -C debuginfo=2 --cfg feature="default" -C metadata=a4ff03e749cd3808 -C extra-filename=-a4ff03e749cd3808 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern heck="$CARGO_TARGET_DIR/$PROFILE"/deps/libheck-cd1cdbedec0a6dc0.rlib --extern proc_macro2="$CARGO_TARGET_DIR/$PROFILE"/deps/libproc_macro2-ef119f7eb3ef5720.rlib --extern quote="$CARGO_TARGET_DIR/$PROFILE"/deps/libquote-74434efe692a445d.rlib --extern syn="$CARGO_TARGET_DIR/$PROFILE"/deps/libsyn-4befa7538c9a9f80.rlib --extern proc_macro --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure f5e51647aa7f63210277423b50332fe3c3e0a018e10554a472b13402591b4ec1 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name clap --edition=2021 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/clap-4.2.1/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="color" --cfg feature="default" --cfg feature="derive" --cfg feature="error-context" --cfg feature="help" --cfg feature="std" --cfg feature="suggestions" --cfg feature="usage" -C metadata=8996e440435cdc93 -C extra-filename=-8996e440435cdc93 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern clap_builder="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap_builder-02591a0046469edd.rmeta --extern clap_derive="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap_derive-a4ff03e749cd3808.so --extern once_cell="$CARGO_TARGET_DIR/$PROFILE"/deps/libonce_cell-da1c67e98ff0d3df.rmeta --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure ce6e368345e52f1d35c56552efac510ef2c7610738e3af297b54098db62ab537 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type lib --emit=dep-info,metadata,link -C embed-bitcode=no -C debuginfo=2 -C metadata=1052b4790952332f -C extra-filename=-1052b4790952332f --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rmeta --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rmeta --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rmeta -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure c68b91d305505ea79d63b8243c0a23d4356fe01e7fb8514d4b5b1b283d9f57ba "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name buildxargs --edition=2021 src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=4248d2626f765b01 -C extra-filename=-4248d2626f765b01 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 7f0d415e92dee6e18fd146ff23cab5c791c896b6a753a4fbcd0763709b76f3eb "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --test -C metadata=9b4fb3065c88e032 -C extra-filename=-9b4fb3065c88e032 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern buildxargs="$CARGO_TARGET_DIR/$PROFILE"/deps/libbuildxargs-1052b4790952332f.rlib --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure ea2d3233ffd643cbf4c57ab3831e01f64bbd47d57f4ed3f19aa976bc8205fad0 "$CARGO_TARGET_DIR/$PROFILE"/deps
_rustc --crate-name buildxargs --edition=2021 src/main.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 -C metadata=357a2a97fcd61762 -C extra-filename=-357a2a97fcd61762 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/deps -C linker=/usr/bin/clang -C incremental="$CARGO_TARGET_DIR/$PROFILE"/incremental -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --extern buildxargs="$CARGO_TARGET_DIR/$PROFILE"/deps/libbuildxargs-1052b4790952332f.rlib --extern clap="$CARGO_TARGET_DIR/$PROFILE"/deps/libclap-8996e440435cdc93.rlib --extern shlex="$CARGO_TARGET_DIR/$PROFILE"/deps/libshlex-df9eb4fba8dd532e.rlib --extern tempfile="$CARGO_TARGET_DIR/$PROFILE"/deps/libtempfile-018ce729f986d26d.rlib -C link-arg=-fuse-ld=/usr/local/bin/mold
ensure 6ef047ff4813ca9d5c64101357757f5b2f76a32037636e3a355655aeee72de35 "$CARGO_TARGET_DIR/$PROFILE"/deps
