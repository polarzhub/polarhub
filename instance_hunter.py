import os
import sys
import time
import urllib.parse
import asyncio
import threading
import requests
import discord
from discord.ext import commands, tasks
from dotenv import load_dotenv
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

# Forzar codificación UTF-8 en la salida estándar para soportar emojis en consolas Windows
if sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")

# Configuración inicial y carga de variables de entorno
load_dotenv()

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
LOG_CHANNEL_ID = os.getenv("LOG_CHANNEL_ID")
RESULT_CHANNEL_ID = os.getenv("RESULT_CHANNEL_ID")
ROBLOX_COOKIE = os.getenv("ROBLOX_COOKIE", "")

if not DISCORD_TOKEN:
    print("❌ ERROR: Falta el DISCORD_TOKEN en el archivo .env")
    sys.exit(1)

# Diccionario de juegos precargados (ID)
GAMES_OPTIONS = {
    "sea1": "2753915549",
    "sea2": "4442272183",
    "sea3": "7449423635"
}

# Colores Hexadecimales para Embeds de Discord
COLOR_CYAN = 0x00f0ff
COLOR_GREEN = 0x39ff14
COLOR_ORANGE = 0xffaa00
COLOR_RED = 0xff0055
COLOR_INFO = 0xa100ff

# ServerJoinView eliminado porque Discord no soporta URIs personalizadas (roblox-player:) en botones de enlace

