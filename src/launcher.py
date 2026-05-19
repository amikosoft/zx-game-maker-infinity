# -*- coding: utf-8 -*-
import os
import platform
import subprocess
import sys
import threading
import webbrowser
import time
import tkinter as tk
from tkinter import messagebox
import customtkinter as ctk
from PIL import Image, ImageTk
import pyfiglet
import json
from ZXFontRenderer import ZXFontRenderer

version = "6.0.0"

# Configuración de CustomTkinter
# Configuración inicial (se sobreescribirá con los ajustes guardados)
ctk.set_default_color_theme("blue")

from builder.PlayerFxBuilder import PlayerFxBuilder
from builder.SpritesPreviewGenerator import SpritesPreviewGenerator
from builder.helper import DIST_FOLDER, MAPS_PROJECT, getProjectFileName
from builder.LanguageManager import LanguageManager
from builder.KeysConfigManager import KeysConfigManager
from translations import TRANSLATIONS

class ZXInfinityApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        # Establecer el directorio de trabajo al directorio del script
        os.chdir(os.path.dirname(os.path.abspath(__file__)))

        # Cargar Ajustes
        self.settings_file = os.path.join(os.getcwd(), "config.json")
        self.app_settings = self.load_settings()
        self.current_lang = self.app_settings.get("language", "Spanish")
        ctk.set_appearance_mode(self.app_settings.get("theme", "light"))

        self.title(f"ZXGM - Infinity v{version}")
        self.geometry("1100x750")
        self.configure(fg_color=("#f0f0f0", "#050505")) # Fondo de ventana adaptable

        # Configurar el grid (2 columnas, 2 filas: una para menú, otra para contenido)
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(1, weight=1)

        # Diccionarios para traducción dinámica
        self.section_buttons = {}
        self.item_buttons = {}
        self.menu_buttons = []
        
        # Secuencia Konami (Easter Egg)
        self.konami_code = ["Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "b", "a", "Return"]
        self.current_sequence = []
        self.bind("<Key>", self.check_konami_code)

        # --- Sidebar Estructurada (Logo fijo, Menú scrollable, Salida fija) ---
        self.sidebar_frame = ctk.CTkFrame(self, width=220, corner_radius=0, 
                                          fg_color=("#666666", "#050505"))
        self.sidebar_frame.grid(row=0, column=0, rowspan=2, sticky="nsew", padx=0, pady=0)
        self.sidebar_frame.grid_rowconfigure(1, weight=1) 
        self.sidebar_frame.grid_columnconfigure(0, weight=1)

        # 1. LOGO FIJO (Arriba)
        icon_path = os.path.join(os.getcwd(), "ui/infinity_logo.png")
        if os.path.exists(icon_path):
            img = Image.open(icon_path)
            w, h = img.size
            aspect_ratio = w / h
            target_width = 150
            target_height = int(target_width / aspect_ratio)
            self.logo_image = ctk.CTkImage(light_image=img, dark_image=img, size=(target_width, target_height))
            self.logo_label = ctk.CTkLabel(self.sidebar_frame, image=self.logo_image, text="")
        else:
            self.logo_label = ctk.CTkLabel(self.sidebar_frame, text="ZX INFINITY", 
                                            font=ctk.CTkFont(size=18, weight="bold"),
                                            text_color="#00ffff")
        self.logo_label.grid(row=0, column=0, padx=10, pady=(20, 20))

        # 2. MENÚ SCROLLABLE (Centro)
        self.menu_scroll = ctk.CTkScrollableFrame(self.sidebar_frame, corner_radius=0, 
                                                  fg_color="transparent", 
                                                  scrollbar_button_color="#004444",
                                                  scrollbar_button_hover_color="#006666")
        self.menu_scroll.grid(row=1, column=0, sticky="nsew", padx=0, pady=0)
        self.menu_scroll.grid_columnconfigure(0, weight=1)

        self.sidebar_row = 0
        def get_next_row():
            r = self.sidebar_row
            self.sidebar_row += 1
            return r

        def add_collapsible_section(text, expanded=True):
            btn = ctk.CTkButton(self.menu_scroll, text=f"{text} ▼" if expanded else f"{text} ▶", 
                                font=ctk.CTkFont(size=12, weight="bold"),
                                fg_color=("#4a4a4a", "#151515"), 
                                text_color="#00ffff",
                                hover_color=("#3a3a3a", "#222222"), 
                                anchor="w", height=32,
                                corner_radius=8)
            btn.grid(row=get_next_row(), column=0, sticky="ew", padx=8, pady=(12, 0))
            
            content_frame = ctk.CTkFrame(self.menu_scroll, fg_color="transparent")
            content_frame.grid(row=get_next_row(), column=0, sticky="ew")
            content_frame.grid_columnconfigure(0, weight=1)
            
            if not expanded:
                content_frame.grid_remove()
                
            btn.configure(command=lambda: self.toggle_section(btn, content_frame, text))
            self.section_buttons[text] = (btn, text)
            return content_frame

        def add_item(parent, text, command):
            btn = ctk.CTkButton(parent, text=text, 
                                font=ctk.CTkFont(size=11),
                                fg_color=("#555555", "#0a0a0a"), 
                                text_color=("#ffffff", "#aaaaaa"),
                                hover_color=("#444444", "#1a1a1a"), 
                                anchor="w", height=28,
                                corner_radius=6,
                                command=command)
            btn.grid(row=parent.grid_size()[1], column=0, sticky="ew", padx=(8, 8), pady=2)
            self.item_buttons[text] = (btn, text)
            return btn

        # --- Secciones ---
        self.sidebar_buttons = []
        
        sec_run = add_collapsible_section("RUN")
        self.sidebar_buttons.append(add_item(sec_run, "Play Normal", lambda: self.open_game_variant("normal")))
        self.sidebar_buttons.append(add_item(sec_run, "Play RF", lambda: self.open_game_variant("rf")))
        if platform.system() in ["Linux", "Darwin"]:
            self.sidebar_buttons.append(add_item(sec_run, "Play Experimental", lambda: self.open_game_variant("experimental")))

        sec_build = add_collapsible_section("BUILD")
        self.sidebar_buttons.append(add_item(sec_build, "Build Game", lambda: self.run_script("make-game")))
        self.sidebar_buttons.append(add_item(sec_build, "Build Verbose", lambda: self.run_script("make-game", ["--verbose"])))
        self.sidebar_buttons.append(add_item(sec_build, "Build Graphics", lambda: self.run_script("make-graphics")))
        self.sidebar_buttons.append(add_item(sec_build, "Build FX", self.fxBuild))
        self.sidebar_buttons.append(add_item(sec_build, "Reload/View Fonts", self.find_fonts))

        sec_map = add_collapsible_section("Game configuration")
        add_item(sec_map, "Map (Tiled)", self.open_map_with_tiled)
        add_item(sec_map, "Edit Game Texts", self.open_text_editor)
        add_item(sec_map, "Console mode options", self.open_keys_editor)

        # sec_sprites = add_collapsible_section("SPRITES", expanded=False)
        # add_item(sec_sprites, "Main (Running)", self.open_main_character_running_preview)
        # add_item(sec_sprites, "Main (Idle)", self.open_main_character_idle_preview)
        # add_item(sec_sprites, "Platforms", self.open_first_platform_preview)
        # # Listado plano de enemigos
        # for i in range(1, 9):
        #     add_item(sec_sprites, f"Enemy {i}", lambda i=i: self.open_enemy_preview(i))

        sec_memory = add_collapsible_section("MEMORY", expanded=False)
        add_item(sec_memory, "Bank 0 (Generic)", lambda: self.open_memory_bank_image("memory-bank-0-128K.png"))
        add_item(sec_memory, "Bank 3 (Texts)", lambda: self.open_memory_bank_image("memory-bank-3.png"))
        add_item(sec_memory, "Bank 4 (Musics)", lambda: self.open_memory_bank_image("memory-bank-4.png"))
        add_item(sec_memory, "Bank 6 (FX/Maps)", lambda: self.open_memory_bank_image("memory-bank-6.png"))
        add_item(sec_memory, "Bank 7 (SCR)", lambda: self.open_memory_bank_image("memory-bank-7.png"))

        # 3. CONTROLES FIJOS (Abajo)

        # 3. CONTROLES FIJOS (Abajo)
        self.controls_frame = ctk.CTkFrame(self.sidebar_frame, fg_color="transparent")
        self.controls_frame.grid(row=2, column=0, padx=10, pady=20, sticky="ew")

        self.theme_button = ctk.CTkButton(self.controls_frame, text="", 
                                          command=self.change_appearance_mode,
                                          height=35)
        self.theme_button.pack(padx=10, pady=(0, 15), fill="x")
        self.update_theme_button_ui()

        self.btn_exit = ctk.CTkButton(self.controls_frame, text="Exit Application", 
                                      fg_color="transparent", text_color="#ff5555",
                                      hover_color=("#ffdddd", "#330000"), height=30,
                                      command=self.quit)
        self.btn_exit.pack(padx=10, pady=0, fill="x")

        # --- Habilitar Scroll con Rueda ---
        self._setup_scroll_event(self.menu_scroll, self.menu_scroll)

        # Frame Principal - Sin borde para un look más despejado
        self.main_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.main_frame.grid(row=1, column=1, sticky="nsew", padx=10, pady=10)
        self.main_frame.grid_rowconfigure(1, weight=1)
        self.main_frame.grid_columnconfigure(0, weight=1)



        self.spectrum_colors = ["#0000D7", "#D70000", "#D700D7", "#00D700", "#00D7D7", "#D7D700"]
        self.color_index = 0

        # Contenedor de contenido dinámico (Log o Editores)
        self.content_container = ctk.CTkFrame(self.main_frame, fg_color="transparent")
        self.content_container.grid(row=1, column=0, sticky="nsew", padx=0, pady=(15,0))
        self.content_container.grid_rowconfigure(0, weight=1)
        self.content_container.grid_columnconfigure(0, weight=1)

        # Frame de Log (Barra de progreso + Consola)
        self.log_frame = ctk.CTkFrame(self.content_container, fg_color="transparent")
        self.log_frame.grid(row=0, column=0, sticky="nsew")
        self.log_frame.grid_rowconfigure(1, weight=1)
        self.log_frame.grid_columnconfigure(0, weight=1)

        # Cabecera del log (Status + Progreso)
        self.log_header = ctk.CTkFrame(self.log_frame, fg_color="transparent")
        self.log_header.grid(row=0, column=0, sticky="ew", pady=(0, 10))
        self.log_header.grid_columnconfigure(1, weight=1)

        self.status_label = ctk.CTkLabel(self.log_header, text="Welcome to ZXGM Infinity", 
                                         font=ctk.CTkFont(size=14))
        self.status_label.grid(row=0, column=0, padx=(0, 20), sticky="w")

        self.progress_bar = ctk.CTkProgressBar(self.log_header, progress_color="#00ffff", height=8)
        self.progress_bar.grid(row=0, column=1, sticky="ew")
        self.progress_bar.set(0)
        self.progress_bar.grid_remove()

        # Consola de Log con scrollbar integrado
        self.output_text = ctk.CTkTextbox(self.log_frame, wrap="word", 
                                           font=ctk.CTkFont(family="Consolas", size=12),
                                           border_width=1, 
                                           border_color=("#00aa00", "#006600"), 
                                           fg_color=("#cccccc", "#151515"),
                                           text_color=("#111111", "#eeeeee"))
        self.output_text.grid(row=1, column=0, sticky="nsew")
        # Empieza en solo lectura; se desbloquea durante ejecución de scripts
        self.output_text.configure(state="disabled")

        self.active_editor_frame = None


        # Menús flotantes (Context menus alternativos)
        self.current_menu = None

        # Inicialización final
        self.create_custom_menu_bar()
        self.update_ui_texts()
        self.show_help_info()
        self.after(500, self._update_scrollbar_visibility)

    def create_custom_menu_bar(self):
        """Crea una barra de menú superior personalizada con alineación a la derecha."""
        self.custom_menu_bar = ctk.CTkFrame(self, height=30, corner_radius=0,
                                            fg_color=("#dbdbdb", "#1a1a1a"))
        self.custom_menu_bar.grid(row=0, column=1, sticky="ew")
        
        # Selector de Idioma (Alineado a la izquierda del menú bar)
        self.lang_selector = ctk.CTkSegmentedButton(self.custom_menu_bar, values=["Spanish", "English"],
                                                   command=self.change_language,
                                                   selected_color="#008888",
                                                   selected_hover_color="#00aaaa",
                                                   height=26)
        self.lang_selector.set(self.current_lang)
        self.lang_selector.pack(side="left", padx=10)

        # Acciones de Soporte (Alineadas a la derecha)
        self.support_actions_refs = []
        support_actions = [
            ("donate", lambda: webbrowser.open("https://www.paypal.com/donate/?hosted_button_id=TF4WN7542U5KE")),
            ("website", lambda: webbrowser.open("https://zxinfinitydocs.great-site.net/")),
            ("github", lambda: webbrowser.open("https://github.com/amikosoft/zx-game-maker-infinity")),
            ("telegram", lambda: webbrowser.open("https://t.me/+R5PUBeHV0WhlMjQ0")),
            ("discord", lambda: webbrowser.open("https://discord.com/channels/942735294359277578/1390332022630907945")),
            ("docs", lambda: webbrowser.open(os.path.join(os.path.dirname(__file__), "../site", "index.html"))),
            ("quick_info", self.show_help_info)
        ]
        
        for key, command in support_actions:
            text = TRANSLATIONS[self.current_lang].get(key, key)
            color = ("#ff5555", "#ff5555") if key == "donate" else ("#111111", "#00ffff")
            btn = ctk.CTkButton(self.custom_menu_bar, text=text, width=80, height=30,
                                font=ctk.CTkFont(size=11, weight="bold" if key == "donate" else "normal"),
                                fg_color="transparent", text_color=color,
                                hover_color=("#ffcccc", "#331111") if key == "donate" else ("#bbbbbb", "#333333"),
                                corner_radius=0,
                                command=command)
            btn.pack(side="right", padx=0)
            self.menu_buttons.append((btn, key))

    def load_settings(self):
        if os.path.exists(self.settings_file):
            try:
                with open(self.settings_file, "r") as f:
                    return json.load(f)
            except:
                return {"theme": "light"}
        return {"theme": "light"}

    def save_settings(self):
        try:
            with open(self.settings_file, "w") as f:
                json.dump(self.app_settings, f)
        except Exception as e:
            print(f"Error al guardar ajustes: {e}")

    def update_theme_button_ui(self):
        """Actualiza el texto y apariencia del botón de tema."""
        theme = self.app_settings.get("theme", "light")
        lang = self.current_lang
        texts = TRANSLATIONS[lang]
        
        if theme == "dark":
            text = "🌙 " + texts.get("dark_mode", "DARK MODE")
            self.theme_button.configure(text=text, fg_color="#2b2b2b", hover_color="#3b3b3b", text_color="#00ffff")
        else:
            text = "☀️ " + texts.get("light_mode", "LIGHT MODE")
            self.theme_button.configure(text=text, fg_color="#dbdbdb", hover_color="#cbcbcb", text_color="#111111")

    def change_appearance_mode(self):
        current_theme = self.app_settings.get("theme", "light")
        new_theme = "light" if current_theme == "dark" else "dark"
        self.app_settings["theme"] = new_theme
        ctk.set_appearance_mode(new_theme)
        self.update_theme_button_ui()
        self.save_settings()

    def change_language(self, new_lang):
        self.current_lang = new_lang
        self.app_settings["language"] = new_lang
        self.update_ui_texts()
        self.save_settings()

    def update_ui_texts(self):
        """Actualiza todos los textos de la interfaz al idioma actual."""
        lang = self.current_lang
        texts = TRANSLATIONS[lang]
        
        # 1. Títulos de secciones del sidebar
        mapping = {
            "RUN": "run",
            "BUILD": "build",
            "Game configuration": "game_config",
            "MEMORY": "memory"
        }
        for orig_text, (btn, key_part) in self.section_buttons.items():
            trans_key = mapping.get(key_part, key_part)
            new_text = texts.get(trans_key, key_part)
            # Mantener la flecha
            current_btn_text = btn.cget("text")
            arrow = " ▼" if "▼" in current_btn_text else " ▶"
            btn.configure(text=f"{new_text}{arrow}")

        # 2. Botones de items del sidebar
        item_mapping = {
            "Play Normal": "play_normal",
            "Play RF": "play_rf",
            "Play Experimental": "play_experimental",
            "Build Game": "build_game",
            "Build Verbose": "build_verbose",
            "Build Graphics": "build_graphics",
            "Build FX": "build_fx",
            "Reload/View Fonts": "reload_fonts",
            "Map (Tiled)": "map_tiled",
            "Edit Game Texts": "edit_texts",
            "Console mode options": "console_mode",
            "Bank 0 (Generic)": "bank_0",
            "Bank 3 (Texts)": "bank_3",
            "Bank 4 (Musics)": "bank_4",
            "Bank 6 (FX/Maps)": "bank_6",
            "Bank 7 (SCR)": "bank_7"
        }
        for orig_text, (btn, key_part) in self.item_buttons.items():
            trans_key = item_mapping.get(key_part, key_part)
            new_text = texts.get(trans_key, key_part)
            btn.configure(text=new_text)

        # 3. Botones del menú superior
        for btn, key in self.menu_buttons:
            btn.configure(text=texts.get(key, key))

        # 4. Status y Welcome
        self.status_label.configure(text=texts.get("welcome", "Welcome"))
        
        # 5. Botón Salir
        self.btn_exit.configure(text=texts.get("exit", "EXIT"))
        
        # 6. Actualizar tema botón (que tiene texto hardcoded)
        self.update_theme_button_ui()

    def check_konami_code(self, event):
        key = event.keysym
        # Normalizar b, a y Return
        if key.lower() in ['b', 'a']:
            key = key.lower()
        if key == "KP_Enter":
            key = "Return"
            
        self.current_sequence.append(key)
        
        # Mantener solo los últimos N elementos
        if len(self.current_sequence) > len(self.konami_code):
            self.current_sequence.pop(0)
            
        if self.current_sequence == self.konami_code:
            self.play_easter_egg_sound()
            self.current_sequence = [] # Reset

    def play_easter_egg_sound(self):
        sound_path = os.path.join(os.getcwd(), "builder/sonido.ogg")
        image_path = os.path.join(os.getcwd(), "builder/8999825375b0e6d5.gif")
        
        # Mostrar en el log
        self.show_log()
        self.log_clear()
        self.printBanner()
        
        # Escribir el texto especial en el log con color especial
        special_text = "El espíritu sagrado de Sluosnarf\nacaba de extender su dominio sobre ZX Infinity,\nproclamando el inicio de una nueva era\n\n"
        self.log_write_color(special_text, "#FFD700")
        
        # Mostrar imagen a pantalla completa
        if os.path.exists(image_path):
            self.show_fullscreen_image(image_path)
        
        if not os.path.exists(sound_path):
            return
            
        def _play():
            try:
                try:
                    # Intentar usar ffpyplayer si está instalado (evita requerir reproductores externos)
                    from ffpyplayer.player import MediaPlayer
                    import time
                    
                    player = MediaPlayer(sound_path)
                    # Dar un breve instante para cargar metadatos e iniciar reproducción
                    time.sleep(0.2)
                    metadata = player.get_metadata()
                    duration = metadata.get('duration', 0) if metadata else 0
                    
                    if duration > 0:
                        while player.get_pts() < duration:
                            time.sleep(0.1)
                    else:
                        time.sleep(3.0)  # Fallback de seguridad si no lee la duración
                    
                    player.close_player()
                except ImportError:
                    # Fallback a comandos de sistema si ffpyplayer no está disponible
                    if platform.system() == "Windows":
                        subprocess.run(["ffplay", "-nodisp", "-autoexit", sound_path], 
                                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    else:
                        # Linux: paplay es común para OGG
                        subprocess.run(["paplay", sound_path], 
                                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            except:
                pass
                
        threading.Thread(target=_play, daemon=True).start()

    def show_fullscreen_image(self, image_path):
        """Muestra una imagen a pantalla completa (fullscreen overlay). Soporta GIFs animados."""
        # Cerrar modal anterior si existe
        if hasattr(self, "fullscreen_modal_frame") and self.fullscreen_modal_frame.winfo_exists():
            self.fullscreen_modal_frame.destroy()
        
        # Cancelar animación anterior si existe
        if hasattr(self, "fullscreen_animation_id") and self.fullscreen_animation_id:
            self.after_cancel(self.fullscreen_animation_id)
            self.fullscreen_animation_id = None

        # Crear frame que ocupe toda la ventana
        fullscreen_frame = ctk.CTkFrame(self, fg_color="#000000")
        self.fullscreen_modal_frame = fullscreen_frame
        fullscreen_frame.place(relx=0, rely=0, relwidth=1, relheight=1)
        fullscreen_frame.lift()

        # Cargar imagen
        img = Image.open(image_path)
        
        # Obtener dimensiones de la ventana
        self.update_idletasks()
        window_w = self.winfo_width()
        window_h = self.winfo_height()
        
        # Redimensionar imagen para ocupar toda la ventana manteniendo proporción
        img_w, img_h = img.size
        ratio = min(window_w / img_w, window_h / img_h)
        new_w = int(img_w * ratio)
        new_h = int(img_h * ratio)

        # Crear label centrado con la imagen
        img_label = ctk.CTkLabel(fullscreen_frame, image=None, text="")
        img_label.place(relx=0.5, rely=0.5, anchor="center")

        # Cerrar al hacer clic o presionar Escape
        def close_fullscreen():
            if hasattr(self, "fullscreen_animation_id") and self.fullscreen_animation_id:
                self.after_cancel(self.fullscreen_animation_id)
                self.fullscreen_animation_id = None
            if fullscreen_frame.winfo_exists():
                fullscreen_frame.destroy()

        img_label.bind("<Button-1>", lambda e: close_fullscreen())
        fullscreen_frame.bind("<Escape>", lambda e: close_fullscreen())
        
        # Verificar si es un GIF animado
        try:
            is_gif = hasattr(img, 'n_frames') and img.n_frames > 1
        except:
            is_gif = False
        
        if is_gif:
            # Animar el GIF
            self.fullscreen_frames = []
            self.fullscreen_durations = []
            
            try:
                for frame_idx in range(img.n_frames):
                    img.seek(frame_idx)
                    frame = img.copy().convert("RGBA")
                    
                    # Redimensionar frame
                    frame.thumbnail((new_w, new_h), Image.Resampling.LANCZOS)
                    
                    ctk_frame = ctk.CTkImage(light_image=frame, dark_image=frame, size=(new_w, new_h))
                    self.fullscreen_frames.append(ctk_frame)
                    
                    # Obtener duración del frame (en milisegundos)
                    duration = img.info.get('duration', 100)
                    self.fullscreen_durations.append(max(duration, 50))
                
                self.fullscreen_frame_index = 0
                
                def animate_gif():
                    if fullscreen_frame.winfo_exists():
                        current_frame = self.fullscreen_frames[self.fullscreen_frame_index]
                        img_label.configure(image=current_frame)
                        
                        self.fullscreen_frame_index = (self.fullscreen_frame_index + 1) % len(self.fullscreen_frames)
                        duration = self.fullscreen_durations[self.fullscreen_frame_index - 1]
                        
                        self.fullscreen_animation_id = self.after(duration, animate_gif)
                    else:
                        self.fullscreen_animation_id = None
                
                animate_gif()
                
            except Exception as e:
                print(f"Error animando GIF: {e}")
                # Fallback a imagen estática
                self.fullscreen_img = ctk.CTkImage(light_image=img, dark_image=img, size=(new_w, new_h))
                img_label.configure(image=self.fullscreen_img)
        else:
            # Imagen estática
            self.fullscreen_img = ctk.CTkImage(light_image=img, dark_image=img, size=(new_w, new_h))
            img_label.configure(image=self.fullscreen_img)
        
        # Auto-cerrar después de 15 segundos (más tiempo para GIFs)
        self.after(15000, close_fullscreen)

    def _setup_scroll_event(self, widget, scroll_frame):
        """Bind mouse wheel events to a widget and all its children recursively to a specific scroll frame."""
        def handle_mouse_wheel(event):
            try:
                start, end = scroll_frame._parent_canvas.yview()
                if start == 0.0 and end == 1.0:
                    return

                if platform.system() == "Linux":
                    if event.num == 4:
                        scroll_frame._parent_canvas.yview_scroll(-1, "units")
                    elif event.num == 5:
                        scroll_frame._parent_canvas.yview_scroll(1, "units")
                else:
                    scroll_frame._parent_canvas.yview_scroll(int(-1*(event.delta/120)), "units")
            except:
                pass

        try:
            if platform.system() == "Linux":
                widget.bind("<Button-4>", handle_mouse_wheel, add="+")
                widget.bind("<Button-5>", handle_mouse_wheel, add="+")
            else:
                widget.bind("<MouseWheel>", handle_mouse_wheel, add="+")
        except:
            # Algunos widgets como CTkSegmentedButton no soportan bind directo
            pass
        
        for child in widget.winfo_children():
            self._setup_scroll_event(child, scroll_frame)

    def toggle_section(self, button, frame, name):
        if frame.winfo_viewable():
            frame.grid_remove()
            button.configure(text=f"{name} ▶")
        else:
            frame.grid(padx=0, pady=0, sticky="ew")
            button.configure(text=f"{name} ▼")
        
        # Actualizar visibilidad del scrollbar después de cambiar secciones
        self.after(100, self._update_scrollbar_visibility)

    def _update_scrollbar_visibility(self):
        """Oculta el scrollbar si no es necesario."""
        try:
            self.update_idletasks()
            start, end = self.menu_scroll._parent_canvas.yview()
            if start == 0.0 and end == 1.0:
                self.menu_scroll._scrollbar.grid_remove()
            else:
                self.menu_scroll._scrollbar.grid()
        except:
            pass

    def log_write(self, text):
        """Escribe texto en la consola de log (read-only para el usuario)."""
        self.show_log() # Asegurar que el log sea visible
        self.output_text.configure(state="normal")
        self.output_text.insert(tk.END, text)
        self.output_text.see(tk.END)
        self.output_text.configure(state="disabled")

    def show_log(self):
        """Muestra el frame de log y oculta cualquier editor activo."""
        if self.active_editor_frame:
            self.active_editor_frame.destroy()
            self.active_editor_frame = None
        self.log_frame.grid()

    def clear_content_area(self):
        """Limpia el área de contenido para mostrar un nuevo editor."""
        if self.active_editor_frame:
            self.active_editor_frame.destroy()
        self.log_frame.grid_remove()
        self.active_editor_frame = ctk.CTkFrame(self.content_container, fg_color="transparent")
        self.active_editor_frame.grid(row=0, column=0, sticky="nsew")
        self.active_editor_frame.grid_rowconfigure(0, weight=1)
        self.active_editor_frame.grid_columnconfigure(0, weight=1)
        return self.active_editor_frame

    def log_write_color(self, text, color):
        """Escribe texto en la consola de log con un color específico."""
        self.show_log()
        self.output_text.configure(state="normal")
        tag_name = f"color_{color.replace('#', '')}"
        self.output_text.tag_config(tag_name, foreground=color)
        self.output_text.insert(tk.END, text, tag_name)
        self.output_text.see(tk.END)
        self.output_text.configure(state="disabled")

    def log_clear(self):
        """Limpia la consola de log."""
        self.show_log()
        self.output_text.configure(state="normal")
        self.output_text.delete("1.0", tk.END)
        self.output_text.configure(state="disabled")

    def printBanner(self):
        self.log_write(f"\n")
    
        try:
            texto = pyfiglet.figlet_format("ZX Infinity", font='ansi_shadow')

            # Paleta BRIGHT del ZX Spectrum (Hex)
            ZX_COLORS = [
                "#0000FF",  # BLUE BRIGHT
                "#FF0000",  # RED BRIGHT
                "#FF00FF",  # MAGENTA BRIGHT
                "#00FF00",  # GREEN BRIGHT
                "#00FFFF",  # CYAN BRIGHT
                "#FFFF00",  # YELLOW BRIGHT
                "#FFFFFF",  # WHITE BRIGHT
            ]

            # Aplicar color por línea
            for i, linea in enumerate(texto.split("\n")):
                color = ZX_COLORS[i % len(ZX_COLORS)]
                self.log_write_color(linea + "\n", color)
        except:
            self.log_write(f"····::::: ZX INFINITY :::::····\n")
        
        self.log_write(f"-= by Amikosoft =- Ver. {version}\n\n")

    def show_help_info(self):
        self.log_clear()
        self.printBanner()
        
        lang_suffix = "_es" if self.current_lang == "Spanish" else "_en"
        info_path = os.path.join(os.getcwd(), f"ui/quick_info{lang_suffix}.txt")
        
        # Fallback to default if localized doesn't exist
        if not os.path.exists(info_path):
            info_path = os.path.join(os.getcwd(), "ui/quick_info.txt")

        if os.path.exists(info_path):
            try:
                with open(info_path, "r", encoding="utf-8") as f:
                    self.log_write(f.read())
            except Exception as e:
                self.log_write(f"Error reading quick info: {e}\n")
        else:
            texts = TRANSLATIONS[self.current_lang]
            self.log_write(f"{texts.get('quick_info', 'Quick Info')}\n\n")
            self.log_write(f"- {texts.get('run', 'Run')}: {texts.get('play_normal', 'Play')}\n")
            self.log_write(f"- {texts.get('build', 'Build')}: {texts.get('build_game', 'Build')}\n")
            self.log_write(f"- {texts.get('game_config', 'Config')}\n")
            self.log_write(f"- {texts.get('memory', 'Memory')}\n")
        
    def run_script(self, script_name, extra_args=None):
        def execute():
            try:
                self.show_log()
                for btn in self.sidebar_buttons:
                    btn.configure(state="disabled")
                self.btn_exit.configure(state="disabled")
                self.status_label.configure(text=f'Running {script_name}...', text_color="#f55")
                
                self.progress_bar.grid()  # Mostrar la barra de progreso
                self.progress_bar.set(0)

                self.log_clear()
                self.printBanner()
                # Desbloquear el textbox durante la ejecución
                self.output_text.configure(state="normal")

                if platform.system() == "Windows":
                    script_file = script_name + ".ps1"
                else:
                    script_file = script_name + ".sh"

                script_path = os.path.join(os.getcwd(), "scripts", script_file)

                if not os.path.exists(script_path):
                    self.log_write(f"No se encontró el script: {script_path}\n")
                    return

                command = [script_path]
                if extra_args:
                    command.extend(extra_args)

                if platform.system() == "Windows":
                    process = subprocess.Popen(
                        ["powershell", "-ExecutionPolicy", "Bypass", "-File"] + command,
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE
                    )
                else:
                    process = subprocess.Popen(
                        ["bash"] + command,
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE
                    )

                for line_bytes in iter(process.stdout.readline, b''):
                    try:
                        line = line_bytes.decode('utf-8')
                    except UnicodeDecodeError:
                        line = line_bytes.decode('cp1252', errors='replace')
                    self.output_text.insert(tk.END, line)
                    self.output_text.see(tk.END)
                    # Incrementar progreso ligeramente
                    new_val = min(0.95, self.progress_bar.get() + 0.005)
                    self.progress_bar.set(new_val)
                    # Ciclo de colores Spectrum
                    self.color_index = (self.color_index + 1) % len(self.spectrum_colors)
                    self.progress_bar.configure(progress_color=self.spectrum_colors[self.color_index])

                for line_bytes in iter(process.stderr.readline, b''):
                    try:
                        line = line_bytes.decode('utf-8')
                    except UnicodeDecodeError:
                        line = line_bytes.decode('cp1252', errors='replace')
                    self.output_text.insert(tk.END, line)
                    self.output_text.see(tk.END)
                    # Incrementar progreso ligeramente
                    new_val = min(0.95, self.progress_bar.get() + 0.005)
                    self.progress_bar.set(new_val)
                    # Ciclo de colores Spectrum
                    self.color_index = (self.color_index + 1) % len(self.spectrum_colors)
                    self.progress_bar.configure(progress_color=self.spectrum_colors[self.color_index])

                process.wait()
                self.status_label.configure(text=f'Last executed: {script_name}', text_color=("gray10", "#DCE4EE"))
            except Exception as e:
                self.log_write(f"Error al ejecutar {script_name}:\n{e}\n")
                self.status_label.configure(text=f"Error: {script_name}", text_color="red")
            finally:    
                for btn in self.sidebar_buttons:
                    btn.configure(state="normal")
                self.btn_exit.configure(state="normal")
                self.progress_bar.set(1)
                # Bloquear el textbox al terminar
                self.output_text.configure(state="disabled")
                
        threading.Thread(target=execute).start()

    def open_game_variant(self, variant):
        try:
            project_name = getProjectFileName()
            if variant == "rf":
                project_name += "-RF"
            elif variant == "experimental":
                project_name += "_infinity"

            self.status_label.configure(text=f'Running {project_name}...')
            
            if platform.system() == "Windows":
                game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.exe")
            else:
                game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.linux")

            if not os.path.exists(game_path):
                messagebox.showerror("Error", f"No se encontró el archivo del juego: {game_path}")
                return

            subprocess.Popen([game_path], shell=True)
            self.status_label.configure(text=f'Executed {project_name}')
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo abrir el juego: {e}")

    def show_project_menu(self):
        menu = tk.Menu(self, tearoff=0, bg="#0a0a0a", fg="#00ffff", 
                       activebackground="#008888", activeforeground="white",
                       font=("Segoe UI", 10), bd=1, relief="solid")
        
        # Submenú Play
        play_menu = tk.Menu(menu, tearoff=0, bg="#0a0a0a", fg="#00ffff", 
                            activebackground="#008888", activeforeground="white", bd=1)
        play_menu.add_command(label="Play", command=lambda: self.open_game_variant("normal"))
        play_menu.add_command(label="Play RF", command=lambda: self.open_game_variant("rf"))
        if platform.system() in ["Linux", "Darwin"]:
            play_menu.add_command(label="Play Experimental", command=lambda: self.open_game_variant("experimental"))
        menu.add_cascade(label="Run...", menu=play_menu)

        # Submenú Build
        build_menu = tk.Menu(menu, tearoff=0, bg="#0a0a0a", fg="#00ffff", 
                             activebackground="#008888", activeforeground="white", bd=1)
        build_menu.add_command(label="Build", command=lambda: self.run_script("make-game"))
        build_menu.add_command(label="Build (verbose)", command=lambda: self.run_script("make-game", ["--verbose"]))
        build_menu.add_separator()
        build_menu.add_command(label="Build Tiles+Sprites", command=lambda: self.run_script("make-graphics"))
        build_menu.add_command(label="Build FX", command=self.fxBuild)
        menu.add_cascade(label="Build...", menu=build_menu)

        menu.add_separator()
        menu.add_command(label="Open Map (Tiled)", command=self.open_map_with_tiled)
        
        self.post_menu(menu, self.btn_project)

    def show_utilities_menu(self):
        menu = tk.Menu(self, tearoff=0, bg="#0a0a0a", fg="#00ffff", 
                       activebackground="#008888", activeforeground="white",
                       font=("Segoe UI", 10), bd=1, relief="solid")
        
        # Submenú Sprites
        sprites_menu = tk.Menu(menu, tearoff=0, bg="#0a0a0a", fg="#00ffff", 
                               activebackground="#008888", activeforeground="white", bd=1)
        
        main_menu = tk.Menu(sprites_menu, tearoff=0, bg="#0a0a0a", fg="#00ffff", activebackground="#008888")
        main_menu.add_command(label="Running", command=self.open_main_character_running_preview)
        main_menu.add_command(label="Idle", command=self.open_main_character_idle_preview)
        sprites_menu.add_cascade(label="Main Character", menu=main_menu)

        plat_menu = tk.Menu(sprites_menu, tearoff=0, bg="#0a0a0a", fg="#00ffff", activebackground="#008888")
        plat_menu.add_command(label="Platform 1", command=self.open_first_platform_preview)
        plat_menu.add_command(label="Platform 2", command=self.open_second_platform_preview)
        sprites_menu.add_cascade(label="Platforms", menu=plat_menu)

        enemy_menu = tk.Menu(sprites_menu, tearoff=0, bg="#0a0a0a", fg="#00ffff", activebackground="#008888")
        for i in range(1, 9):
            enemy_menu.add_command(label=f"Enemy {i}", command=lambda i=i: self.open_enemy_preview(i))
        sprites_menu.add_cascade(label="Enemies", menu=enemy_menu)
        
        menu.add_cascade(label="Sprites Preview", menu=sprites_menu)

        # Submenú Memory
        memory_menu = tk.Menu(menu, tearoff=0, bg="#0a0a0a", fg="#00ffff", 
                              activebackground="#008888", activeforeground="white", bd=1)
        memory_menu.add_command(label="Bank 0 (Generic)", command=lambda: self.open_memory_bank_image("memory-bank-0-128K.png"))
        memory_menu.add_command(label="Bank 3 (Texts)", command=lambda: self.open_memory_bank_image("memory-bank-3.png"))
        memory_menu.add_command(label="Bank 4 (Musics)", command=lambda: self.open_memory_bank_image("memory-bank-4.png"))
        memory_menu.add_command(label="Bank 6 (Fx + Maps)", command=lambda: self.open_memory_bank_image("memory-bank-6.png"))
        memory_menu.add_command(label="Bank 7 (SCR)", command=lambda: self.open_memory_bank_image("memory-bank-7.png"))
        
        menu.add_cascade(label="Memory Usage", menu=memory_menu)

        self.post_menu(menu, self.btn_utilities)

    def show_support_menu(self):
        menu = tk.Menu(self, tearoff=0, bg="#0a0a0a", fg="#00ffff", 
                       activebackground="#008888", activeforeground="white",
                       font=("Segoe UI", 10), bd=1, relief="solid")
        menu.add_command(label="Quick Info", command=self.show_help_info)
        menu.add_separator()
        infinity_docs_path = os.path.join(os.path.dirname(__file__), "../site", "index.html")
        menu.add_command(label="Infinity Docs", command=lambda: webbrowser.open(infinity_docs_path))
        # menu.add_command(label="ZXGM Documentation", command=lambda: webbrowser.open("https://gm.retrojuegos.org/"))
        menu.add_separator()
        menu.add_command(label="Discord", command=lambda: webbrowser.open("https://discord.com/channels/942735294359277578/1390332022630907945"))
        menu.add_command(label="Telegram", command=lambda: webbrowser.open("https://t.me/+R5PUBeHV0WhlMjQ0"))
        menu.add_command(label="GitHub", command=lambda: webbrowser.open("https://github.com/amikosoft/zx-game-maker-infinity"))
        menu.add_command(label="itch.io", command=lambda: webbrowser.open("https://amikoes.itch.io/"))
        menu.add_command(label="Web Site", command=lambda: webbrowser.open("https://zxinfinitydocs.great-site.net/"))
        
        self.post_menu(menu, self.btn_support)

    def post_menu(self, menu, widget):
        # Añadir un pequeño offset de 10px desde el botón
        x = widget.winfo_rootx() + widget.winfo_width() + 10
        y = widget.winfo_rooty()
        menu.tk_popup(x, y)

    # Sprites Preview wrappers
    def open_main_character_running_preview(self):
        result = SpritesPreviewGenerator.generateMainPreview()
        if result: self.show_modal_with_animation(result)

    def open_main_character_idle_preview(self):
        result = SpritesPreviewGenerator.generateIdlePreview()
        if result: self.show_modal_with_animation(result)

    def open_first_platform_preview(self):
        result = SpritesPreviewGenerator.generateFirstPreview()
        if result: self.show_modal_with_animation(result)

    def open_second_platform_preview(self):
        result = SpritesPreviewGenerator.generateSecondPreview()
        if result: self.show_modal_with_animation(result)

    def open_enemy_preview(self, i):
        result = SpritesPreviewGenerator.generateEnemy(i)
        if result: self.show_modal_with_animation(result)

    def show_modal_with_animation(self, gif_path):
        try:
            webbrowser.open(f"file://{os.path.abspath(gif_path)}")
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo abrir el GIF: {e}")

    def open_memory_bank_image(self, image):
        try:
            image_path = os.path.join(os.getcwd(), "output", image)
            if not os.path.exists(image_path):
                messagebox.showerror("Error", f"No se encontró la imagen: {image_path}")
                return
            self.show_image_modal(image_path)
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo abrir la imagen: {e}")

    def show_image_modal(self, image_path, secondary=False):
        # Si ya hay un modal abierto, lo cerramos
        modal_attr = "secondary_modal_frame" if secondary else "modal_frame"
        
        if hasattr(self, modal_attr) and getattr(self, modal_attr).winfo_exists():
            getattr(self, modal_attr).destroy()

        # Crear el frame del modal (overlay)
        modal_frame = ctk.CTkFrame(self, fg_color=("#ffffff", "#101010"), corner_radius=15, 
                                        border_width=2, border_color="#00ffff")
        setattr(self, modal_attr, modal_frame)

        # Centrar el modal en la ventana
        width_ratio = 0.8 if secondary else 0.85
        height_ratio = 0.8 if secondary else 0.85
        modal_frame.place(relx=0.5, rely=0.5, relwidth=width_ratio, relheight=height_ratio, anchor="center")
        
        # Título del modal
        title = ctk.CTkLabel(modal_frame, text=os.path.basename(image_path), 
                               font=ctk.CTkFont(size=14, weight="bold"), text_color="#00ffff")
        title.pack(pady=(10, 5))

        # Cargar y redimensionar imagen
        img = Image.open(image_path)
        img_w, img_h = img.size
        
        # Calcular espacio disponible (aprox)
        self.update_idletasks()
        avail_w = modal_frame.winfo_width() - 40
        avail_h = modal_frame.winfo_height() - 100
        
        if avail_w <= 0 or avail_h <= 0: # Fallback if not yet rendered
            avail_w, avail_h = 800, 500

        ratio = min(avail_w / img_w, avail_h / img_h)
        new_w = int(img_w * ratio)
        new_h = int(img_h * ratio)

        self.modal_img = ctk.CTkImage(light_image=img, dark_image=img, size=(new_w, new_h))
        
        img_label = ctk.CTkLabel(modal_frame, image=self.modal_img, text="")
        img_label.pack(expand=True, fill="both", padx=10, pady=10)

        # Botón de cierre
        close_btn = ctk.CTkButton(modal_frame, text="CLOSE PREVIEW", 
                                  fg_color="transparent", border_width=1, border_color="#00ffff",
                                  hover_color="#004444", command=modal_frame.destroy)
        close_btn.pack(pady=(0, 20))

        # También cerrar al hacer clic en la imagen
        img_label.bind("<Button-1>", lambda e: modal_frame.destroy())

    def open_map_with_tiled(self):
        if not MAPS_PROJECT or not os.path.exists(MAPS_PROJECT):
            messagebox.showerror("Error", "Archivo de mapa no encontrado.")
            return
        command = f"tiled {MAPS_PROJECT}" if os.name != "nt" else f"\"{os.environ['ProgramFiles']}\\Tiled\\tiled.exe\" {MAPS_PROJECT}"
        subprocess.Popen(command, shell=True)

    def fxBuild(self):
        self.show_log()
        self.log_clear()
        self.printBanner()
        self.log_write("Building FX...\n")
        start_time = time.time()
        
        success = PlayerFxBuilder.build()
        duration = time.time() - start_time
        
        if success:
            self.log_write("\nÉxito: FX construidos correctamente.\n")
            self.log_write("\nTotal execution time: " + f"{duration:.2f}s")
            self.status_label.configure(text=f"Last executed: Build FX ({duration:.2f}s)", text_color=("gray10", "#DCE4EE"))
        else:
            self.log_write("\nError: Fallo al construir los FX.\n")
            self.log_write("\nTotal execution time: " + f"{duration:.2f}s")
            self.status_label.configure(text="Error: Build FX", text_color="red")

    def find_fonts(self):
        self.log_clear()
        self.printBanner()
        self.log_write("Searching for fonts in src/bin/fnts...\n")
        
        try:
            fonts_dir = os.path.join(os.getcwd(), "bin/fnts")
            if not os.path.exists(fonts_dir):
                self.log_write(f"Error: Directory {fonts_dir} not found.\n")
                return

            # Get font names without extension
            fonts = ["default"]
            for f in sorted(os.listdir(fonts_dir)):
                if f.endswith(".fnt"):
                    fonts.append(os.path.splitext(f)[0])
            
            self.log_write(f"Found {len(fonts)-1} fonts.\n")
            
            # Update maps.tiled-project
            if os.path.exists(MAPS_PROJECT):
                with open(MAPS_PROJECT, "r") as f:
                    project_data = json.load(f)
                
                updated = False
                if "propertyTypes" in project_data:
                    for ptype in project_data["propertyTypes"]:
                        if ptype.get("name") == "fontCustomTypes":
                            ptype["values"] = fonts
                            updated = True
                            break
                
                if updated:
                    with open(MAPS_PROJECT, "w") as f:
                        json.dump(project_data, f, indent=4)
                    self.log_write(f"Successfully updated {MAPS_PROJECT}\n")
                    self.status_label.configure(text="Fonts updated successfully", text_color=("gray10", "#DCE4EE"))
                    # Abrir listado de fuentes
                    self.after(500, lambda: self.open_fonts_list(fonts))
                else:
                    self.log_write("Error: 'fontCustomTypes' property type not found in project file.\n")
            else:
                self.log_write(f"Error: {MAPS_PROJECT} not found.\n")
                
        except Exception as e:
            self.log_write(f"Error: {str(e)}\n")
            self.status_label.configure(text="Error updating fonts", text_color="red")

    def open_fonts_list(self, fonts):
        """Abre el listado de fuentes encontradas en el área principal con previsualización a la derecha."""
        editor_root = self.clear_content_area()
        
        # Cabecera
        header = ctk.CTkFrame(editor_root, fg_color="transparent")
        header.pack(fill="x", padx=30, pady=(20, 10))
        
        title = ctk.CTkLabel(header, text="AVAILABLE FONTS PREVIEW", 
                              font=ctk.CTkFont(size=20, weight="bold"), text_color="#00ffff")
        title.pack(side="left")

        # Separador visual
        sep = ctk.CTkFrame(editor_root, height=2, fg_color="#222222")
        sep.pack(fill="x", padx=30, pady=5)

        # Contenedor para el contenido (2 columnas)
        content = ctk.CTkFrame(editor_root, fg_color="transparent")
        content.pack(expand=True, fill="both")
        content.grid_columnconfigure(0, weight=1)
        content.grid_columnconfigure(1, weight=2)
        content.grid_rowconfigure(0, weight=1)

        # Columna Izquierda: Listado
        left_panel = ctk.CTkFrame(content, fg_color="transparent")
        left_panel.grid(row=0, column=0, sticky="nsew", padx=(30, 10), pady=10)
        left_panel.grid_rowconfigure(0, weight=1)
        left_panel.grid_columnconfigure(0, weight=1)

        fonts_scroll = ctk.CTkScrollableFrame(left_panel, fg_color="transparent")
        fonts_scroll.grid(row=0, column=0, sticky="nsew")
        
        self.font_buttons = {}
        for font in fonts:
            btn = ctk.CTkButton(fonts_scroll, text=font, 
                                anchor="w",
                                fg_color="transparent",
                                text_color=("#111111", "#eeeeee"),
                                hover_color=("#eeeeee", "#222222"),
                                command=lambda f=font: self.preview_font(f))
            btn.pack(fill="x", padx=5, pady=2)
            self.font_buttons[font] = btn

        # Columna Derecha: Previsualización
        self.preview_panel = ctk.CTkFrame(content, fg_color=("#dbdbdb", "#151515"), corner_radius=10)
        self.preview_panel.grid(row=0, column=1, sticky="nsew", padx=(10, 30), pady=10)
        
        self.preview_title = ctk.CTkLabel(self.preview_panel, text="SELECT A FONT", 
                                          font=ctk.CTkFont(size=14, weight="bold"), text_color=("#111111", "#00ffff"))
        self.preview_title.pack(pady=(15, 5))

        self.preview_label = ctk.CTkLabel(self.preview_panel, text="Select a font to preview", 
                                          text_color=("#555555", "#888888"))
        self.preview_label.pack(expand=True, fill="both", padx=10, pady=10)

        # Pie de página
        footer = ctk.CTkFrame(editor_root, fg_color="transparent")
        footer.pack(fill="x", padx=30, pady=(10, 20))
        
        close_btn = ctk.CTkButton(footer, text="CLOSE", fg_color="transparent", 
                                  border_width=1, border_color="#ff5555",
                                  text_color="#ff5555", hover_color="#330000", 
                                  command=self.show_log)
        close_btn.pack(side="right")

        self._setup_scroll_event(editor_root, fonts_scroll)

    def preview_font(self, font_name):
        """Genera una previsualización de la fuente y la muestra en el panel derecho."""
        # Actualizar título
        self.preview_title.configure(text=font_name.upper())
        
        # Resaltar la fuente seleccionada
        for name, btn in self.font_buttons.items():
            if name == font_name:
                btn.configure(fg_color=("#dddddd", "#004444"), text_color=("#000000", "#00ffff"))
            else:
                btn.configure(fg_color="transparent", text_color=("#111111", "#eeeeee"))

        if font_name == "default":
            self.preview_label.configure(image="", text="Default font (ROM)\nNo preview available")
            return

        font_path = os.path.join(os.getcwd(), "bin/fnts", f"{font_name}.fnt")
        if not os.path.exists(font_path):
            return

        try:
            output_path = os.path.join(os.getcwd(), "output", f"preview_{font_name}.png")
            renderer = ZXFontRenderer()
            renderer.load(font_path)
            renderer.save(output_path, margin=1)
            
            # Cargar imagen para el panel
            img = Image.open(output_path)
            
            # Ajustar tamaño al panel
            self.update_idletasks()
            pw = self.preview_panel.winfo_width() - 40
            ph = self.preview_panel.winfo_height() - 40
            if pw < 100: pw = 300
            if ph < 100: ph = 300
            
            ratio = min(pw / img.size[0], ph / img.size[1])
            new_size = (int(img.size[0] * ratio), int(img.size[1] * ratio))
            
            ctk_img = ctk.CTkImage(light_image=img, dark_image=img, size=new_size)
            self.preview_label.configure(image=ctk_img, text="")
            self.preview_label._image = ctk_img # Keep reference
            
        except Exception as e:
            self.preview_label.configure(image="", text=f"Error rendering font:\n{e}")

    def open_text_editor(self):
        """Abre el editor de textos de juego en el área principal."""
        editor_root = self.clear_content_area()
        
        # Cabecera
        header = ctk.CTkFrame(editor_root, fg_color="transparent")
        header.pack(fill="x", padx=30, pady=(20, 10))
        
        title = ctk.CTkLabel(header, text="GAME TEXTS EDITOR", 
                              font=ctk.CTkFont(size=20, weight="bold"), text_color="#00ffff")
        title.pack(side="left")

        # Selector de Idioma
        self.lang_var = tk.StringVar(value="Spanish")
        lang_selector = ctk.CTkSegmentedButton(header, values=["Spanish", "English"],
                                               command=self.load_lang_texts,
                                               variable=self.lang_var,
                                               selected_color="#008888",
                                               selected_hover_color="#00aaaa")
        lang_selector.pack(side="right", padx=20)

        # Separador visual
        sep = ctk.CTkFrame(editor_root, height=2, fg_color="#222222")
        sep.pack(fill="x", padx=30, pady=5)

        # Área scrollable para las entradas
        self.editor_scroll = ctk.CTkScrollableFrame(editor_root, fg_color="transparent",
                                                  scrollbar_button_color="#004444",
                                                  scrollbar_button_hover_color="#006666")
        self.editor_scroll.pack(expand=True, fill="both", padx=30, pady=10)
        
        # Pie de página (Botones)
        footer = ctk.CTkFrame(editor_root, fg_color="transparent")
        footer.pack(fill="x", padx=30, pady=(10, 20))
        
        save_btn = ctk.CTkButton(footer, text="SAVE CHANGES", font=ctk.CTkFont(weight="bold"),
                                 fg_color="#008888", hover_color="#00aaaa", width=150, height=35,
                                 command=self.save_lang_texts)
        save_btn.pack(side="right", padx=10)
        
        close_btn = ctk.CTkButton(footer, text="CLOSE", fg_color="transparent", border_width=1, border_color="#ff5555",
                                  text_color="#ff5555", hover_color="#330000", width=120, height=35,
                                  command=self.show_log)
        close_btn.pack(side="right", padx=10)

        self.load_lang_texts("Spanish")
        
        # Habilitar scroll en todo el editor apuntando al frame scrollable
        self._setup_scroll_event(editor_root, self.editor_scroll)

    def load_lang_texts(self, lang):
        """Carga los textos del idioma seleccionado en el editor."""
        # Limpiar entradas anteriores
        for child in self.editor_scroll.winfo_children():
            child.destroy()
            
        file_name = "texts_es.bas" if lang == "Spanish" else "texts_en.bas"
        file_path = os.path.join(os.getcwd(), "boriel/langs", file_name)
        
        if not os.path.exists(file_path):
            error_label = ctk.CTkLabel(self.editor_scroll, text=f"File not found: {file_name}", text_color="red")
            error_label.pack(pady=20)
            return

        self.current_lang_manager = LanguageManager(file_path)
        entries = self.current_lang_manager.get_entries()
        
        self.entry_widgets = {} # key -> CTkEntry
        
        for entry in entries:
            row = ctk.CTkFrame(self.editor_scroll, fg_color="transparent")
            row.pack(fill="x", pady=4)
            
            # Label para la clave (Key) - No editable
            key_label = ctk.CTkLabel(row, text=entry['key'], width=220, anchor="w",
                                     font=ctk.CTkFont(family="Consolas", size=12, weight="bold"),
                                     text_color=("#333333", "#aaaaaa"))
            key_label.pack(side="left", padx=(5, 15))
            
            # Entry para el valor (Value) - Editable
            val_entry = ctk.CTkEntry(row, height=28, border_width=1, 
                                     border_color=("#cccccc", "#333333"), 
                                     fg_color=("#f0f0f0", "#1a1a1a"),
                                     text_color=("#111111", "#00ffff"))
            val_entry.insert(0, entry['value'])
            val_entry.pack(side="left", expand=True, fill="x", padx=5)
            
            # Label para la longitud
            len_label = ctk.CTkLabel(row, text=str(len(entry['value'])), width=40,
                                     font=ctk.CTkFont(family="Consolas", size=11, weight="bold"),
                                     text_color="#00aaaa")
            len_label.pack(side="right", padx=10)

            # Actualizar longitud en tiempo real
            val_entry.bind("<KeyRelease>", lambda e, l=len_label, w=val_entry: l.configure(text=str(len(w.get()))))
            
            self.entry_widgets[entry['key']] = val_entry

        # Habilitar scroll con rueda de ratón en el editor
        self._setup_scroll_event(self.editor_scroll, self.editor_scroll)

    def save_lang_texts(self):
        """Guarda los cambios realizados en el fichero .bas."""
        if not hasattr(self, "current_lang_manager"):
            return
            
        for key, widget in self.entry_widgets.items():
            new_value = widget.get()
            self.current_lang_manager.update_value(key, new_value)
            
        if self.current_lang_manager.save():
            self.log_write(f"Texts saved successfully in {os.path.basename(self.current_lang_manager.file_path)}\n")
            messagebox.showinfo("Success", "Texts saved successfully!")
            self.show_log()
        else:
            messagebox.showerror("Error", "Could not save texts.")

    def open_keys_editor(self):
        """Abre el editor de keys.cfg en el área principal."""
        editor_root = self.clear_content_area()

        # Header
        header = ctk.CTkFrame(editor_root, fg_color="transparent")
        header.pack(fill="x", padx=30, pady=(20, 10))
        
        title = ctk.CTkLabel(header, text="The Spectrum configuration options", 
                              font=ctk.CTkFont(size=20, weight="bold"), text_color="#00ffff")
        title.pack(side="left")

        # Separador visual
        sep = ctk.CTkFrame(editor_root, height=2, fg_color="#222222")
        sep.pack(fill="x", padx=30, pady=5)

        # Área scrollable para las entradas
        self.keys_scroll = ctk.CTkScrollableFrame(editor_root, fg_color="transparent",
                                                   scrollbar_button_color="#004444",
                                                   scrollbar_button_hover_color="#006666")
        self.keys_scroll.pack(expand=True, fill="both", padx=30, pady=10)
        
        # Load entries
        keys_path = os.path.join(os.getcwd(), "bin/keys.cfg")
        self.keys_manager = KeysConfigManager(keys_path)
        self.keys_widgets = {}
        
        for entry in self.keys_manager.get_entries():
            key = entry['key']
            val = entry['value']
            
            # Ocultar opciones no deseadas
            if key in ["tape_acceleration", "joystick_type"]:
                continue

            row = ctk.CTkFrame(self.keys_scroll, fg_color="transparent")
            row.pack(fill="x", pady=4)
            
            k_lbl = ctk.CTkLabel(row, text=entry['key'], width=200, anchor="w",
                                 font=ctk.CTkFont(family="Consolas", size=12, weight="bold"),
                                 text_color=("#333333", "#aaaaaa"))
            k_lbl.pack(side="left", padx=(5, 15))
            
            if key == "ula_plus":
                var = tk.BooleanVar(value=(val.lower() == "true"))
                widget = ctk.CTkSwitch(row, text="", variable=var, 
                                       progress_color="#008888",
                                       button_color="#00ffff")
                widget.pack(side="left", padx=5)
                self.keys_widgets[key] = var
            elif key in ["emulator_machine", "joystick_type"]:
                options = ["128", "plus2"] if key == "emulator_machine" else ["none", "kempston", "sinclair1", "sinclair2"]
                var = tk.StringVar(value=val)
                widget = ctk.CTkSegmentedButton(row, values=options, variable=var,
                                               selected_color="#008888",
                                               selected_hover_color="#00aaaa")
                widget.pack(side="left", padx=5)
                self.keys_widgets[key] = var
            else:
                k_ent = ctk.CTkEntry(row, height=28, border_width=1, 
                                     border_color=("#cccccc", "#333333"), 
                                     fg_color=("#f0f0f0", "#1a1a1a"),
                                     text_color=("#111111", "#00ffff"))
                k_ent.insert(0, val)
                k_ent.pack(side="left", expand=True, fill="x", padx=5)
                self.keys_widgets[key] = k_ent
            
        # Pie de página (Botones)
        footer = ctk.CTkFrame(editor_root, fg_color="transparent")
        footer.pack(fill="x", padx=30, pady=(10, 20))
        
        save_btn = ctk.CTkButton(footer, text="SAVE CHANGES", font=ctk.CTkFont(weight="bold"),
                                 fg_color="#008888", hover_color="#00aaaa", width=150, height=35,
                                 command=self.save_keys_config)
        save_btn.pack(side="right", padx=10)
        
        close_btn = ctk.CTkButton(footer, text="CLOSE", fg_color="transparent", border_width=1, border_color="#ff5555",
                                  text_color="#ff5555", hover_color="#330000", width=120, height=35,
                                  command=self.show_log)
        close_btn.pack(side="right", padx=10)

        # Habilitar scroll con rueda de ratón
        self._setup_scroll_event(editor_root, self.keys_scroll)

    def save_keys_config(self):
        """Guarda los cambios realizados en keys.cfg."""
        if not hasattr(self, "keys_manager"):
            return
            
        for key, widget_or_var in self.keys_widgets.items():
            if isinstance(widget_or_var, (tk.StringVar, tk.BooleanVar)):
                new_val = str(widget_or_var.get()).lower() if isinstance(widget_or_var, tk.BooleanVar) else widget_or_var.get()
            else:
                new_val = widget_or_var.get()
            self.keys_manager.update_value(key, new_val)
        
        if self.keys_manager.save():
            self.status_label.configure(text="Keys configuration saved!", text_color="#00ff00")
            # Restaurar el texto original después de 3 segundos
            self.after(3000, lambda: self.status_label.configure(text="Welcome to ZXGM Infinity", text_color=("gray10", "#DCE4EE")))
            self.log_write("Keys configuration saved successfully in bin/keys.cfg\n")
            self.show_log()
        else:
            messagebox.showerror("Error", "Could not save keys.cfg")

if __name__ == "__main__":
    app = ZXInfinityApp()
    app.mainloop()