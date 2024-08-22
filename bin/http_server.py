#!/usr/bin/env python3

# A simple http server with additional support for PUT/POST method
#
# Examples:
# $ python httpserver.py
# $ python httpserver.py 8080
# $ nohup python -u httpserver.py &      # -u: force stdout and stderr to be unbuffered

import os
import sys

try:
    import http.server as httpserver  # Python 3
except ImportError:
    import SimpleHTTPServer as httpserver  # Python 2


class HTTPRequestHandler(httpserver.SimpleHTTPRequestHandler):
    def do_PUT(self):
        print(self.headers)
        length = 0
        if "Content-Length" in self.headers:
            length = int(self.headers["Content-Length"])
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            print("Error: A directory with same name exist in server")
            self.send_response(405, "Method Not Allowed")
        else:
            with open(path, "wb") as dst:
                dst.write(self.rfile.read(length))
            self.send_response(201)
        # Since Python 3.3, end_headers() needs to be called explicitly.
        self.end_headers()

    def do_POST(self):
        print(self.headers)
        length = 0
        if "Content-Length" in self.headers:
            length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(length)
        print(post_data)  # Just print the post data
        self.send_response(200)
        # Since Python 3.3, end_headers() needs to be called explicitly.
        self.end_headers()


HandlerClass = HTTPRequestHandler
ServerClass  = httpserver.HTTPServer
Protocol     = "HTTP/1.0"

host = '0.0.0.0'
if sys.argv[1:]:
    port = int(sys.argv[1])
else:
    port = 8000

server_address = (host, port)
print("Serving HTTP on", host, "port", port)

HandlerClass.protocol_version = Protocol
httpd = ServerClass(server_address, HandlerClass)
httpd.serve_forever()
