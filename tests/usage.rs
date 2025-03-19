use assert_cmd::Command;
use predicates::str::contains;

#[test]
fn cli_main_usage() {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
    cmd.arg("--help").assert().success().code(0).stdout(contains(
        r#"
--

xargs for BuildKit with docker buildx bake

Usage: buildxargs [BAKE OPTIONS] [OPTIONS]

Options:
      --retry <RETRY>        Retry each failed build at most this many times [default: 3]
      --help                 Print help
  -V, --version              Print version
"#,
    ));
}
