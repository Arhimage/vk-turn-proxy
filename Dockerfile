FROM golang:1.25 AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY server ./server

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w -checklinkname=0" \
    -o /out/server ./server

FROM gcr.io/distroless/static-debian12

WORKDIR /app

COPY --from=build /out/server /app/server

ENTRYPOINT ["/app/server"]
CMD ["-listen", "0.0.0.0:56000"]
