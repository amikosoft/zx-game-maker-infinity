import os
import platform
import subprocess
import sys

version = "3.3.0"

def printBanner():
    output_text.insert(tk.END, f"\n")
    
    if platform.system() == "Windows":
        output_text.insert(tk.END, f"····::::: ZX INFINITY :::::····\n")
    elif platform.system() in ["Linux", "Darwin"]:
        with open("infinitybanner.txt", "r") as f:
            logo_string = f.readlines()

            for textTmp, line in enumerate(logo_string):
                output_text.insert(tk.END, f"{line}")
    
    output_text.insert(tk.END, f"-= by Amikosoft =- Ver. {version}\n\n")

def show_help_info():
    # Limpiar la ventana de salida
    output_text.delete(1.0, tk.END)
    
    printBanner()

    output_text.insert(tk.END, f"Quick info\n")
    
    output_text.insert(tk.END, f"\n- Game: (disabled while build is in progress)\n")
    output_text.insert(tk.END, f"\tPlay: run your last compilated version\n")
    output_text.insert(tk.END, f"\tPlay RF: run your last compilated version in RF mode\n")
    output_text.insert(tk.END, f"\t--------\n")
    output_text.insert(tk.END, f"\tBuild: compile you game (includes tiles+sprites). See progress in the log box\n")
    output_text.insert(tk.END, f"\tBuild (verbose): compile you game with progress detailed in the log box\n")
    output_text.insert(tk.END, f"\t--------\n")
    output_text.insert(tk.END, f"\tBuild tiles+sprites: compile tiles and sprites in order to see in tiled tool\n")
    output_text.insert(tk.END, f"\tBuild FX: runs the FX tool in order to generate FXs for your project\n")
    
    output_text.insert(tk.END, f"\n- Map:\n")
    output_text.insert(tk.END, f"\tOpen map: open Tiled with the map in your assets folder\n")
    
    output_text.insert(tk.END, f"\n- Sprites preview:\n")
    output_text.insert(tk.END, f"\tMain character: shows player animations\n")
    output_text.insert(tk.END, f"\tPlatforms: shows platforms animations\n")
    output_text.insert(tk.END, f"\tEnemies: shows enemies animations\n")
    
    output_text.insert(tk.END, f"\n- Memory usage:\n")
    output_text.insert(tk.END, f"\tBank 0 48k: shows pie chart with memory allocation of your game\n")
    output_text.insert(tk.END, f"\t--------\n")
    output_text.insert(tk.END, f"\tBank 0/3/4/6 128k: shows pie charts with memory allocation of your game per bank\n")
    
    output_text.insert(tk.END, f"\n- Help:\n")
    output_text.insert(tk.END, f"\tTool help: this one\n")
    output_text.insert(tk.END, f"\t--------\n")
    output_text.insert(tk.END, f"\tInfinity docs: opens infinity help docs in browser\n")
    output_text.insert(tk.END, f"\tZXGM Documentation: opens ZXGM docs in browser\n")
    output_text.insert(tk.END, f"\t--------\n")
    output_text.insert(tk.END, f"\tDiscord: invitation link for the discord support group\n")
    output_text.insert(tk.END, f"\tTelegram: link for the telegram support group\n")
    output_text.insert(tk.END, f"\tGithub: open source repository\n")
    
    output_text.insert(tk.END, f"\n- Exit:\n")
    output_text.insert(tk.END, f"\tCloses application (disabled while build is in progress)")
    
def install_requirements():
    """Ejecuta el script de instalación de dependencias según el sistema operativo."""
    try:
        # Detectar el sistema operativo
        current_os = platform.system()
        script_name = ""

        if current_os == "Windows":
            script_name = "install-requeriments.ps1"
        elif current_os in ["Linux", "Darwin"]:  # Linux o macOS
            script_name = "install-requeriments.sh"
        else:
            print(f"Sistema operativo no soportado: {current_os}")
            sys.exit(1)

        # Construir la ruta completa del script
        script_path = os.path.join(os.path.dirname(__file__), "scripts", script_name)

        # Verificar si el script existe
        if not os.path.exists(script_path):
            print(f"No se encontró el script: {script_path}")
            sys.exit(1)

        # Ejecutar el script
        if current_os == "Windows":
            subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path], check=True)
        else:
            subprocess.run(["bash", script_path], check=True)

    except subprocess.CalledProcessError as e:
        print(f"Error al ejecutar el script de instalación de dependencias: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error inesperado: {e}")
        sys.exit(1)

