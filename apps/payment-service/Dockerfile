FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download || true
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o payment-service .

FROM alpine:3.19
RUN adduser -D -u 10001 appuser
USER 10001:10001
WORKDIR /home/appuser
COPY --from=builder /app/payment-service /home/appuser/payment-service
EXPOSE 8084
ENTRYPOINT ["/home/appuser/payment-service"]
