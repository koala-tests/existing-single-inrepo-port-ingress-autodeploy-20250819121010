FROM golang:1.20-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server ./main.go

# Final stage
FROM alpine:latest

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/server .

# Copy VERSION file if it exists
COPY --from=builder /app/VERSION* ./

ENTRYPOINT ["./server"]
