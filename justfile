set shell := ["nu", "-c"]
ver := `open Cargo.toml | get package.version`
image := "ghcr.io/virto-network/virto-proxy"

@default:
	just --list

@version:
	echo {{ ver }}

build-container:
	#!/usr/bin/env nu
	'FROM rust:1.75 as builder
	RUN apt update && apt install -y cmake
	WORKDIR /tmp
	COPY . /tmp
	RUN --mount=type=cache,target=/home/rust/.cargo/git \
	--mount=type=cache,target=/home/rust/.cargo/registry \
	cargo build --release

	FROM debian:bookworm-slim
	COPY --from=builder /tmp/target/release/virto-proxy /usr/bin
	LABEL io.containers.autoupdate="registry"
	ENTRYPOINT ["/usr/bin/virto-proxy"]'
	| podman build . -t {{ image }}:{{ ver }} -t {{ image }}:latest --ignorefile .build-container-ignore -f -
