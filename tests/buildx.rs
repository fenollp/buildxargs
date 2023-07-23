use std::{assert_eq, process::Command};

use predicates::{str::diff, Predicate};

#[test]
fn cli_installed_docker_usage() {
    let cmd = Command::new("docker").arg("buildx").arg("version").output().unwrap();
    assert_eq!(cmd.status.code(), Some(0));
    let buildx_version = String::from_utf8_lossy(&cmd.stdout).into_owned();

    let cmd = Command::new("docker").env("DOCKER_BUILDKIT", "1").arg("--help").output().unwrap();
    assert_eq!(cmd.status.code(), Some(0));
    #[allow(deprecated)]
    let re_home = |usage: String| match std::env::home_dir() {
        None => usage,
        Some(home) => usage.replace(&home.into_os_string().into_string().unwrap(), "~"),
    };
    let matcher = diff(usages(&buildx_version).0);
    let blank = "\n                           ";
    assert!(matcher
        .find_case(false, &re_home(String::from_utf8_lossy(&cmd.stdout).replace(blank, " ")))
        .map(|dif| eprintln!("{dif:?}"))
        .is_none());

    let cmd = Command::new("docker").arg("buildx").arg("bake").arg("--help").output().unwrap();
    assert_eq!(cmd.status.code(), Some(0));
    let matcher = diff(usages(&buildx_version).1);
    let blank = "\n                               ";
    assert!(matcher
        .find_case(false, &String::from_utf8_lossy(&cmd.stdout).replace(blank, " "))
        .map(|dif| eprintln!("{dif:?}"))
        .is_none());

    let cmd = Command::new("docker").arg("buildx").arg("build").arg("--help").output().unwrap();
    assert_eq!(cmd.status.code(), Some(0));
    let matcher = diff(usages(&buildx_version).2);
    let blank = "\n                                      ";
    assert!(matcher
        .find_case(false, &String::from_utf8_lossy(&cmd.stdout).replace(blank, " "))
        .map(|dif| eprintln!("{dif:?}"))
        .is_none());
}

#[inline]
fn usages(version: &str) -> (&'static str, &'static str, &'static str) {
    let short: String = version.replace('+', " ").split_ascii_whitespace().take(2).collect();
    match short.as_str() {
        "github.com/docker/buildxv0.11.1" => (
            r#"
Usage:  docker [OPTIONS] COMMAND

A self-sufficient runtime for containers

Common Commands:
  run         Create and run a new container from an image
  exec        Execute a command in a running container
  ps          List containers
  build       Build an image from a Dockerfile
  pull        Download an image from a registry
  push        Upload an image to a registry
  images      List images
  login       Log in to a registry
  logout      Log out from a registry
  search      Search Docker Hub for images
  version     Show the Docker version information
  info        Display system-wide information

Management Commands:
  builder     Manage builds
  buildx*     Docker Buildx (Docker Inc., v0.11.1)
  compose*    Docker Compose (Docker Inc., v2.6.1)
  container   Manage containers
  context     Manage contexts
  image       Manage images
  manifest    Manage Docker image manifests and manifest lists
  network     Manage networks
  plugin      Manage plugins
  scan*       Docker Scan (Docker Inc., v0.23.0)
  system      Manage Docker
  trust       Manage trust on Docker images
  volume      Manage volumes

Swarm Commands:
  swarm       Manage Swarm

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  events      Get real time events from the server
  export      Export a container's filesystem as a tar archive
  history     Show the history of an image
  import      Import the contents from a tarball to create a filesystem image
  inspect     Return low-level information on Docker objects
  kill        Kill one or more running containers
  load        Load an image from a tar archive or STDIN
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  wait        Block until one or more containers stop, then print their exit codes

Global Options:
      --config string      Location of client config files (default "~/.docker")
  -c, --context string     Name of the context to use to connect to the daemon (overrides DOCKER_HOST env var and default context set with "docker context use")
  -D, --debug              Enable debug mode
  -H, --host list          Daemon socket to connect to
  -l, --log-level string   Set the logging level ("debug", "info", "warn", "error", "fatal") (default "info")
      --tls                Use TLS; implied by --tlsverify
      --tlscacert string   Trust certs signed only by this CA (default "~/.docker/ca.pem")
      --tlscert string     Path to TLS certificate file (default "~/.docker/cert.pem")
      --tlskey string      Path to TLS key file (default "~/.docker/key.pem")
      --tlsverify          Use TLS and verify the remote
  -v, --version            Print version information and quit

Run 'docker COMMAND --help' for more information on a command.

For more help on how to use Docker, head to https://docs.docker.com/go/guides/
"#,
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

        _ => {
            eprintln!("Unhandled version: {version:?}");
            ("UNHANDLED", "UNHANDLED", "UNHANDLED")
        }
    }
}
