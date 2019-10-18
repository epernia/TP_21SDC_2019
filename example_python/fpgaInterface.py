import numpy as np
import socket
import time as t
s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('192.168.1.10', 7))

data = np.random.randint(0,16,16)

print(data)
start = t.time()
s.send(data.tobytes())
end = t.time()+0.0001
dataLen = len(data.tobytes())
dataRate = dataLen / (end - start) * 8
print('Bytes sent: {0!s} @{1!s}'.format(dataLen,dataRate))

start = t.time()
recvData = s.recv(len(data.tobytes()))
end = t.time()+0.0001
dataLen = len(recvData)
dataRate = dataLen / (end - start) * 8
print('Bytes received: {0!s} @{1!s}'.format(dataLen,dataRate))

rxData = np.frombuffer(recvData, dtype=int)
print(rxData)