# Ejecutar la instalación de dependencias antes de importar cualquier módulo
install_requirements()

import tkinter as tk
from tkinter import messagebox, PhotoImage
import threading
import webbrowser

from builder.SpritesPreviewGenerator import SpritesPreviewGenerator
from builder.helper import DIST_FOLDER, MAPS_PROJECT, getProjectFileName

import os

# Establecer el directorio de trabajo al directorio del script
os.chdir(os.path.dirname(os.path.abspath(__file__)))

def run_script(script_name, extra_args=None):
    def execute(script_name):
        try:
            menu_bar.entryconfig('-= Game =-', state='disabled')
            menu_bar.entryconfig('Exit', state='disabled')
            logo2_label.configure(background='#f55')
            status_bar.configure(text='Running ' + script_name + '...')
            
            # Limpiar la ventana de salida
            output_text.delete(1.0, tk.END)

            printBanner()

            # Detectar el sistema operativo y añadir la extensión adecuada
            if platform.system() == "Windows":
                script_name += ".ps1"
            elif platform.system() in ["Linux", "Darwin"]:
                script_name += ".sh"
            else:
                output_text.insert(tk.END, f"El sistema operativo no es compatible.\n")
                return

            # Construir la ruta completa del script en la carpeta src/scripts
            script_path = os.path.join(os.getcwd(), "scripts", script_name)

            # Verificar si el script existe
            if not os.path.exists(script_path):
                output_text.insert(tk.END, f"No se encontró el script: {script_path}\n")
                return

            # Construir el comando con parámetros adicionales
            command = [script_path]
            if extra_args:
                command.extend(extra_args)

            # Ejecutar el script según el sistema operativo
            if platform.system() == "Windows":
                process = subprocess.Popen(
                    ["powershell", "-ExecutionPolicy", "Bypass", "-File"] + command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    bufsize=1
                )
            elif platform.system() in ["Linux", "Darwin"]:
                process = subprocess.Popen(
                    ["bash"] + command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    bufsize=1
                )

            # Leer la salida del proceso en tiempo real
            for line in iter(process.stdout.readline, ''):
                output_text.insert(tk.END, line)
                output_text.see(tk.END)

            for line in iter(process.stderr.readline, ''):
                output_text.insert(tk.END, line)
                output_text.see(tk.END)

            process.wait()
            # if process.returncode == 0:
            #     output_text.insert(tk.END, f"\nEl script {script_name} se ejecutó correctamente.\n")
            # else:
            #     output_text.insert(tk.END, f"\nEl script {script_name} terminó con errores.\n")

            status_bar.configure(text='Last executed: ' + script_name)
        except FileNotFoundError:
            output_text.insert(tk.END, f"No se encontró el script {script_name}\n")
            status_bar.configure(text=f"No se encontró el script {script_name}")
        except Exception as e:
            output_text.insert(tk.END, f"Error al ejecutar {script_name}:\n{e}\n")
            status_bar.configure(text=f"Error al ejecutar {script_name}")

        logo2_label.configure(background='#000')
        menu_bar.entryconfig('-= Game =-', state='normal')
        menu_bar.entryconfig('Exit', state='normal')
            
    threading.Thread(target=execute, args=(script_name,)).start()

def open_game_variant(variant):
    """Abre el juego en su variante 'Normal' o 'RF'."""
    try:
        project_name = getProjectFileName()

        if variant == "rf":
            project_name += "-RF"

        status_bar.configure(text='Running ' + project_name + '...')
        
        # Detectar el sistema operativo y seleccionar el archivo ejecutable
        if platform.system() == "Windows":
            game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.exe")
        elif platform.system() in ["Linux", "Darwin"]:
            game_path = os.path.join(os.getcwd(), DIST_FOLDER, f"{project_name}.linux")
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
            return

        # Verificar si el archivo existe
        if not os.path.exists(game_path):
            messagebox.showerror("Error", f"No se encontró el archivo del juego: {game_path}")
            return

        status_bar.configure(text='Executed ' + project_name)

        # Abrir el archivo ejecutable
        subprocess.Popen([game_path], shell=True)
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir el juego: {e}")

