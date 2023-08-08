docker --debug buildx bake out-0d4af9095c79189b -f- <<BAKEFILE
target "out-0d4af9095c79189b" {
  dockerfile-inline = <<DOCKERFILE
# syntax=docker.io/docker/dockerfile:1@sha256:39b85bbfa7536a5feceb7372a0817649ecb2724562a38360f4d6a7782a409b14
FROM docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094 AS src_lib_rs-lib-utf8parse-951ca9bdc6d60a50
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
RUN \
    touch /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libutf8parse-951ca9bdc6d60a50.rmeta
FROM scratch AS out-951ca9bdc6d60a50
COPY --from=src_lib_rs-lib-utf8parse-951ca9bdc6d60a50 /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-951ca9bdc6d60a50* /

FROM docker.io/library/rust:1.68.2-slim@sha256:df4d8577fab8b65fabe9e7f792d6f4c57b637dd1c595f3f0a9398a9854e17094 AS src_lib_rs-lib-anstyle_parse-0d4af9095c79189b
WORKDIR /home/pete/wefwefwef/buildxargs.git/_target/debug/deps
RUN \
  --mount=type=bind,from=out-951ca9bdc6d60a50,source=/libutf8parse-951ca9bdc6d60a50.rmeta,target=/home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libutf8parse-951ca9bdc6d60a50.rmeta \
    touch /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/libanstyle_parse-0d4af9095c79189b.rmeta
FROM scratch AS out-0d4af9095c79189b
COPY --from=src_lib_rs-lib-anstyle_parse-0d4af9095c79189b /home/pete/wefwefwef/buildxargs.git/_target/debug/deps/*-0d4af9095c79189b* /
DOCKERFILE
  target = "out-0d4af9095c79189b"
}
BAKEFILE
