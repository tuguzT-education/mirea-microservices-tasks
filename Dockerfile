FROM rust:latest as builder
USER root
WORKDIR /usr/src/mirea-microservices-tasks
COPY . .
RUN cargo install --path .

FROM debian:buster-slim
RUN apt-get update && apt-get install -y ca-certificates tzdata wget gnupg
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get install -y libpq-dev
RUN rm -rf /var/lib/apt/lists/*

ENV DATABASE_URL postgres://postgres:password@localhost:5432/cringy-blog
ENV RUST_LOG debug
ENV GELF_ADDR 0.0.0.0:12201
EXPOSE 8080

COPY --from=builder /usr/local/cargo/bin/mirea-microservices-tasks /usr/local/bin/mirea-microservices-tasks
CMD mirea-microservices-tasks