def show_modal_with_animation(gif_path):
    """Abre el GIF en el navegador predeterminado."""
    try:
        # Verificar si el archivo existe
        if not os.path.exists(gif_path):
            messagebox.showerror("Error", f"No se encontró el archivo: {gif_path}")
            return

        # Abrir el archivo GIF en el navegador predeterminado
        webbrowser.open(f"file://{os.path.abspath(gif_path)}")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir el GIF: {e}")

def open_main_character_running_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateMainPreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_main_character_idle_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateIdlePreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_first_platform_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateFirstPreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_second_platform_preview():
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateSecondPreview()
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def open_enemy_preview(enemy_number):
    """Ejecuta la función y muestra el resultado en un modal."""
    try:
        # Llamar a la función que genera el preview
        result = SpritesPreviewGenerator.generateEnemy(enemy_number)
        if result:
            show_modal_with_animation(result)
        else:
            messagebox.showerror("Error", "No se generó ningún resultado.")
    except Exception as e:
        messagebox.showerror("Error", f"Error al generar el preview: {e}")

def show_sprites_menu(event):
    # Crear un menú emergente
    sprites_menu = tk.Menu(root, tearoff=0)

    # Submenú para "Main Character"
    main_character_menu = tk.Menu(sprites_menu, tearoff=0)
    main_character_menu.add_command(label="Running", command=open_main_character_running_preview)
    main_character_menu.add_command(label="Idle", command=lambda: open_main_character_idle_preview())
    sprites_menu.add_cascade(label="Main Character", menu=main_character_menu)

    # Submenú para "Platforms"
    platforms_menu = tk.Menu(sprites_menu, tearoff=0)
    platforms_menu.add_command(label="Platform 1", command=lambda: open_first_platform_preview())
    platforms_menu.add_command(label="Platform 2", command=lambda: open_second_platform_preview())
    sprites_menu.add_cascade(label="Platforms", menu=platforms_menu)

    # Submenú para "Enemies"
    enemies_menu = tk.Menu(sprites_menu, tearoff=0)
    for i in range(1, 9):  # Generar dinámicamente las opciones de enemigos del 1 al 8
        enemies_menu.add_command(label=f"Enemy {i}", command=lambda i=i: open_enemy_preview(i))
    sprites_menu.add_cascade(label="Enemies", menu=enemies_menu)

    # Mostrar el menú en la posición del cursor
    sprites_menu.post(event.x_root, event.y_root)

def open_memory_bank_image(image):
    """Abre la imagen de uso de memoria para el banco especificado."""
    try:
        # Construir la ruta de la imagen
        image_path = os.path.join(os.getcwd(), "output", image)

        # Verificar si la imagen existe
        if not os.path.exists(image_path):
            messagebox.showerror("Error", f"No se encontró la imagen: {image_path}")
            return

        # Abrir la imagen con el visor predeterminado del sistema
        if platform.system() == "Windows":
            os.startfile(image_path)
        elif platform.system() == "Linux":
            subprocess.Popen(["xdg-open", image_path])
        elif platform.system() == "Darwin":  # macOS
            subprocess.Popen(["open", image_path])
        else:
            messagebox.showerror("Error", "El sistema operativo no es compatible.")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo abrir la imagen: {e}")

def open_map_with_tiled():
    """Abre el mapa en Tiled."""
    # Verificar si la variable MAPS_PROJECT está definida
    if not MAPS_PROJECT:
        messagebox.showerror("Error", "No se especificó el archivo del mapa.")
        return

    # Verificar si el archivo del mapa existe
    if not os.path.exists(MAPS_PROJECT):
        messagebox.showerror("Error", f"No se encontró el archivo del mapa: {MAPS_PROJECT}")
        return
    
    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        command = "\"" + program_files + "\\Tiled\\tiled.exe\" " + MAPS_PROJECT
    else:
        command = "tiled " + MAPS_PROJECT
    
    subprocess.Popen(command, shell=True)
    
    # Ejecutar el comando

