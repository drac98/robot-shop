FROM python:3.9

EXPOSE 8080
USER root

ENV INSTANA_SERVICE_NAME=payment

WORKDIR /app

COPY requirements.txt /app/

RUN pip install -r requirements.txt
RUN apt-get update && apt-get install -y stress-ng && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY payment.sh.sh /app/

COPY *.py /app/
COPY payment.ini /app/

#CMD ["python", "payment.py"]
CMD ["uwsgi", "--ini", "payment.ini"]

