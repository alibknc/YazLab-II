import time
import zmq

context = zmq.Context()
socket = context.socket(zmq.PUB)
socket.bind("tcp://127.0.0.1:5555")

messages = [100,200,300]
curMsg = 0

while True:
    time.sleep(1)
    socket.send_pyobj({curMsg: messages[curMsg]})
    if(curMsg == 2):
        curMsg = 0
    else:
        curMsg = curMsg + 1