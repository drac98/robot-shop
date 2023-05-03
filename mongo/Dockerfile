FROM mongo:5

COPY *.js /docker-entrypoint-initdb.d/
COPY network.sh /docker-entrypoint-initdb.d/

RUN apt-get update && apt-get install -y iproute2
