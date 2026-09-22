# Stage 1: Build
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod ./
RUN go mod download || true

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o auth-service .

# Stage 2: Minimal Distroless / Alpine Non-Root Image
FROM alpine:3.19

# Security: Run as non-root user (UID 10001)
RUN adduser -D -u 10001 appuser
USER 10001:10001

WORKDIR /home/appuser
COPY --from=builder /app/auth-service /home/appuser/auth-service

EXPOSE 8081

ENTRYPOINT ["/home/appuser/auth-service"]