# Crear la ventana principal
root = tk.Tk()
root.title(f"ZXGM - Infinity v{version}")
root.geometry("750x750")
root.resizable(True, True)

# root.grid_columnconfigure(0, weight=1)
# root.grid(baseWidth=0, baseHeight=0,widthInc=1, heightInc=1)
# content = tk.Frame(master=root, background="#000")
# content.grid(column=0, row=0)
# content.pack()

# content.columnconfigure(0, weight=1, pad=1)
# content.columnconfigure(1, weight=1, pad=5)
# content.rowconfigure(0, weight=2, pad=2)
# content.rowconfigure(1, weight=2, pad=1)

# Establecer el icono de la aplicación
icon_path = os.path.join(os.getcwd(), "ui/infinity_logo.png")
if os.path.exists(icon_path):
    root.iconphoto(True, PhotoImage(file=icon_path))
else:
    messagebox.showwarning("Advertencia", "No se encontró el icono en 'ui/infinity_logo.png'.")

# Carga del logo
logo2_path = os.path.join(os.getcwd(), "ui/infinity_logo.png")
if not os.path.exists(logo2_path):
    messagebox.showwarning("Advertencia", "No se encontró el logo en 'ui/infinity_logo.png'.")


logo2 = PhotoImage(file=logo2_path)
# logo2_frame = tk.Frame(root, borderwidth=0)
# logo2_frame.grid(column=0, row=0)
logo2_label = tk.Label(root, image=logo2, borderwidth=0, background='#000')
logo2_label.pack(ipadx=2, ipady=5, fill=tk.X)

# logo2_label.place(x=0, y=0, height=100, width=100)

# spectrum_path = os.path.join(os.getcwd(), "ui/spectrum.png")
# if os.path.exists(spectrum_path):
#     logoSpectrum = PhotoImage(file=spectrum_path)
#     logoSpectrum_frame = tk.Frame(master=content)
#     logoSpectrum_frame.grid(column=1, row=0)
#     logoSpectrum_label = tk.Label(master=logoSpectrum_frame, image=logoSpectrum, borderwidth=0)
#     logoSpectrum_label.pack(padx=1, pady=1)
#     # logoSpectrum_label.pack(side='right')
# else:
#     messagebox.showwarning("Advertencia", "No se encontró el logo en 'ui/spectrum.png'.")

# Crear el menú de barras
menu_bar = tk.Menu(root,background='#111', foreground='#ffffff', borderwidth=0)

# Menú "GAME"
build_menu = tk.Menu(menu_bar, tearoff=0)
build_menu.add_command(label="Play", command=lambda: open_game_variant("normal"))
build_menu.add_command(label="Play RF", command=lambda: open_game_variant("rf"))
build_menu.add_separator()
build_menu.add_command(label="Build", command=lambda: run_script("make-game"))
build_menu.add_command(label="Build (verbose)", command=lambda: run_script("make-game", ["--verbose"]))
build_menu.add_separator()
build_menu.add_command(label="Build Tiles+Sprites", command=lambda: run_script("make-graphics"))
build_menu.add_command(label="Build FX", command=lambda: run_script("make-fx"))

menu_bar.add_cascade(label="-= Game =-", menu=build_menu)

# Menú "Map"
map_menu = tk.Menu(menu_bar, tearoff=0)
map_menu.add_command(label="Open Map", command=open_map_with_tiled)
menu_bar.add_cascade(label="Map", menu=map_menu)

# Menú "Sprites"
sprites_menu = tk.Menu(menu_bar, tearoff=0)

# Submenú para "Main Character"
main_character_menu = tk.Menu(sprites_menu, tearoff=0)
main_character_menu.add_command(label="Running", command=open_main_character_running_preview)
main_character_menu.add_command(label="Idle", command=open_main_character_idle_preview)
sprites_menu.add_cascade(label="Main Character", menu=main_character_menu)

