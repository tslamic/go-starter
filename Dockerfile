# syntax=docker/dockerfile:1

FROM golang:latest AS builder
ARG LDFLAGS
WORKDIR /builder
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY ./ .
RUN CGO_ENABLED=0 sh -c "go build -o app -ldflags '${LDFLAGS}'"

FROM alpine:latest
RUN addgroup -S builder && adduser -S builder -G builder
USER builder
COPY --from=builder /builder/app .
CMD ["./app"]
