#!/usr/bin/env python3
"""install_modules.py

Adaptación para Linux (Ubuntu 20.04) de un *wrapper* que, en Windows,
utiliza un script PowerShell (`menu.ps1`) para instalar módulos ubicados en
`src/windows/module`.

Este script realiza lo mismo pero en Python, sin depender de PowerShell
excepto para la verificación opcional de los módulos instalados.

Uso::
    python3 install_modules.py            # muestra el menú interactivo
    python3 install_modules.py --all      # instala todos los módulos sin preguntar
    python3 install_modules.py --module <nombre>  # instala solo el módulo especificado
    python3 install_modules.py --verify   # tras copiar, intenta cargar el módulo con pwsh

Requisitos:
    * Python 3.8+ (ya disponible en Ubuntu 20.04)
    * Variable de entorno HOME definida (por defecto en Linux)
    * (Opcional) pwsh instalado para la verificación

El script copia cada carpeta de módulo a la ubicación de módulos de PowerShell
para Linux, que es ``$HOME/.local/share/powershell/Modules``.  Si esa ruta no
existe, se crea automáticamente.

Después de la copia, opcionalmente se intenta cargar el módulo con ``pwsh``
para asegurar que la instalación fue correcta.  Si ``pwsh`` no está
instalado, el script lo indica pero continúa con la copia.
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

def find_pwsh() -> str | None:
    """Busca el ejecutable de PowerShell Core (pwsh) en el PATH.
    Devuelve la ruta completa o ``None`` si no se encuentra.
    """
    for candidate in ("pwsh", "pwsh.exe"):
        path = shutil.which(candidate)
        if path:
            return path
    return None

def copy_module(src: Path, dest_root: Path) -> None:
    """Copia un módulo completo a la raíz de módulos de PowerShell.

    La estructura de destino será ``dest_root/<module_name>`` donde
    ``module_name`` es el nombre de la carpeta ``src``.
    Si la carpeta de destino ya existe, se elimina primero para garantizar
    una instalación limpia.
    """
    dest = dest_root / src.name
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    print(f"[✓] Copiado módulo '{src.name}' a '{dest}'.")

def verify_module(module_name: str, pwsh_path: str) -> None:
    """Intenta cargar el módulo usando PowerShell y muestra el resultado.
    No se considera fatal si la carga falla; solo se informa al usuario.
    """
    cmd = [pwsh_path, "-NoLogo", "-NoProfile", "-Command", f"Import-Module -Name {module_name} -ErrorAction Stop; Write-Host 'Módulo cargado correctamente.'"]
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"[⚠] No se pudo cargar el módulo '{module_name}'. Detalle:")
        print(e.stderr.strip())
    else:
        print(f"[✓] Verificación exitosa del módulo '{module_name}'.")

def list_modules(modules_dir: Path) -> list[Path]:
    """Devuelve una lista de rutas a los módulos (carpetas) dentro de ``modules_dir``.
    Ignora archivos que no sean directorios.
    """
    if not modules_dir.is_dir():
        print(f"Error: el directorio de módulos '{modules_dir}' no existe.")
        sys.exit(1)
    return [p for p in modules_dir.iterdir() if p.is_dir()]

def main() -> None:
    parser = argparse.ArgumentParser(description="Instalador de módulos PowerShell para Linux (Ubuntu 20.04).")
    parser.add_argument("--all", action="store_true", help="Instalar todos los módulos sin mostrar menú interactivo.")
    parser.add_argument("--module", type=str, help="Instalar sólo el módulo especificado (nombre de la carpeta).")
    parser.add_argument("--verify", action="store_true", help="Después de copiar, intentar cargar cada módulo con pwsh.")
    args = parser.parse_args()

    # Ruta del directorio que contiene los módulos (relativa al script)
    script_dir = Path(__file__).parent.resolve()
    modules_dir = script_dir / "src" / "windows" / "module"
    modules = list_modules(modules_dir)

    if not modules:
        print("No se encontraron módulos para instalar.")
        sys.exit(0)

    # Determinar qué módulos instalar
    to_install: list[Path] = []
    if args.module:
        match = next((m for m in modules if m.name == args.module), None)
        if not match:
            print(f"Módulo '{args.module}' no encontrado en '{modules_dir}'.")
            sys.exit(1)
        to_install = [match]
    elif args.all:
        to_install = modules
    else:
        # Menú interactivo
        print("Módulos disponibles:")
        for idx, mod in enumerate(modules, start=1):
            print(f"  {idx}. {mod.name}")
        print("  0. Instalar TODOS los módulos")
        selection = input("Seleccione el número del módulo a instalar (o 0 para todos, separados por comas): ")
        if not selection.strip():
            print("No se seleccionó nada. Saliendo.")
            sys.exit(0)
        choices = [s.strip() for s in selection.split(',')]
        if '0' in choices:
            to_install = modules
        else:
            for c in choices:
                if not c.isdigit():
                    continue
                idx = int(c) - 1
                if 0 <= idx < len(modules):
                    to_install.append(modules[idx])
        if not to_install:
            print("No se seleccionó ningún módulo válido. Saliendo.")
            sys.exit(0)

    # Ruta destino de los módulos PowerShell en Linux
    dest_root = Path(os.getenv("HOME", "~")) / ".local" / "share" / "powershell" / "Modules"
    dest_root.mkdir(parents=True, exist_ok=True)

    pwsh_path = find_pwsh()
    if args.verify and not pwsh_path:
        print("[⚠] pwsh no está instalado; la verificación se omitirá.")
        args.verify = False

    for mod_path in to_install:
        copy_module(mod_path, dest_root)
        if args.verify:
            verify_module(mod_path.name, pwsh_path)

    print("\nInstalación completada.")
    if args.verify:
        print("Verifique los mensajes anteriores para posibles errores de carga.")

if __name__ == "__main__":
    main()
