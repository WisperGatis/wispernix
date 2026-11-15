#!/usr/bin/env python3
"""Serves ~/.config/web-palette/palette.json on 127.0.0.1:8765 for the extension.

Only that one file is served, with CORS enabled so the extension's background
worker can fetch it. Started by the web-palette-server user service.
"""
import http.server
import os
import pathlib

HOST, PORT = "127.0.0.1", 8765
PALETTE = pathlib.Path(os.path.expanduser("~/.config/web-palette/palette.json"))


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.split("?")[0] != "/palette.json":
            self.send_error(404)
            return
        try:
            body = PALETTE.read_bytes()
        except OSError:
            self.send_error(404, "palette not generated yet")
            return
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass  # keep the journal quiet; polling is every 30 s


if __name__ == "__main__":
    http.server.ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
