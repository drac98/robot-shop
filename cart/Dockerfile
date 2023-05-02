FROM node:14

ENV INSTANA_AUTO_PROFILE true

EXPOSE 8080

WORKDIR /opt/server

COPY package.json /opt/server/

RUN npm install
RUN apt-get update && apt-get install -y stress-ng && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY cart.sh /opt/server/

COPY server.js /opt/server/

CMD ["node", "server.js"]

