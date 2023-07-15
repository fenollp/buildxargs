use assert_cmd::{crate_name, Command};

#[test]
fn cli_main_usage() {
    let mut cmd = Command::cargo_bin(crate_name!()).unwrap();
    cmd.arg("--help").assert().success().code(0).stdout(
        r#"xargs for BuildKit with docker buildx bake

Usage: buildxargs [OPTIONS]

Options:
  -f, --file <FILE>          Read commands from file [default: -]
      --no-cache             Do not use cache when building the image
      --print                Print the options without building
      --progress <PROGRESS>  Set type of progress output ("plain", "tty") [default: auto]
      --pull                 Always attempt to pull all referenced images
      --debug                Print more things
      --retry <RETRY>        Retry each failed build at most this many times [default: 3]
  -h, --help                 Print help
  -V, --version              Print version
"#,
    );
}
