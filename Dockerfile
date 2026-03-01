# Use the latest golang Alpine image (unpinned) as requested
FROM golang:alpine AS builder
# Install build-time dependencies: C compiler, libpcap headers and upx
RUN apk add --no-cache git build-base libpcap-dev ca-certificates upx

# Build for linux with cgo enabled (pcap requires libpcap C API).
ENV GOOS=linux CGO_ENABLED=1
RUN go install -ldflags='-s -w' github.com/fragglet/ipxbox@latest
# UPX compress the binary to reduce size
RUN upx --best /go/bin/ipxbox || true

FROM alpine:latest
# Runtime deps: libpcap and certificates (minimal)
RUN apk add --no-cache libpcap ca-certificates

# Copy the built, (possibly) UPX-compressed binary from the builder stage
COPY --from=builder /go/bin/ipxbox /usr/local/bin/ipxbox

EXPOSE 213/udp
ENTRYPOINT ["/usr/local/bin/ipxbox"]
CMD ["--port","213"]