class RobloxHunterBot(commands.Bot):
    def __init__(self):
        intents = discord.Intents.default()
        intents.message_content = True
        super().__init__(command_prefix="!", intents=intents)
        
        self.search_running = False
        self.current_hunt_task = None
        self.http_session = requests.Session()
        
        # Cola de eventos para comunicar el hilo síncrono (hunt_worker) con el bucle asíncrono de Discord
        self.event_queue = asyncio.Queue()
        self.last_found_server = None
        
        # Aplicar cookie si existe en el entorno (nunca vía comando)
        if ROBLOX_COOKIE:
            formatted_cookie = ROBLOX_COOKIE if ROBLOX_COOKIE.startswith(".ROBLOSECURITY=") else f".ROBLOSECURITY={ROBLOX_COOKIE}"
            self.http_session.headers.update({"Cookie": formatted_cookie})
            print("🍪 Cookie configurada desde .env")

    async def setup_hook(self):
        # Iniciar la tarea en segundo plano que procesa los eventos
        self.process_events_loop.start()
        # Sincronizar comandos Slash
        await self.tree.sync()
        print("✅ Comandos Slash sincronizados.")

    async def on_ready(self):
        print(f"🤖 Bot conectado como {self.user} (ID: {self.user.id})")
        print("Esperando comandos en Discord...")

    @tasks.loop(seconds=0.5)
    async def process_events_loop(self):
        """Lee eventos de la cola (desde hunt_worker) y los envía a los canales de Discord."""
        if not LOG_CHANNEL_ID or not RESULT_CHANNEL_ID:
            return

        try:
            log_id = int(LOG_CHANNEL_ID)
            result_id = int(RESULT_CHANNEL_ID)
        except ValueError:
            print("❌ ERROR: Los IDs de los canales en .env deben ser numéricos. Deteniendo el procesador de eventos.")
            self.process_events_loop.stop()
            return

        # Intentar obtener de caché local, y si no hacer fetch vía API de Discord
        log_channel = self.get_channel(log_id)
        if not log_channel:
            try:
                log_channel = await self.fetch_channel(log_id)
            except Exception:
                pass

        result_channel = self.get_channel(result_id)
        if not result_channel:
            try:
                result_channel = await self.fetch_channel(result_id)
            except Exception as e:
                print(f"❌ Error al obtener canal de resultados: {e}")

        while not self.event_queue.empty():
            evt_type, data = await self.event_queue.get()
            
            if evt_type == "LOG":
                if log_channel:
                    # Discord tiene un límite de 2000 chars, evitamos fallos truncando si es necesario
                    safe_log = data[:1990]
                    await log_channel.send(f"`{safe_log}`")
                else:
                    print(f"[LOG] {data}")
                    
            elif evt_type == "SERVER":
                if result_channel:
                    await self.send_server_embed(result_channel, data)
            elif evt_type == "DISCORD_MSG":
                if result_channel:
                    msg_text = data.get("message", "")
                    embed_data = data.get("embed")
                    if embed_data:
                        title = embed_data.get("title", "Notificación Polar Hub")
                        color = embed_data.get("color", COLOR_CYAN)
                        desc = embed_data.get("description", "")
                        embed = discord.Embed(title=title, description=desc, color=color)
                        for f in embed_data.get("fields", []):
                            embed.add_field(name=f.get("name", ""), value=f.get("value", ""), inline=f.get("inline", True))
                        footer = embed_data.get("footer", "")
                        if footer:
                            embed.set_footer(text=footer)
                        await result_channel.send(content=msg_text if msg_text else None, embed=embed)
                    elif msg_text:
                        await result_channel.send(msg_text)

    async def send_server_embed(self, channel, server_info):
        """Construye y envía el Embed con los resultados al canal"""
        confidence = server_info.get("confidence_level", "HIGH")
        
        if confidence == "ASSASSIN":
            color = COLOR_CYAN
        elif confidence == "HIGH":
            color = COLOR_GREEN
        elif confidence == "MEDIUM":
            color = COLOR_ORANGE
        else:
            color = COLOR_RED

        job_id = server_info["job_id"]
        place_id = server_info["place_id"]
        ping = server_info.get("ping", "N/A")
        fps = server_info.get("fps", "N/A")
        playing = server_info.get("playing", "N/A")
        max_players = server_info.get("max_players", "N/A")
        matched_user = server_info.get("matched_user", "Jugador")
        
        # Formatear números
        fps_str = f"{fps:.0f}" if isinstance(fps, (int, float)) else str(fps)
        ping_str = f"{ping}ms" if isinstance(ping, (int, float)) else str(ping)

        embed = discord.Embed(
            title="🎯 ¡Servidor Localizado!",
            color=color,
            description=f"**Confianza / Match:**\n{matched_user}"
        )
        embed.add_field(name="👥 Jugadores", value=f"{playing}/{max_players}", inline=True)
        embed.add_field(name="📶 Ping", value=ping_str, inline=True)
        embed.add_field(name="💻 FPS", value=fps_str, inline=True)
        embed.add_field(name="🆔 Job ID", value=f"`{job_id}`", inline=False)
        embed.add_field(
            name="🚀 Cómo unirse:",
            value=f"1. Haz clic en el botón de copiar del bloque de código de abajo.\n2. Presiona `Win + R` en tu teclado (o pégalo en la barra de direcciones de tu navegador).\n3. Pega el comando y presiona `Enter`.\n\n```text\nroblox-player:1+launchmode:join+gameinstanceid:{job_id}+placeid:{place_id}\n```",
            inline=False
        )
        embed.set_footer(text="Roblox Instance Hunter Bot")

        await channel.send(embed=embed)

    # --- MÉTODOS AUXILIARES SÍNCRONOS (Llamados desde hunt_worker) ---
    def write_log_sync(self, message):
        """Encolar un log desde el hilo secundario al loop principal de forma segura"""
        self.loop.call_soon_threadsafe(self.event_queue.put_nowait, ("LOG", message))

    def add_found_server_event_sync(self, server_info):
        """Encolar un servidor desde el hilo secundario al loop principal de forma segura"""
        self.loop.call_soon_threadsafe(self.event_queue.put_nowait, ("SERVER", server_info))

    def clean_thumbnail_url(self, url):
        if not url:
            return ""
        if "?" in url:
            url = url.split("?")[0]
        return url.strip().lower()

    def make_api_request(self, url, method="GET", json_data=None):
        """Método seguro de peticiones HTTP con timeouts y reintentos para 429"""
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
        
        while self.search_running:
            try:
                if method == "POST":
                    response = self.http_session.post(url, json=json_data, headers=headers, timeout=(5, 12))
                else:
                    response = self.http_session.get(url, headers=headers, timeout=(5, 12))

                if response.status_code == 429:
                    self.write_log_sync("⏳ API saturada (Error 429). Esperando 2 segundos para reintentar...")
                    time.sleep(2.0)
                    continue

                return response
            except requests.exceptions.RequestException as e:
                self.write_log_sync(f"⚠️ Error de conexión: {str(type(e).__name__)}. Reintentando en 2 segundos...")
                time.sleep(2.0)
            except Exception as e:
                self.write_log_sync(f"⚠️ Error inesperado en API: {str(type(e).__name__)}")
                time.sleep(2.0)
        return None

    def fetch_servers_by_type(self, place_id, query_type):
        """
        Consulta la API de Roblox para encontrar los mejores servidores públicos.
        query_type puede ser 'low_players' o 'best_ping'.
        """
        server_list = []
        cursor = ""
        attempts = 0
        while attempts < 5:
            url = f"https://games.roblox.com/v1/games/{place_id}/servers/Public?sortOrder=Asc&limit=100"
            if cursor:
                url += f"&cursor={cursor}"
            response = self.make_api_request(url)
            if not response or response.status_code != 200:
                break
            data = response.json().get("data", [])
            if not data:
                break
            for v in data:
                if isinstance(v, dict) and "playing" in v and "maxPlayers" in v:
                    # Evitar servidores vacíos/restringidos (0-1 jugadores) y servidores llenos
                    if v["playing"] >= 2 and v["playing"] <= v["maxPlayers"] - 2:
                        server_list.append({
                            "id": v["id"],
                            "playing": v["playing"],
                            "maxPlayers": v["maxPlayers"],
                            "ping": v.get("ping", 99999)
                        })
            cursor = response.json().get("nextPageCursor")
            if not cursor or len(server_list) >= 50:
                break
            attempts += 1
            time.sleep(0.1)

        if not server_list:
            return None

        if query_type == "low_players":
            server_list.sort(key=lambda x: x["playing"])
        else:
            server_list.sort(key=lambda x: x["ping"])

        import random
        selected = random.choice(server_list[:min(5, len(server_list))])
        return selected

    # --- LA LÓGICA PRINCIPAL DEL ALGORITMO (HILO SECUNDARIO) ---
    def hunt_worker(self, target_username, secondary_nicknames, place_id, search_mode):
        """
        Ejecuta el escaneo de servidores. Debe correr en un hilo usando asyncio.to_thread 
        para no bloquear el event loop.
        """
        try:
            self.write_log_sync("🔑 Validando sesión de Roblox...")
            auth_resp = self.http_session.get("https://users.roblox.com/v1/users/authenticated", timeout=8)
            if auth_resp and auth_resp.status_code == 200:
                auth_data = auth_resp.json()
                self.write_log_sync(f"👤 Sesión iniciada como: {auth_data.get('name')} (ID: {auth_data.get('id')})")
            else:
                self.write_log_sync("⚠️ Sin sesión activa o cookie inválida. Peticiones anónimas.")

            # --- PASO 1: BÚSQUEDA Y RESOLUCIÓN DE CANDIDATOS ---
            self.write_log_sync(f"🔍 Paso 1: Buscando UserIds según el modo de búsqueda [{search_mode}]...")
            
            target_user_id = None
            target_real_name = None
            all_candidate_ids = {} 
            backup_candidates = {} 
            
            names_to_resolve_exactly = []
            if search_mode == "full_usernames":
                names_to_resolve_exactly.append(target_username)
                for nick in secondary_nicknames:
                    names_to_resolve_exactly.append(nick)
            elif search_mode == "mixed":
                names_to_resolve_exactly.append(target_username)
                
            resolved_usernames = {} 
            resolved_real_names = {} 
            
            if names_to_resolve_exactly:
                self.write_log_sync(f"  ⚡ Resolviendo {len(names_to_resolve_exactly)} nombres exactos como Usernames...")
                username_payload = {"usernames": list(set(names_to_resolve_exactly)), "excludeBannedUsers": True}
                response = self.make_api_request("https://users.roblox.com/v1/usernames/users", method="POST", json_data=username_payload)
                if response and response.status_code == 200:
                    for user in response.json().get("data", []):
                        resolved_usernames[user["name"].lower()] = user["id"]
                        resolved_real_names[user["name"].lower()] = user["name"]
            
            if search_mode != "full_display_names":
                if target_username.lower() in resolved_usernames:
                    target_user_id = resolved_usernames[target_username.lower()]
                    target_real_name = resolved_real_names[target_username.lower()]
                    self.write_log_sync(f"🎯 Objetivo Principal (Username) localizado: {target_real_name}")
                else:
                    self.write_log_sync(f"⚠️ Objetivo Principal '{target_username}' no es Username exacto. Buscando como apodo...")
                    resp = self.make_api_request(f"https://users.roblox.com/v1/users/search?keyword={urllib.parse.quote(target_username)}&limit=100")
                    if resp and resp.status_code == 200 and resp.json().get("data"):
                        target_user_id = resp.json()["data"][0]["id"]
                        target_real_name = resp.json()["data"][0]["name"]
                        self.write_log_sync(f"🎯 Objetivo Principal (Fuzzy) localizado: {target_real_name}")
                        for user in resp.json()["data"][1:]:
                            all_candidate_ids[user["id"]] = f"Apodo Principal: {target_username} (coincidencia: {user['name']})"
            else:
                resp = self.make_api_request(f"https://users.roblox.com/v1/users/search?keyword={urllib.parse.quote(target_username)}&limit=100")
                if resp and resp.status_code == 200 and resp.json().get("data"):
                    target_user_id = resp.json()["data"][0]["id"]
                    target_real_name = resp.json()["data"][0]["name"]
                    self.write_log_sync(f"🎯 Objetivo Principal (Fuzzy) localizado: {target_real_name}")
                    for user in resp.json()["data"][1:]:
                        all_candidate_ids[user["id"]] = f"Apodo Principal: {target_username} (coincidencia: {user['name']})"

            for nick in secondary_nicknames:
                if not self.search_running: return
                
                if search_mode == "full_usernames":
                    if nick.lower() in resolved_usernames:
                        uid = resolved_usernames[nick.lower()]
                        if uid != target_user_id:
                            all_candidate_ids[uid] = f"Username: {resolved_real_names[nick.lower()]}"
                            backup_candidates[nick] = (uid, f"Username: {resolved_real_names[nick.lower()]}")
                else:
                    self.write_log_sync(f"  🔍 Buscando apodo fuzzy '{nick}'...")
                    current_cursor = None
                    for page in range(1, 13):
                        if not self.search_running: return
                        url = f"https://users.roblox.com/v1/users/search?keyword={urllib.parse.quote(nick)}&limit=100"
                        if current_cursor: url += f"&cursor={urllib.parse.quote(current_cursor)}"
                        
                        resp = self.make_api_request(url)
                        time.sleep(0.2)
                        if not resp or resp.status_code != 200: break
                        data = resp.json().get("data", [])
                        if not data: break
                        
                        if page == 1 and data[0]["id"] != target_user_id:
                            backup_candidates[nick] = (data[0]["id"], f"Respaldo Apodo: {nick} ({data[0]['name']})")
                        
                        for user in data:
                            if user["id"] != target_user_id:
                                all_candidate_ids[user["id"]] = f"Apodo: {nick} ({user['name']})"
                        
                        current_cursor = resp.json().get("nextPageCursor")
                        if not current_cursor: break
            
            # --- DETECCIÓN AUTOMÁTICA DE AMIGOS (AUTO-COPRESENCIA) ---
            if target_user_id and search_mode != "full_display_names":
                self.write_log_sync(f"👥 Obteniendo amigos de {target_real_name} para escaneo automático...")
                friends_resp = self.make_api_request(f"https://friends.roblox.com/v1/users/{target_user_id}/friends")
                if friends_resp and friends_resp.status_code == 200:
                    friends_data = friends_resp.json().get("data", [])
                    self.write_log_sync(f"  ✓ Detectados {len(friends_data)} amigos en su lista pública.")
                    for friend in friends_data:
                        fid = friend["id"]
                        if fid != target_user_id and fid not in all_candidate_ids:
                            all_candidate_ids[fid] = f"Amigo de {target_real_name}: {friend['name']}"

            # --- PASO 2: FASE ASESINA (PRESENCE API) ---
            self.write_log_sync("💀 ═══ FASE ASESINA: Interrogando Presence API ═══")
            assassin_kills = 0
            
            if target_user_id:
                presence_resp = self.make_api_request("https://presence.roblox.com/v1/presence/users", method="POST", json_data={"userIds": [target_user_id]})
                if presence_resp and presence_resp.status_code == 200:
                    presences = presence_resp.json().get("userPresences", [])
                    if presences:
                        p_info = presences[0]
                        if p_info.get("userPresenceType") == 2 and p_info.get("gameId") and str(p_info.get("placeId")) == str(place_id):
                            self.write_log_sync(f"💀 ¡KILL CONFIRMADO! {target_real_name} localizado DIRECTAMENTE.")
                            self.add_found_server_event_sync({
                                "job_id": p_info.get("gameId"),
                                "place_id": place_id,
                                "matched_user": f"💀 {target_real_name} | FASE ASESINA",
                                "confidence_level": "ASSASSIN"
                            })
                            assassin_kills += 1
                else:
                    status = presence_resp.status_code if presence_resp else "Conexión Fallida"
                    self.write_log_sync(f"⚠️ Error en Presence API (HTTP {status}) para el objetivo principal.")
            
            filtered_users = {}
            if all_candidate_ids:
                candidate_list = list(all_candidate_ids.keys())
                chunks = [candidate_list[i:i + 100] for i in range(0, len(candidate_list), 100)]
                for chunk in chunks:
                    if not self.search_running: return
                    presence_resp = self.make_api_request("https://presence.roblox.com/v1/presence/users", method="POST", json_data={"userIds": chunk})
                    if presence_resp and presence_resp.status_code == 200:
                        for p in presence_resp.json().get("userPresences", []):
                            if p.get("userPresenceType") == 2 and (not p.get("placeId") or str(p.get("placeId")) == str(place_id)):
                                uid = p.get("userId")
                                filtered_users[uid] = all_candidate_ids[uid]
                                if p.get("gameId"):
                                    self.write_log_sync(f"💀 ¡KILL CONFIRMADO! Candidato {uid} localizado DIRECTAMENTE.")
                                    self.add_found_server_event_sync({
                                        "job_id": p.get("gameId"),
                                        "place_id": place_id,
                                        "matched_user": f"💀 {all_candidate_ids[uid]} | FASE ASESINA",
                                        "confidence_level": "ASSASSIN"
                                    })
                                    assassin_kills += 1
                    else:
                        status = presence_resp.status_code if presence_resp else "Conexión Fallida"
                        self.write_log_sync(f"⚠️ Error en Presence API (HTTP {status}) para lote de candidatos.")

            if assassin_kills > 0:
                self.write_log_sync(f"💀 ═══ FASE ASESINA COMPLETADA: {assassin_kills} kills ═══")
                if not secondary_nicknames:
                    self.write_log_sync(">>> CACERÍA COMPLETA (Fase Asesina).")
                    self.search_running = False
                    return          self.write_log_sync(">>> CACERÍA COMPLETA (Fase Asesina).")
                    self.search_running = False
                    return
            
            # --- PREPARACIÓN AVATARES ---
            scan_users = {}
            if target_user_id: scan_users[target_user_id] = f"🎯 {target_real_name}"
            for uid, info in filtered_users.items(): scan_users[uid] = info
            
            for nick in secondary_nicknames:
                has_active = any(nick.lower() in info.lower() for info in filtered_users.values())
                if not has_active and nick in backup_candidates:
                    uid_backup, info_backup = backup_candidates[nick]
                    if uid_backup not in scan_users:
                        scan_users[uid_backup] = info_backup

            if not scan_users:
                self.write_log_sync("❌ No hay candidatos válidos para escaneo.")
                self.search_running = False
                return

            is_squad_mode = len(scan_users) >= 2
            self.write_log_sync(f"{'👥 ESCUADRÓN' if is_squad_mode else '⚠️ RIESGO'} Activado ({len(scan_users)} objs).")
            
            avatar_url_to_user = {}
            uids_str = ",".join(map(str, scan_users.keys()))
            for resolution in ["150x150", "48x48"]:
                resp = self.make_api_request(f"https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds={uids_str}&size={resolution}&format=Png&isCircular=false")
                if resp and resp.status_code == 200:
                    for item in resp.json().get("data", []):
                        if item.get("state") == "Completed":
                            clean = self.clean_thumbnail_url(item.get("imageUrl"))
                            if item.get("targetId") in scan_users:
                                avatar_url_to_user[clean] = scan_users[item.get("targetId")]
                time.sleep(0.2)

            # --- ESCÁNER ---
            self.write_log_sync("🔍 Iniciando escaneo de servidores públicos...")
            server_scan_count = 0
            
            # Estrategia de Triple Fase:
            # Fase A (Llenos): Escanea servidores con más jugadores (Desc), permitiendo salas 12/12.
            # Fase B (Medios): Escanea servidores de forma Descendente, pero excluyendo salas 12/12 (excludeFullGames=true) para ver el rango medio (11/12, 10/12, etc.) donde es posible unirse.
            # Fase C (Vacíos): Escanea servidores de forma Ascendente (de menos a más jugadores) para detectar si el objetivo está en salas semivacías.
            phases = [
                {"name": "Fase A (Llenos)", "sortOrder": "Desc", "excludeFull": False},
                {"name": "Fase B (Medios)", "sortOrder": "Desc", "excludeFull": True},
                {"name": "Fase C (Vacíos)", "sortOrder": "Asc", "excludeFull": False},
                {"name": "Fase D (Vacíos sin llenos)", "sortOrder": "Asc", "excludeFull": True}
            ]
            
            for phase in phases:
                if not self.search_running: break
                self.write_log_sync(f"⚡ {phase['name']}...")
                phase_scan_count = 0
                cursor = ""
                page = 1
                
                while self.search_running:
                    self.write_log_sync(f"📦 {phase['name']} - Escaneando Página {page}...")
                    
                    exclude_full_str = "true" if phase["excludeFull"] else "false"
                    url = f"https://games.roblox.com/v1/games/{place_id}/servers/Public?limit=100&sortOrder={phase['sortOrder']}&excludeFullGames={exclude_full_str}"
                    if cursor: url += f"&cursor={cursor}"
                    resp = self.make_api_request(url)
                    if not resp:
                        self.write_log_sync("⚠️ Búsqueda detenida o error de conexión al consultar servidores.")
                        break
                    if resp.status_code != 200:
                        self.write_log_sync(f"❌ Error HTTP {resp.status_code} al consultar lista de servidores. Deteniendo fase.")
                        break
                    
                    servers = resp.json().get("data", [])
                    if not servers:
                        self.write_log_sync(f"ℹ️ No quedan más servidores públicos activos en {phase['name']}.")
                        break
                    
                    server_scan_count += len(servers)
                    phase_scan_count += len(servers)
                    
                    tokens_to_servers = {}
                    for srv in servers:
                        for token in srv.get("playerTokens", []):
                            tokens_to_servers[token] = {
                                "job_id": srv.get("id"),
                                "place_id": place_id,
                                "ping": srv.get("ping"),
                                "fps": srv.get("fps"),
                                "playing": srv.get("playing", 0),
                                "max_players": srv.get("maxPlayers", 0)
                            }
                            
                    if servers and not tokens_to_servers:
                        self.write_log_sync("❌ Roblox bloquea jugadores. Requiere Cookie válida en .env.")
                        self.search_running = False
                        break
                        
                    if tokens_to_servers:
                        server_matches = {}
                        all_tokens = list(tokens_to_servers.keys())
                        for i in range(0, len(all_tokens), 100):
                            if not self.search_running: break
                            chunk = all_tokens[i:i+100]
                            payload = [{"requestId": t, "token": t, "type": "AvatarHeadShot", "size": "150x150", "format": "Png", "isCircular": False} for t in chunk]
                            b_resp = self.make_api_request("https://thumbnails.roblox.com/v1/batch", method="POST", json_data=payload)
                            time.sleep(0.2)
                            
                            if b_resp and b_resp.status_code == 200:
                                for item in b_resp.json().get("data", []):
                                    if item.get("state") == "Completed":
                                        url_cln = self.clean_thumbnail_url(item.get("imageUrl"))
                                        if url_cln in avatar_url_to_user:
                                            srv_inf = tokens_to_servers.get(item.get("requestId"))
                                            if srv_inf:
                                                jid = srv_inf["job_id"]
                                                if jid not in server_matches: server_matches[jid] = set()
                                                server_matches[jid].add(avatar_url_to_user[url_cln])
                                                
                        for srv in servers:
                            if not self.search_running: break
                            jid = srv.get("id")
                            n_playing = srv.get("playing", 0)
                            v_tokens = len(srv.get("playerTokens", []))
                            t_targets = len(set(avatar_url_to_user.values()))
                            matches = server_matches.get(jid, set())
                            
                            if v_tokens > (n_playing - t_targets) and not matches: continue
                            if not matches: continue
                            
                            legit = False
                            conf_tag = ""
                            conf_lvl = "HIGH"
                            
                            if search_mode == "full_usernames":
                                legit = True
                                if len(matches) >= 2:
                                    conf_tag, conf_lvl = "👥 GRUPO CONFIRMADO (100%)", "HIGH"
                                else:
                                    conf_tag, conf_lvl = f"🎯 {list(matches)[0]} (100%)", "HIGH"
                            elif is_squad_mode:
                                if len(matches) >= 2:
                                    legit, conf_tag, conf_lvl = True, "👥 GRUPO CONFIRMADO (100%)", "HIGH"
                                elif len(matches) == 1:
                                    is_prim = list(matches)[0].startswith("🎯")
                                    if is_prim and n_playing >= 8:
                                        legit, conf_tag, conf_lvl = True, "🎯 PRINCIPAL (100%)", "HIGH"
                                    elif n_playing < 5:
                                        legit, conf_tag, conf_lvl = True, "⚠️ Semivacía (75%)", "MEDIUM"
                            else:
                                legit = True
                                if n_playing < 5:
                                    conf_tag, conf_lvl = "⚠️ Semivacía (75%)", "MEDIUM"
                                else:
                                    conf_tag, conf_lvl = "🔴 POSIBLE BOT (50%)", "LOW"
                                    
                            if legit:
                                sorted_m = sorted(list(matches))
                                srv_info = {
                                    "job_id": jid,
                                    "place_id": place_id,
                                    "ping": srv.get("ping"),
                                    "fps": srv.get("fps"),
                                    "playing": n_playing,
                                    "max_players": srv.get("maxPlayers"),
                                    "matched_user": f"{' + '.join(sorted_m)} | {conf_tag}",
                                    "confidence_level": conf_lvl
                                }
                                self.add_found_server_event_sync(srv_info)
                            else:
                                # Loguear coincidencias descartadas por co-presencia en canal de logs
                                sorted_m = sorted(list(matches))
                                self.write_log_sync(f"🔍 Filtrado: Hallado '{'+'.join(sorted_m)}' en server {jid[:8]}... ({n_playing} jugs) sin co-presencia.")
                                
                    cursor = resp.json().get("nextPageCursor")
                    if not cursor or server_scan_count >= 3000 or phase_scan_count >= 1500:
                        self.write_log_sync(f"ℹ️ Fin de {phase['name']}. Se examinaron {phase_scan_count} servidores.")
                        break
                    page += 1
                    time.sleep(0.5)
                    
            self.write_log_sync(">>> CACERÍA COMPLETA.")
            self.search_running = False

        except Exception as e:
            self.write_log_sync(f"💥 Error crítico: {str(e)}")
            self.search_running = False


