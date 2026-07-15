from http.server import BaseHTTPRequestHandler, HTTPServer
import os, socket

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        msg = f"""
        <h1>Hello from my first custom container!</h1>
        <p>Served by hostname: <b>{socket.gethostname()}</b></p>
        <p>This hostname is the container ID — proof I'm in my own UTS namespace.</p>
        """
        self.wfile.write(msg.encode())

print("Starting server on :5000")
HTTPServer(("0.0.0.0", 5000), H).serve_forever()
