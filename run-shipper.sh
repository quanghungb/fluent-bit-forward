#!/bin/sh

podman run \
    -v ./fluent-bit/fluent-bit-shipper.yaml:/fluent-bit/etc/fluent-bit.yaml:ro \
    -v ./fluent-bit/parsers_multiline.conf:/fluent-bit/etc/parsers_multiline.conf:ro \
    -v ./log/system.log:/data/system.log \
    -v ./log/server.log:/data/server.log \
    --net fluent-bit-network \
    --name flb-shipper \
    --rm \
    fluent/fluent-bit:3.0.0  "/fluent-bit/bin/fluent-bit" "-c" "/fluent-bit/etc/fluent-bit.yaml"