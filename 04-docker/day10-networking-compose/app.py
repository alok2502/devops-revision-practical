from http.server import BaseHTTPRequestHandler, HTTPServer
import os, psycopg2, time

def get_conn():
    for _ in range(10):  # retry: db may not be ready when web starts
        try:
            return psycopg2.connect(host="db", user="postgres",
                                    password=os.environ["DB_PASSWORD"], dbname="postgres")
        except Exception:
            time.sleep(2)
    raise Exception("could not connect to db")

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        conn = get_conn(); cur = conn.cursor()
        cur.execute("CREATE TABLE IF NOT EXISTS visits(id SERIAL PRIMARY KEY);")
        cur.execute("INSERT INTO visits DEFAULT VALUES;")
        cur.execute("SELECT COUNT(*) FROM visits;")
        count = cur.fetchone()[0]; conn.commit(); conn.close()
        self.send_response(200); self.send_header("Content-type","text/html"); self.end_headers()
        self.wfile.write(f"<h1>Visit count: {count}</h1><p>web + db wired via Compose</p>".encode())

print("web up on :5000"); HTTPServer(("0.0.0.0",5000), H).serve_forever()
