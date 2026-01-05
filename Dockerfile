# https://docs.docker.com/language/golang/build-images/#multi-stage-builds
# https://hub.docker.com/_/golang/tags
FROM  registry.hub.docker.com/library/golang:1.21.3-alpine3.18 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
COPY *.go ./
COPY cmd/transmission-exporter/* cmd/transmission-exporter/

RUN go mod download \
  && go build -v ./cmd/transmission-exporter

# 2. stage
FROM alpine:3.18.4
COPY --from=build /app/transmission-exporter /usr/bin/transmission-exporter
# COPY --chmod=755 .. requires Buildkit

# Antoine Edit
## 2024-04 - no ca-certificates
RUN chmod 755 /usr/bin/transmission-exporter
## 2024-04 - Should work but not in future
#RUN chmod 755 /usr/bin/transmission-exporter \
#  && apk add --no-cache ca-certificates=20240226-r0
## Original
#RUN chmod 755 /usr/bin/transmission-exporter \
#  && apk add --no-cache ca-certificates=20230506-r0

EXPOSE 19091

ENTRYPOINT ["/usr/bin/transmission-exporter"]
