FROM debian:stable-slim

RUN apt-get update -y \
    && apt-get install -y nano vim net-tools \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN mkdir -p /app
WORKDIR /app

CMD ["sleep", "infinity"]