# Submenú para "Platforms"
platforms_menu = tk.Menu(sprites_menu, tearoff=0)
platforms_menu.add_command(label="Platform 1", command=open_first_platform_preview)
platforms_menu.add_command(label="Platform 2", command=open_second_platform_preview)
sprites_menu.add_cascade(label="Platforms", menu=platforms_menu)

# Submenú para "Enemies"
enemies_menu = tk.Menu(sprites_menu, tearoff=0)
for i in range(1, 9):  # Generar dinámicamente las opciones de enemigos del 1 al 8
    enemies_menu.add_command(label=f"Enemy {i}", command=lambda i=i: open_enemy_preview(i))
sprites_menu.add_cascade(label="Enemies", menu=enemies_menu)

menu_bar.add_cascade(label="Sprites Preview", menu=sprites_menu)

# Menú "Game"
# game_menu = tk.Menu(menu_bar, tearoff=0)
# game_menu.add_command(label="Normal", command=lambda: open_game_variant("normal"))
# game_menu.add_command(label="RF", command=lambda: open_game_variant("rf"))
# menu_bar.add_cascade(label="Game", menu=game_menu)

# Menú "Memory Usage"
memory_menu = tk.Menu(menu_bar, tearoff=0)
memory_menu.add_command(label="Bank 0 48k", command=lambda: open_memory_bank_image("memory-bank-0-48K.png"))
memory_menu.add_separator()
memory_menu.add_command(label="Bank 0 128k", command=lambda: open_memory_bank_image("memory-bank-0-128K.png"))
memory_menu.add_command(label="Bank 3", command=lambda: open_memory_bank_image("memory-bank-3.png"))
memory_menu.add_command(label="Bank 4", command=lambda: open_memory_bank_image("memory-bank-4.png"))
memory_menu.add_command(label="Bank 6", command=lambda: open_memory_bank_image("memory-bank-6.png"))
menu_bar.add_cascade(label="Memory Usage", menu=memory_menu)

# Menú "Help"
help_menu = tk.Menu(menu_bar, tearoff=0)
infinity_docs_path = os.path.join(os.path.dirname(__file__), "../site", "index.html")
help_menu.add_command(label="Tool help", command=lambda: show_help_info())
help_menu.add_separator()

help_menu.add_command(label="Infinity Docs", command=lambda: webbrowser.open(infinity_docs_path))
help_menu.add_command(label="ZXGM Documentation", command=lambda: webbrowser.open("https://gm.retrojuegos.org/"))
help_menu.add_separator()
help_menu.add_command(label="Discord", command=lambda: webbrowser.open("https://discord.com/channels/942735294359277578/1390332022630907945"))
help_menu.add_command(label="Telegram", command=lambda: webbrowser.open("https://t.me/+R5PUBeHV0WhlMjQ0"))
help_menu.add_command(label="GitHub", command=lambda: webbrowser.open("https://github.com/amikosoft/zx-game-maker-infinity"))
menu_bar.add_cascade(label="Help", menu=help_menu)

menu_bar.add_command(label="Exit", command=root.quit)

# Configurar el menú en la ventana principal
root.config(menu=menu_bar, background='#000000')

status_bar = tk.Label(root, relief="ridge", text='Welcome to ZXGM Infinity -= by Amikosoft =-', background='#111', foreground='#c4c4c4', justify='left', anchor="w")
status_bar.pack(side=tk.BOTTOM,fill=tk.X,padx=2, pady=2)

# Área de texto para mostrar la salida de los scripts
# output_text_frame = tk.Frame(master=content)
# output_text_frame.grid(column=0, row=1, columnspan=2)
output_text = tk.Text(root, width=100, height=100,background='#111111', foreground='#c4c4c4', borderwidth=0)
output_text.pack(side=tk.BOTTOM,padx=2, pady=2, fill=tk.X)
# output_text.insert(tk.END, "Welcome to ZXGM Infinity -= by Amikosoft =-")
# self.pack(side=tk.BOTTOM, fill=tk.X)

show_help_info()

# Iniciar el bucle principal de la aplicación
root.mainloop()