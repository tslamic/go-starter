#!/bin/bash -e

CGO="${CGO_ENABLED:=0}"
LDF="${LDFLAGS:+-ldflags=$LDFLAGS}"
CGO_ENABLED="$CGO" go build -o app "$LDF"
