# syntax=docker/dockerfile:1

FROM golang:1.21 AS builder
ARG LDFLAGS=''
ARG CGO_ENABLED=0
WORKDIR /builder
COPY go.mod go.sum ./
RUN go mod download
COPY ./ .
RUN chmod +x ./bin/build.sh && ./bin/build.sh

FROM scratch
COPY --from=builder /builder/app .
CMD ["./app"]
