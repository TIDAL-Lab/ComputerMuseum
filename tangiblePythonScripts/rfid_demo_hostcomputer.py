
 #-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      dhpollock
#
# Created:     09/06/2014
# Copyright:   (c) dhpollock 2014
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import serial
from multiprocessing import Process, Queue
import threading
from wsgiref.simple_server import make_server
from ws4py.websocket import EchoWebSocket
from ws4py.server.wsgirefserver import WSGIServer, WebSocketWSGIRequestHandler
from ws4py.server.wsgiutils import WebSocketWSGIApplication
from ws4py.websocket import WebSocket
import sys
import signal
import time

#websocket handler
class MyHandler(WebSocket):

	serOutput = serial.Serial()
	serialThread = threading.Thread()
	serialLoop = True
	
	def received_message(self, message):
		if(MyHandler.serOutput.isOpen() == False):
			print("trying to connect to serial port...")
			# self.serialConnect()
			MyHandler.serialThread = threading.Thread(target = self.serialConnect, args = ()).start()
			

		if(message.data == "hello?"):
			self.send("hi", message.is_binary)

		elif(message.data == "fake"):
			self.send("hop, chirp, hop", message.is_binary)
            
		else:
			print(message.data)
			self.send(message.data, message.is_binary)

	def serialConnect(self):
		connected = False
		try:
			MyHandler.serOutput = serial.Serial("/dev/cu.PL2303-00002014", baudrate=115200, timeout=3.0)
			if(MyHandler.serOutput.isOpen()):
				MyHandler.serOutput.close()
			MyHandler.serOutput.open()
			MyHandler.serOutput.flushInput()
			MyHandler.serOutput.flushOutput()
			connected = True
			print("serial connected")
		except:
			print("unable to connect to main serial port, oops")
		while(MyHandler.serialLoop):
			if(connected):
				if(MyHandler.serOutput.inWaiting() > 2):
					line = MyHandler.serOutput.readline()
					print(line)
					try:
						self.send(line)
					except:
						print("whoops, try restarting server then client")

def close(myserver):
		print("closing program, stopping server")
		MyHandler.serialLoop = False
		time.sleep(.25)
		MyHandler.serOutput.close()
		myserver.shutdown()
		sys.exit()

def main():
	
	try:
		#setup websocket server
		# try:
		server = make_server("localhost", 9067, server_class=WSGIServer,
	    	handler_class=WebSocketWSGIRequestHandler,
	    	app=WebSocketWSGIApplication(handler_cls=MyHandler))
		serverThread = threading.Thread(target = startmyServer, args = (server,)).start()
		# except:
			# print("unable to setup websocket server")
		# server.initialize_websockets_manager()
		# server.serve_forever()
		# signal.signal(singal.SIGINT, close)
		# signal.pause()
		time.sleep(0.1)
		print("type command 'exit:' to stop server and then control+z to quit")
		while(True):
			command = raw_input("Command: ")

			if(command == 'exit'):
				closer(server)
			elif(command == 'fake'):
				MyHandler.send("testsend")

	except Exception as e:
		print(e)
		close(server)


def startmyServer(server):
	print("server started: ")
	print(server.server_address)
	server.initialize_websockets_manager()
	server.serve_forever()

if __name__ == '__main__':

    main()