FROM python:3.9

EXPOSE 8082
USER root

ENV INSTANA_SERVICE_NAME=payment

WORKDIR /app

COPY requirements.txt /app/

RUN pip install -r requirements.txt

COPY *.py /app/
#COPY payment.ini /app/

CMD ["python", "listener_ratings.py"]
#CMD ["uwsgi", "--ini", "payment.ini"]