# Instanciación del bot
bot = RobloxHunterBot()

@bot.tree.command(name="cazar", description="Inicia una cacería de servidores")
@discord.app_commands.describe(
    username="Usuario principal a buscar",
    apodos="Lista de apodos o clones separados por coma (ej: nick1, nick2)",
    juego="Selecciona el Place (Sea 1, Sea 2, Sea 3 o Custom)",
    custom_place="Place ID si elegiste Custom",
    modo="Modo de búsqueda"
)
@discord.app_commands.choices(juego=[
    discord.app_commands.Choice(name="Blox Fruits - Sea 1", value="sea1"),
    discord.app_commands.Choice(name="Blox Fruits - Sea 2", value="sea2"),
    discord.app_commands.Choice(name="Blox Fruits - Sea 3", value="sea3"),
    discord.app_commands.Choice(name="Custom Place ID", value="custom")
], modo=[
    discord.app_commands.Choice(name="Modo Mixto (Username + Apodos)", value="mixed"),
    discord.app_commands.Choice(name="Solo Nombres Reales (Full Usernames)", value="full_usernames"),
    discord.app_commands.Choice(name="Solo Apodos (Full Display Names)", value="full_display_names")
])
async def cazar(interaction: discord.Interaction, username: str, apodos: str = "", juego: str = "sea2", custom_place: str = "", modo: str = "mixed"):
    if bot.search_running:
        await interaction.response.send_message("❌ Ya hay una búsqueda en progreso. Usa `/stop` primero.", ephemeral=True)
        return

    place_id = custom_place if juego == "custom" else GAMES_OPTIONS.get(juego)
    if not place_id or not place_id.isdigit():
        await interaction.response.send_message("❌ Place ID inválido.", ephemeral=True)
        return

    nicknames_list = [n.strip() for n in apodos.split(",") if n.strip()]

    bot.search_running = True
    await interaction.response.send_message(f"🚀 Iniciando cacería para **{username}** en el place **{place_id}**...", ephemeral=False)
    
    # Lanzar la tarea pesada de red y escaneo en un hilo sin bloquear Discord
    bot.current_hunt_task = asyncio.create_task(
        asyncio.to_thread(bot.hunt_worker, username, nicknames_list, place_id, modo)
    )

