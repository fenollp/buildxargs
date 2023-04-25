#!/bin/bash -eu
# trash _targetWell >/dev/null 2>&1; shellcheck ./well.sh && DEBUG=1 ./well.sh

PROFILE=${PROFILE:-debug}
CARGO_HOME=${CARGO_HOME:-$HOME/.cargo}
CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-$PWD/_targetWell}

./tryin.sh --crate-name build_script_build --edition=2018 "$CARGO_HOME"/registry/src/github.com-1ecc6299db9ec823/io-lifetimes-1.0.3/build.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts,future-incompat --diagnostic-width=211 --crate-type bin --emit=dep-info,link -C embed-bitcode=no -C debuginfo=2 --cfg feature="close" --cfg feature="default" --cfg feature="libc" --cfg feature="windows-sys" -C metadata=5fc4d6e9dda15f11 -C extra-filename=-5fc4d6e9dda15f11 --out-dir "$CARGO_TARGET_DIR/$PROFILE"/build/io-lifetimes-5fc4d6e9dda15f11 -C linker=/usr/bin/clang -L dependency="$CARGO_TARGET_DIR/$PROFILE"/deps --cap-lints allow -C link-arg=-fuse-ld=/usr/local/bin/mold
