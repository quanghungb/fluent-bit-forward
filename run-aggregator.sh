#!/bin/sh

podman run \
    -v ./fluent-bit/fluent-bit-aggregator.yaml:/fluent-bit/etc/fluent-bit.yaml:ro \
    -v ./fluent-bit/parsers_multiline.conf:/fluent-bit/etc/parsers_multiline.conf:ro \
    -v ./fluent-bit/storage:/storage \
    -v ./fluent-bit/output:/output \
    --net fluent-bit-network \
    --name flb-aggregator \
    --rm \
    fluent/fluent-bit:3.0.2  "/fluent-bit/bin/fluent-bit" "-c" "/fluent-bit/etc/fluent-bit.yaml"