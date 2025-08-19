#!/usr/bin/env bash
set -e

goreleaser release --snapshot --skip-publish --clean
if $PUSH_IMAGE; then
    docker push $IMAGE
fi