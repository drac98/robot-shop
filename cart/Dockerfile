FROM node:14

ENV INSTANA_AUTO_PROFILE true

EXPOSE 8080

WORKDIR /opt/server

COPY package.json /opt/server/

RUN npm install

RUN apt-get update && apt-get install -y stress-ng && apt-get clean && rm -rf /var/lib/apt/lists/*


COPY server.js /opt/server/

COPY memory_leak.sh /opt/server/

# CMD ["sh" "./cart.sh"]
CMD ["node", "server.js"]

# CMD ["stress-ng", "--vm", "1", "--vm-bytes", "300M", "-t", "4h"]
