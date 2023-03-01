import random
import threading
import instana
import os
import sys
import time
import logging
import uuid
import json
import requests
import traceback
from flask import Flask
from flask import Response
from flask import request
from flask import jsonify
from rabbitmq import Publisher
# Prometheus
import prometheus_client
from prometheus_client import Counter, Histogram

app = Flask(__name__)
app.logger.setLevel(logging.INFO)

CART = os.getenv('CART_HOST', 'cart')
USER = os.getenv('USER_HOST', 'user')
PAYMENT_GATEWAY = os.getenv('PAYMENT_GATEWAY', 'https://paypal.com/')

# Prometheus
PromMetrics = {}
PromMetrics['SOLD_COUNTER'] = Counter('sold_count', 'Running count of items sold')
PromMetrics['AUS'] = Histogram('units_sold', 'Avergae Unit Sale', buckets=(1, 2, 5, 10, 100))
PromMetrics['AVS'] = Histogram('cart_value', 'Avergae Value Sale', buckets=(100, 200, 500, 1000, 2000, 5000, 10000))
PromMetrics['rt_web_post_payment'] = Histogram('rt_web_post_payment', 'Pay response time', buckets=(0,10,50,100,200,500,1000,5000,10000))
PromMetrics['rt_payment_post_user'] = Histogram('rt_payment_post_user', 'Post order response time', buckets=(0,10,50,100,200,500,1000,5000,10000))
PromMetrics['rt_payment_get_user'] = Histogram('rt_payment_get_user', 'Check user id response time', buckets=(0,10,50,100,200,500,1000,5000,10000))
PromMetrics['rt_payment_delete_cart'] = Histogram('rt_payment_delete_cart', 'Delete cart response time', buckets=(0,10,50,100,200,500,1000,5000,10000))

first = True
@app.errorhandler(Exception)
def exception_handler(err):
    app.logger.error(str(err))
    return str(err), 500

@app.route('/health', methods=['GET'])
def health():
    return 'OK'

# Prometheus
@app.route('/metrics', methods=['GET'])
def metrics():
    global first
    if (first):
        thread1 = threading.Thread(target=my_function1)
        thread1.start()
        thread2 = threading.Thread(target=my_function2)
        thread3 = threading.Thread(target=my_function3)
        thread2.start()
        thread3.start()
        first=False
    res = []
    for m in PromMetrics.values():
        res.append(prometheus_client.generate_latest(m))

    return Response(res, mimetype='text/plain')


@app.route('/pay/<id>', methods=['POST'])
def proccess_pay(id): #Calculates response time taken to process and send the response
    start = time.time()
    cart = request.get_json()
    res = pay(id,cart)
    PromMetrics['rt_web_post_payment'].observe(int((time.time()-start)*1000))
    # time.time() gives time to 1us precision, for 1ns use time.perf_counter_ns()
    return res

def pay(id,cart):
    app.logger.info('payment for {}'.format(id))
    
    app.logger.info(cart)

    anonymous_user = True

    # check user exists
    try:
        start = time.time()
        req = requests.get('http://{user}:8080/check/{id}'.format(user=USER, id=id))
        PromMetrics['rt_payment_get_user'].observe(int((time.time()-start)*1000))
    except requests.exceptions.RequestException as err:
        app.logger.error(err)
        return str(err), 500
    if req.status_code == 200:
        anonymous_user = False

    # check that the cart is valid
    # this will blow up if the cart is not valid
    has_shipping = False
    for item in cart.get('items'):
        if item.get('sku') == 'SHIP':
            has_shipping = True

    if cart.get('total', 0) == 0 or has_shipping == False:
        app.logger.warn('cart not valid')
        return 'cart not valid', 400

    # dummy call to payment gateway, hope they dont object
    time.sleep(0.2) # for execute payment 
    # try:
    #     req = requests.get(PAYMENT_GATEWAY)
    #     app.logger.info('{} returned {}'.format(PAYMENT_GATEWAY, req.status_code))
    # except requests.exceptions.RequestException as err:
    #     app.logger.error(err)
    #     return str(err), 500
    # if req.status_code != 200:
    #     return 'payment error', req.status_code

    # Prometheus
    # items purchased
    item_count = countItems(cart.get('items', []))
    PromMetrics['SOLD_COUNTER'].inc(item_count)
    PromMetrics['AUS'].observe(item_count)
    PromMetrics['AVS'].observe(cart.get('total', 0))

    # Generate order id
    orderid = str(uuid.uuid4())
    queueOrder({ 'orderid': orderid, 'user': id, 'cart': cart })

    # add to order history
    if not anonymous_user:
        try:
            start = time.time()
            req = requests.post('http://{user}:8080/order/{id}'.format(user=USER, id=id),
                    data=json.dumps({'orderid': orderid, 'cart': cart}),
                    headers={'Content-Type': 'application/json'})
            app.logger.info('order history returned {}'.format(req.status_code))
            PromMetrics['rt_payment_post_user'].observe(int((time.time()-start)*1000))
        except requests.exceptions.RequestException as err:
            app.logger.error(err)
            return str(err), 500

    # delete cart
    try:
        start = time.time()
        req = requests.delete('http://{cart}:8080/cart/{id}'.format(cart=CART, id=id));
        PromMetrics['rt_payment_delete_cart'].observe(int((time.time()-start)*1000))
        app.logger.info('cart delete returned {}'.format(req.status_code))
    except requests.exceptions.RequestException as err:
        app.logger.error(err)
        return str(err), 500
    if req.status_code != 200:
        return 'order history update error', req.status_code

    return jsonify({ 'orderid': orderid })


def queueOrder(order):
    app.logger.info('queue order')

    # For screenshot demo requirements optionally add in a bit of delay
    delay = int(os.getenv('PAYMENT_DELAY_MS', 0))
    time.sleep(delay / 1000)

    headers = {}
    publisher.publish(order, headers)


def countItems(items):
    count = 0
    for item in items:
        if item.get('sku') != 'SHIP':
            count += item.get('qty')

    return count

def my_function1():
    # do some work here
    while True:
        time.sleep(1)
        f = open("test1.txt","a+")
        for i in range (10000):
            f.write(str(i))
        f.close()
def my_function2():
    # do some work here
    while True:
        #print("HHHHHHHHHHHHHHHHHHH")
        time.sleep(1)
        f = open("test2.txt","a+")
        for i in range (10000):
            f.write(str(i))
        f.close()
def my_function3():
    # do some work here
    while True:
        time.sleep(1)
        f = open("test3.txt","a+")
        for i in range (10000):
            f.write(str(i))
        f.close()   
        

# RabbitMQ
publisher = Publisher(app.logger)
if __name__ == "__main__":
    sh = logging.StreamHandler(sys.stdout)
    sh.setLevel(logging.INFO)
    fmt = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    app.logger.info('Payment gateway {}'.format(PAYMENT_GATEWAY))
    port = int(os.getenv("SHOP_PAYMENT_PORT", "8080"))
    app.logger.info('Starting on port {}'.format(port))
    app.run(host='0.0.0.0', port=port)
    