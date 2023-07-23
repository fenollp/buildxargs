use assert_cmd::Command;
use assert_fs::prelude::{FileWriteStr, PathChild};
use predicates::{prelude::PredicateBooleanExt, str::contains};

const COMMANDS: &str = r#"
docker build                          --build-arg DO_NOT_REENCODE=1 --build-arg ARGs='--format mp4 -- https://www.youtube.com/watch?v=Hj7LwZqTflc' --output=$TMP https://github.com/fenollp/dockerhost-tools--yt-dlp.git
docker build -o=$TMP --platform=local --build-arg PREBUILT=1 https://github.com/FuzzyMonkeyCo/monkey.git
docker build         --platform=local -o $TMP                https://github.com/docker/buildx.git
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
      "context": "https://github.com/fenollp/dockerhost-tools--yt-dlp.git",
      "dockerfile": "Dockerfile",
      "args": {
        "ARGs": "--format mp4 -- https://www.youtube.com/watch?v=Hj7LwZqTflc",
        "DO_NOT_REENCODE": "1"
      },
      "output": [
        "$TMP"
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
        "$TMP"
      ]
    },
    "3": {
      "context": "https://github.com/docker/buildx.git",
      "dockerfile": "Dockerfile",
      "platforms": [
        "local"
      ],
      "output": [
        "$TMP"
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
fn cli_print_file() {
    let tmp_file = assert_fs::TempDir::new().unwrap().child("commands.txt");
    tmp_file.write_str(COMMANDS).unwrap();

    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
    cmd.arg("-f").arg(tmp_file.path()).arg("--print").assert().success().code(0).stdout(PRINTED);
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

#[test]
fn cli_print_file_that_does_not_exist() {
    let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
    cmd.arg("-f")
        .arg("unexisting.txt")
        .arg("--print")
        .assert()
        .failure()
        .code(1)
        .stdout("")
        .stderr(contains(r#"Error: "not found: unexisting.txt""#));
}

#[test]
fn cli_exec_file() {
    let tmp_dir = assert_fs::TempDir::new().unwrap();
    let tmp_file = tmp_dir.child("commands.txt");
    tmp_file.write_str(&COMMANDS.replace("$TMP", &tmp_dir.path().to_string_lossy())).unwrap();

    for no_cache in [true, false] {
        let mut cmd = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
        cmd.arg("-f").arg(tmp_file.path());
        if no_cache {
            cmd.arg("--no-cache");
        }
        cmd.assert().success().code(0).stdout("");
    }
}

#[test]
fn cli_exec_retrying() {
    let tmp_dir = assert_fs::TempDir::new().unwrap();
    let girouette_dockerfile = tmp_dir.child("girouette.Dockerfile");
    girouette_dockerfile.write_str(r#"
# syntax=docker.io/docker/dockerfile:1@sha256:443aab4ca21183e069e7d8b2dc68006594f40bddf1b15bbd83f5137bd93e80e2
FROM --platform=$BUILDPLATFORM docker.io/library/alpine@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872 AS alpine
FROM alpine AS tryin
ARG FAIL
ARG SLEEP=1
RUN set -ux && sleep "$SLEEP" && [[ -z "${FAIL:-}" ]] && echo Passed! >/girouette
FROM scratch
COPY --from=tryin /girouette /
"#).unwrap();
    let girouette_dockerfile = girouette_dockerfile.path().display();
    let tmp_dir = tmp_dir.path().display();

    for no_cache in [true, false] {
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
}
