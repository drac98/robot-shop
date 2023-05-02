FROM golang:1.17

WORKDIR /go/src/app
EXPOSE 8080
COPY *.go .

RUN go mod init dispatch && go get
RUN go install
RUN apt-get update && apt-get install -y stress-ng && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY memory_leak.sh /go/src/app/

CMD dispatch
