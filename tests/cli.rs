use assert_cmd::Command;
use assert_fs::prelude::{FileWriteStr, PathChild};
use predicates::{prelude::PredicateBooleanExt, str::contains};

const COMMANDS: &str = r#"
docker build                          --allow=fs.write=$TMP --output=type=local,dest=$TMP --build-arg IMG_URL='https://img.freepik.com/free-vector/hand-drawn-fresh-pineapple-vector_53876-108732.jpg?t=st=1728727735~exp=1728731335~hmac=8c5e57ed27047cf4e179a33d9c010b2a624a9f9502c181b278c7b4cace21e1d5&w=740' --build-arg ARGs='-o output.svg -rep 9 -m 6 -n 99 -v -bg FFF' https://github.com/fenollp/dockerhost-tools.git#main:/primitive
docker build -o=$TMP --platform=local --allow=fs.write=$TMP --build-arg PREBUILT=1 https://github.com/FuzzyMonkeyCo/monkey.git
docker build         --platform=local --allow=fs.write=$TMP -o $TMP                https://github.com/docker/buildx.git
"#;

const PRINTED: &str = r#"{
  "group": {
    "default": {
      "targets": [
        "1",
        "2",
        "3"
      ]
    }
  },
  "target": {
    "1": {
      "context": "https://github.com/fenollp/dockerhost-tools.git#main:/primitive",
      "dockerfile": "Dockerfile",
      "args": {
        "ARGs": "-o output.svg -rep 9 -m 6 -n 99 -v -bg FFF",
        "IMG_URL": "https://img.freepik.com/free-vector/hand-drawn-fresh-pineapple-vector_53876-108732.jpg?t=st=1728727735~exp=1728731335~hmac=8c5e57ed27047cf4e179a33d9c010b2a624a9f9502c181b278c7b4cace21e1d5\u0026w=740"
      },
      "output": [
        {
          "dest": "$TMP",
          "type": "local"
        }
      ]
    },
    "2": {
      "context": "https://github.com/FuzzyMonkeyCo/monkey.git",
      "dockerfile": "Dockerfile",
      "args": {
        "PREBUILT": "1"
      },
      "platforms": [
        "local"
      ],
      "output": [
        {
          "dest": "$TMP",
          "type": "local"
        }
      ]
    },
    "3": {
      "context": "https://github.com/docker/buildx.git",
      "dockerfile": "Dockerfile",
      "platforms": [
        "local"
      ],
      "output": [
        {
          "dest": "$TMP",
          "type": "local"
        }
      ]
    }
  }
}
"#;

#[test]
fn cli_print_piped() {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
    cmd.arg("--debug")
        .arg("--print")
        .write_stdin(COMMANDS)
        .assert()
        .success()
        .code(0)
        .stdout(PRINTED);
}

#[test]
fn cli_docker_uses_debug() {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
    cmd.write_stdin(
        "docker --debug build --platform=local -o $TMP https://github.com/docker/buildx.git",
    )
    .assert()
    .failure()
    .code(1)
    .stdout("")
    .stderr(contains(r#"Error: "Unsupported `docker --debug`""#));
}

#[test_case::test_matrix([true, false])]
fn cli_exec_file(no_cache: bool) {
    let tmp_dir = assert_fs::TempDir::new().unwrap();

    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
    cmd.write_stdin(COMMANDS.replace("$TMP", &tmp_dir.path().to_string_lossy()));
    if no_cache {
        cmd.arg("--no-cache");
    }
    cmd.assert().success().code(0).stdout("");
}

#[test_case::test_matrix([true, false])]
fn cli_exec_retrying(no_cache: bool) {
    let tmp_dir = assert_fs::TempDir::new().unwrap();
    let girouette_dockerfile = tmp_dir.child("girouette.Dockerfile");
    girouette_dockerfile
        .write_str(
            r#"
# syntax = docker/dockerfile:1
FROM --platform=$BUILDPLATFORM alpine AS tryin
ARG FAIL
ARG SLEEP=1
RUN set -ux && sleep "$SLEEP" && [[ -z "${FAIL:-}" ]] && echo Passed! >/girouette
FROM scratch
COPY --from=tryin /girouette /
"#,
        )
        .unwrap();
    let girouette_dockerfile = girouette_dockerfile.path().display();
    let tmp_dir = tmp_dir.path().display();

    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
    cmd.arg("--debug");
    if no_cache {
        cmd.arg("--no-cache");
    }
    cmd.write_stdin(format!(
        r#"
docker build -o={tmp_dir} --build-arg FAIL=1 -f {girouette_dockerfile} .
docker build -o={tmp_dir}                    -f {girouette_dockerfile} .
"#
    ))
    .assert()
    .failure()
    .code(1)
    .stdout("")
    .stderr(
        contains(format!(
            r#"
Terminated successfully:
  docker build -o={tmp_dir}                    -f {girouette_dockerfile} .
Failed:
  docker build -o={tmp_dir} --build-arg FAIL=1 -f {girouette_dockerfile} .
    command `docker buildx bake` failed with 1
"#
        ))
        .and(
            contains(r#""1 jobs failed after 3 retries""#)
                .or(contains(r#""2 jobs failed after 3 retries""#)),
        ),
    );
}
