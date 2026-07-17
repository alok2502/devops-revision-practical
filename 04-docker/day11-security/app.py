from http.server import BaseHTTPRequestHandler, HTTPServer
import getpass, os
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.end_headers()
        self.wfile.write(f"Running as user: {getpass.getuser()} (uid={os.getuid()})\n".encode())
HTTPServer(("0.0.0.0",5000), H).serve_forever()
