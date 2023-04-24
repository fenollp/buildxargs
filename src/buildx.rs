#[test]
fn installed_docker_buildx_version() {
    // docker buildx version
    assert_eq!("", "github.com/docker/buildx v0.10.4 c513d34");
}

// docker buildx bake --help
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
"#

// docker buildx build --help
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
      --provenance string             Shortand for "--attest=type=provenance"
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
"#

// Could not parse docker build --platform=local --network none --build-context deps=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps --build-context rust=docker-image://docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094 --file /tmp/tmp.gFbGCMbnpZ --output /home/pete/wefwefwef/buildxargs.git/_target/debug/deps     --target out         /home/pete/wefwefwef/buildxargs.git