@bot.tree.command(name="stop", description="Detiene la búsqueda actual")
async def stop_search(interaction: discord.Interaction):
    if not bot.search_running:
        await interaction.response.send_message("ℹ️ No hay ninguna búsqueda en ejecución.", ephemeral=True)
        return

    bot.search_running = False
    await interaction.response.send_message("🛑 Deteniendo la cacería de forma segura (espera unos segundos).", ephemeral=False)

@bot.tree.command(name="status", description="Muestra el estado de la búsqueda")
async def status_search(interaction: discord.Interaction):
    estado = "🟢 Activa y escaneando" if bot.search_running else "🔴 Inactiva"
    await interaction.response.send_message(f"**Estado del Radar:** {estado}", ephemeral=True)


class LocalBridgeHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return

    def do_GET(self):
        if self.path.startswith("/get_server"):
            parsed_url = urllib.parse.urlparse(self.path)
            params = urllib.parse.parse_qs(parsed_url.query)
            q_type = params.get("type", ["low_players"])[0]
            place_id = params.get("place_id", ["2753915549"])[0]
            
            if q_type == "cazar":
                if hasattr(bot, "last_found_server") and bot.last_found_server:
                    response_data = {
                        "success": True,
                        "jobId": bot.last_found_server.get("job_id"),
                        "placeId": bot.last_found_server.get("place_id")
                    }
                    bot.last_found_server = None
                else:
                    response_data = {"success": False, "message": "No target server found"}
            else:
                server = bot.fetch_servers_by_type(place_id, q_type)
                if server:
                    response_data = {
                        "success": True,
                        "jobId": server["id"],
                        "placeId": place_id
                    }
                else:
                    response_data = {"success": False, "message": "No servers found"}
            
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))
            
        elif self.path == "/eval":
            command_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "command.lua")
            code = ""
            if os.path.exists(command_file):
                try:
                    with open(command_file, "r", encoding="utf-8") as f:
                        code = f.read().strip()
                    if code:
                        with open(command_file, "w", encoding="utf-8") as f:
                            f.write("")
                except Exception:
                    pass
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            if code:
                self.wfile.write(code.encode("utf-8"))
            else:
                self.wfile.write(b"NO_COMMAND")
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        content_length = int(self.headers["Content-Length"])
        post_data = self.rfile.read(content_length).decode("utf-8")
        
        if self.path == "/log_discord":
            try:
                data = json.loads(post_data)
                message = data.get("message", "")
                embed_data = data.get("embed")
                
                bot.loop.call_soon_threadsafe(
                    bot.event_queue.put_nowait, 
                    ("DISCORD_MSG", {"message": message, "embed": embed_data})
                )
                
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"Logged to Discord")
            except Exception as e:
                self.send_response(400)
                self.end_headers()
        elif self.path == "/log":
            try:
                log_data = json.loads(post_data)
                msg = log_data.get("message", "")
                msg_type = log_data.get("type", "")
                if "error" in msg_type.lower() or "exception" in msg_type.lower():
                    print(f"🔴 [ROBLOX ERROR] {msg}")
                elif "warn" in msg_type.lower():
                    print(f"🟡 [ROBLOX WARN]  {msg}")
                else:
                    print(f"🟢 [ROBLOX LOG]   {msg}")
                self.send_response(200)
                self.end_headers()
            except Exception:
                self.send_response(400)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()


def start_http_server():
    try:
        server_address = ("127.0.0.1", 3000)
        httpd = HTTPServer(server_address, LocalBridgeHandler)
        print("======================================================================")
        print("  🔥 Servidor local Polar Bridge corriendo en http://127.0.0.1:3000")
        print("======================================================================")
        httpd.serve_forever()
    except Exception as e:
        print(f"❌ Error al iniciar el servidor local: {e}")


if __name__ == "__main__":
    try:
        threading.Thread(target=start_http_server, daemon=True).start()
        bot.run(DISCORD_TOKEN)
    except KeyboardInterrupt:
        print("Cerrando el bot...")
    except discord.errors.LoginFailure:
        print("❌ Error: DISCORD_TOKEN inválido.")
    except Exception as e:
        print(f"❌ Error fatal: {e}")
