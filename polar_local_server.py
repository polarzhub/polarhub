# polar_local_server.py
# Servidor local para recibir y transmitir datos masivos de mapas de Roblox.
# Ejecución: python polar_local_server.py

import http.server
import json
import os

PORT = 3000
OUTPUT_DIR = "output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

file_handle = None
map_name = "map"

class MapServerHandler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Deshabilitar logs de consola excesivos para evitar ralentización en pantalla
        return

    def do_POST(self):
        global file_handle, map_name
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        
        if self.path == "/start":
            try:
                metadata = json.loads(post_data)
                map_name = metadata.get("mapName", "export_map")
                print(f"[START] Iniciando exportación de mapa: {map_name} ({metadata.get('totalInstances', 0)} instancias)")
                
                file_path = os.path.join(OUTPUT_DIR, f"{map_name}.jsonl")
                if file_handle:
                    file_handle.close()
                
                # Búfer de 1MB para escrituras directas veloces
                file_handle = open(file_path, "w", encoding="utf-8", buffering=1024*1024)
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(b"Session started")
            except Exception as e:
                print(f"Error en inicio de sesión: {e}")
                self.send_response(400)
                self.end_headers()
                
        elif self.path == "/chunk":
            if file_handle:
                file_handle.write(post_data + "\n")
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(b"Chunk written")
            else:
                self.send_response(400)
                self.end_headers()
                
        elif self.path == "/end":
            if file_handle:
                file_handle.close()
                file_handle = None
                print(f"[SUCCESS] Mapa '{map_name}' guardado exitosamente en: output/{map_name}.jsonl")
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(b"Session ended")
            else:
                self.send_response(400)
                self.end_headers()
        elif self.path == "/log":
            try:
                log_data = json.loads(post_data)
                msg = log_data.get("message", "")
                msg_type = log_data.get("type", "")
                # Colorear según el tipo de log
                if "error" in msg_type.lower() or "exception" in msg_type.lower():
                    print(f"🔴 [ROBLOX ERROR] {msg}")
                elif "warn" in msg_type.lower():
                    print(f"🟡 [ROBLOX WARN]  {msg}")
                else:
                    print(f"🟢 [ROBLOX LOG]   {msg}")
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(b"Log registered")
            except Exception as e:
                self.send_response(400)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        # Permite a Roblox Studio leer el archivo .jsonl directamente de la computadora
        if self.path.startswith("/get/"):
            file_name = self.path[5:]
            file_path = os.path.join(OUTPUT_DIR, file_name)
            if os.path.exists(file_path):
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_response(404)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

def run():
    server_address = ('127.0.0.1', PORT)
    httpd = http.server.HTTPServer(server_address, MapServerHandler)
    print("======================================================================")
    print(f"  🔥 Servidor local Polar Cloner V2.2 PRO corriendo en http://127.0.0.1:{PORT}")
    print("  📂 Los archivos se guardarán en la carpeta 'output/'")
    print("======================================================================")
    print("Ejecuta el script en Roblox o Roblox Studio para iniciar...")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServidor detenido.")
        global file_handle
        if file_handle:
            file_handle.close()

if __name__ == "__main__":
    run()
