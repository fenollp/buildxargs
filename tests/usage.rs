use predicates::str::contains;

#[test]
fn cli_main_usage() {
    let mut cmd = assert_cmd::cargo::cargo_bin_cmd!();
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
