use std::{assert_eq, process::Command};

use predicates::{str::diff, Predicate};

#[test]
fn cli_installed_docker_usage() {
    let cmd = Command::new("docker").arg("buildx").arg("version").output().unwrap();
    assert_eq!(cmd.status.code(), Some(0));
    let buildx_version = String::from_utf8_lossy(&cmd.stdout).into_owned();

    let cmd = Command::new("docker").arg("buildx").arg("bake").arg("--help").output().unwrap();
    assert_eq!(cmd.status.code(), Some(0));
    let matcher = diff(usages(&buildx_version).0);
    let blank = "\n                               ";
    assert!(matcher
        .find_case(false, &String::from_utf8_lossy(&cmd.stdout).replace(blank, " "))
        .map(|dif| eprintln!("{dif:?}"))
        .is_none());

    let cmd = Command::new("docker").arg("buildx").arg("build").arg("--help").output().unwrap();
    assert_eq!(cmd.status.code(), Some(0));
    let matcher = diff(usages(&buildx_version).1);
    let blank = "\n                                      ";
    assert!(matcher
        .find_case(false, &String::from_utf8_lossy(&cmd.stdout).replace(blank, " "))
        .map(|dif| eprintln!("{dif:?}"))
        .is_none());
}

#[inline]
fn usages(version: &str) -> (&'static str, &'static str) {
    let version: String = version.replace('+', " ").split_ascii_whitespace().take(2).collect();
    match version.as_str() {
        "github.com/docker/buildxv0.11.1" => (
            r#"
Usage:  docker buildx bake [OPTIONS] [TARGET...]

Build from a file

Aliases:
  docker buildx bake, docker buildx f

Options:
      --builder string         Override the configured builder instance
  -f, --file stringArray       Build definition file
      --load                   Shorthand for "--set=*.output=type=docker"
      --metadata-file string   Write build result metadata to the file
      --no-cache               Do not use cache when building the image
      --print                  Print the options without building
      --progress string        Set type of progress output ("auto", "plain", "tty"). Use plain to show container output (default "auto")
      --provenance string      Shorthand for "--set=*.attest=type=provenance"
      --pull                   Always attempt to pull all referenced images
      --push                   Shorthand for "--set=*.output=type=registry"
      --sbom string            Shorthand for "--set=*.attest=type=sbom"
      --set stringArray        Override target value (e.g., "targetpattern.key=value")
"#,
            r#"
Usage:  docker buildx build [OPTIONS] PATH | URL | -

Start a build

Aliases:
  docker buildx build, docker buildx b

Options:
      --add-host strings              Add a custom host-to-IP mapping (format: "host:ip")
      --allow strings                 Allow extra privileged entitlement (e.g., "network.host", "security.insecure")
      --attest stringArray            Attestation parameters (format: "type=sbom,generator=image")
      --build-arg stringArray         Set build-time variables
      --build-context stringArray     Additional build contexts (e.g., name=path)
      --builder string                Override the configured builder instance
      --cache-from stringArray        External cache sources (e.g., "user/app:cache", "type=local,src=path/to/dir")
      --cache-to stringArray          Cache export destinations (e.g., "user/app:cache", "type=local,dest=path/to/dir")
      --cgroup-parent string          Optional parent cgroup for the container
  -f, --file string                   Name of the Dockerfile (default: "PATH/Dockerfile")
      --iidfile string                Write the image ID to the file
      --label stringArray             Set metadata for an image
      --load                          Shorthand for "--output=type=docker"
      --metadata-file string          Write build result metadata to the file
      --network string                Set the networking mode for the "RUN" instructions during build (default "default")
      --no-cache                      Do not use cache when building the image
      --no-cache-filter stringArray   Do not cache specified stages
  -o, --output stringArray            Output destination (format: "type=local,dest=path")
      --platform stringArray          Set target platform for build
      --progress string               Set type of progress output ("auto", "plain", "tty"). Use plain to show container output (default "auto")
      --provenance string             Shorthand for "--attest=type=provenance"
      --pull                          Always attempt to pull all referenced images
      --push                          Shorthand for "--output=type=registry"
  -q, --quiet                         Suppress the build output and print image ID on success
      --sbom string                   Shorthand for "--attest=type=sbom"
      --secret stringArray            Secret to expose to the build (format: "id=mysecret[,src=/local/secret]")
      --shm-size bytes                Size of "/dev/shm"
      --ssh stringArray               SSH agent socket or keys to expose to the build (format: "default|<id>[=<socket>|<key>[,<key>]]")
  -t, --tag stringArray               Name and optionally a tag (format: "name:tag")
      --target string                 Set the target build stage to build
      --ulimit ulimit                 Ulimit options (default [])
"#,
        ),

        _ => ("UNHANDLED", "UNHANDLED"),
    }
}
