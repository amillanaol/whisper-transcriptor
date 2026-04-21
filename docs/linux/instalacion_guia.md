# src/linux

Este directorio contiene los scripts de Python que adaptan la funcionalidad del antiguo `menu.ps1` (Windows) a un entorno Linux/Ubuntu.

## Archivo principal

- **install_modules.py** – Wrapper que instala los módulos PowerShell ubicados en `src/windows/module` en la ruta de módulos de PowerShell para Linux (`$HOME/.local/share/powershell/Modules`).

## Uso rápido

```bash
# Menú interactivo
python3 src/linux/install_modules.py

# Instalar todos los módulos sin preguntar
python3 src/linux/install_modules.py --all

# Instalar sólo un módulo concreto
python3 src/linux/install_modules.py --module NombreDelModulo

# Instalar y verificar (requiere pwsh)
python3 src/linux/install_modules.py --all --verify
```

Los módulos copiados estarán disponibles para cualquier script PowerShell que se ejecute bajo WSL o una instalación nativa de PowerShell en Linux.
