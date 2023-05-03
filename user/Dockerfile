FROM node:14

ENV INSTANA_AUTO_PROFILE true

EXPOSE 8080

WORKDIR /opt/server

COPY package.json /opt/server/

RUN npm install

RUN apt-get update && apt-get install -y iproute2

COPY server.js /opt/server/
COPY network.sh /opt/server/

CMD ["node", "server.js"]

