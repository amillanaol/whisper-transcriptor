# Makefile for whisper-transcriptor
# Target: install
# Lanza el menú interactivo que permite instalar, desinstalar o realizar otras acciones.

.PHONY: install

install:
	@echo "Ejecutando menú interactivo..."
	@powershell -ExecutionPolicy Bypass -File src/windows/menu.ps1
