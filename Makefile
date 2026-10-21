# =============================================================================
# Makefile - Sistema de Procesamiento de Apuntes Universitarios
# =============================================================================
# Compatible con Windows (Git Bash) y Linux (Ubuntu)
#
# Uso rapido:
#   make setup                           - Instala dependencias Python
#   make procesar                        - Procesa TODOS los PDFs
#   make procesar MATERIA=cyberseguridad - Procesa solo una materia
#   make procesar MATERIA=cyberseguridad ARCHIVOS="tema1.pdf tema2.docx"
#                                        - Procesa solo esos archivos
#   make pdf                             - Compila TODOS los .tex a PDF
#   make pdf MATERIA=cyberseguridad      - Compila los .tex de una materia
#   make limpiar                         - Borra procesado/ para regenerar
#   make help                            - Muestra esta ayuda
# =============================================================================

# --- Deteccion de plataforma ---
ifeq ($(OS),Windows_NT)
    # Windows: usar bash de Git
    SHELL := C:/Program Files/Git/usr/bin/bash.exe
    PYTHON := python
    PDFLATEX := $(shell command -v pdflatex 2>/dev/null || echo "pdflatex")
else
    # Linux/Mac: bash nativo
    SHELL := /bin/bash
    PYTHON := python3
    PDFLATEX := pdflatex
endif

# Lista de materias (subcarpetas dentro de fuentes/)
MATERIAS := seguridad_e_higiene sistemas_operativos_ii arquitectura_de_computadores cyberseguridad portugues

# Si el usuario pasa MATERIA=nombre, solo procesa esa
ifdef MATERIA
MATERIAS := $(MATERIA)
endif

# Directorios base
DIR_FUENTES   := fuentes
DIR_PROCESADO := procesado
DIR_SCRIPTS   := scripts

# =============================================================================
# TARGETS
# =============================================================================

.PHONY: help setup procesar limpiar limpiar-resumenes estructura pdf

## help: Muestra todos los comandos disponibles
help:
	@echo ""
	@echo "  Comandos disponibles:"
	@echo "  ---------------------------------------------------------"
	@echo "  make setup                            Instala dependencias Python"
	@echo "  make procesar                         Procesa TODOS los PDFs y DOCX"
	@echo "  make procesar MATERIA=<nombre>        Procesa solo una materia"
	@echo "  make procesar MATERIA=<nombre> ARCHIVOS=\"a.pdf b.docx\""
	@echo "                                        Procesa solo esos archivos"
	@echo "  make pdf                              Compila TODOS los .tex a PDF"
	@echo "  make pdf MATERIA=<nombre>             Compila los .tex de una materia"
	@echo "  make limpiar-resumenes                Borra todos los resumenes (.tex, .pdf, etc.)"
	@echo "  make limpiar-resumenes MATERIA=<nombre>"
	@echo "                                        Borra resumenes de una materia"
	@echo "  make limpiar-resumenes MATERIA=<nombre> ARCHIVO=<nombre_sin_ext>"
	@echo "                                        Borra un resumen especifico"
	@echo "  make limpiar                          Borra procesado/ completo"
	@echo "  make limpiar MATERIA=<nombre>         Borra procesado de una materia"
	@echo "  make estructura                       Crea carpetas iniciales"
	@echo "  make help                             Muestra este mensaje"
	@echo ""
	@echo "  Materias disponibles:"
	@echo "    seguridad_e_higiene"
	@echo "    sistemas_operativos_ii"
	@echo "    arquitectura_de_computadores"
	@echo "    cyberseguridad"
	@echo "    portugues"
	@echo ""

## setup: Instala las dependencias Python necesarias
setup:
	@echo "Instalando dependencias Python..."
	$(PYTHON) -m pip install -r $(DIR_SCRIPTS)/requirements.txt
	@echo ""
	@echo "Dependencias instaladas."
	@echo ""
ifeq ($(OS),Windows_NT)
	@echo "IMPORTANTE: Tambien necesitas instalar:"
	@echo "  - Tesseract OCR: https://github.com/UB-Mannheim/tesseract/wiki"
	@echo "    (Instalar con paquete de idioma espanol)"
	@echo "  - MiKTeX: winget install MiKTeX.MiKTeX"
else
	@echo "IMPORTANTE: Tambien necesitas instalar:"
	@echo "  sudo apt install tesseract-ocr tesseract-ocr-spa texlive-full"
endif

## estructura: Crea todas las carpetas necesarias (fuentes + procesado + resumenes)
estructura:
	@echo "Creando estructura de carpetas..."
	@$(foreach m,$(MATERIAS), \
		mkdir -p $(DIR_FUENTES)/$(m) && \
		mkdir -p $(DIR_PROCESADO)/$(m)/texto && \
		mkdir -p $(DIR_PROCESADO)/$(m)/imagenes && \
		mkdir -p resumenes/$(m) && \
	) true
	@echo "Estructura creada."

## procesar: Extrae texto e imagenes de los PDFs y DOCX
##   Sin ARCHIVOS: procesa todo. Con ARCHIVOS="a.pdf b.docx": solo esos.
procesar: estructura
	@echo "Procesando archivos..."
	@$(foreach materia,$(MATERIAS), \
		echo "" && \
		echo "=== $(materia) ===" && \
		( \
			encontrados=0; \
			if [ -n "$(ARCHIVOS)" ]; then \
				for nombre in $(ARCHIVOS); do \
					archivo="$(DIR_FUENTES)/$(materia)/$$nombre"; \
					if [ -f "$$archivo" ]; then \
						encontrados=1; \
						echo "Procesando: $$archivo"; \
						$(PYTHON) $(DIR_SCRIPTS)/extraer_texto.py "$$archivo" "$(DIR_PROCESADO)/$(materia)/texto"; \
						$(PYTHON) $(DIR_SCRIPTS)/extraer_imagenes.py "$$archivo" "$(DIR_PROCESADO)/$(materia)/imagenes"; \
					else \
						echo "  No encontrado: $$archivo"; \
					fi; \
				done; \
			else \
				for archivo in $(DIR_FUENTES)/$(materia)/*.pdf $(DIR_FUENTES)/$(materia)/*.docx; do \
					if [ -f "$$archivo" ]; then \
						encontrados=1; \
						echo "Procesando: $$archivo"; \
						$(PYTHON) $(DIR_SCRIPTS)/extraer_texto.py "$$archivo" "$(DIR_PROCESADO)/$(materia)/texto"; \
						$(PYTHON) $(DIR_SCRIPTS)/extraer_imagenes.py "$$archivo" "$(DIR_PROCESADO)/$(materia)/imagenes"; \
					fi; \
				done; \
			fi; \
			if [ "$$encontrados" = "0" ]; then \
				echo "  (sin archivos para procesar)"; \
			fi; \
		) && \
	) true
	@echo ""
	@echo "Procesamiento completo."

## pdf: Compila los .tex de resumenes/ a PDF (doble pasada para indice)
pdf:
	@echo "Compilando LaTeX a PDF..."
	@$(foreach materia,$(MATERIAS), \
		echo "" && \
		echo "=== $(materia) ===" && \
		( \
			encontrados=0; \
			for tex in resumenes/$(materia)/*.tex; do \
				if [ -f "$$tex" ]; then \
					encontrados=1; \
					echo "Compilando: $$tex"; \
					cd resumenes/$(materia) && \
					$(PDFLATEX) -interaction=nonstopmode "$$(basename $$tex)" > /dev/null 2>&1 && \
					$(PDFLATEX) -interaction=nonstopmode "$$(basename $$tex)" > /dev/null 2>&1 && \
					echo "  OK: $${tex%.tex}.pdf" && \
					cd ../.. || cd ../..; \
				fi; \
			done; \
			if [ "$$encontrados" = "0" ]; then \
				echo "  (sin .tex en resumenes/$(materia)/)"; \
			fi; \
		) && \
	) true
	@echo ""
	@echo "Compilacion completa."

## limpiar-resumenes: Borra .tex, .pdf y archivos auxiliares de resumenes/
##   ARCHIVO=nombre (sin extension) para borrar uno especifico
limpiar-resumenes:
ifdef ARCHIVO
ifndef MATERIA
	@echo "ERROR: Necesitas especificar MATERIA junto con ARCHIVO"
	@echo "  Ejemplo: make limpiar-resumenes MATERIA=cyberseguridad ARCHIVO=cap11_infraestructura_red"
	@exit 1
endif
	@echo "Limpiando resumenes/$(MATERIA)/$(ARCHIVO)..."
	rm -f resumenes/$(MATERIA)/$(ARCHIVO).tex resumenes/$(MATERIA)/$(ARCHIVO).pdf resumenes/$(MATERIA)/$(ARCHIVO).aux resumenes/$(MATERIA)/$(ARCHIVO).log resumenes/$(MATERIA)/$(ARCHIVO).out resumenes/$(MATERIA)/$(ARCHIVO).toc
else ifdef MATERIA
	@echo "Limpiando resumenes/$(MATERIA)/..."
	rm -f resumenes/$(MATERIA)/*.tex resumenes/$(MATERIA)/*.pdf resumenes/$(MATERIA)/*.aux resumenes/$(MATERIA)/*.log resumenes/$(MATERIA)/*.out resumenes/$(MATERIA)/*.toc
else
	@echo "Limpiando todos los resumenes..."
	@$(foreach m,$(MATERIAS), \
		rm -f resumenes/$(m)/*.tex resumenes/$(m)/*.pdf resumenes/$(m)/*.aux resumenes/$(m)/*.log resumenes/$(m)/*.out resumenes/$(m)/*.toc; \
	)
endif
	@echo "Resumenes limpiados."

## limpiar: Borra la carpeta procesado/ (o solo la de una materia)
limpiar:
ifdef MATERIA
	@echo "Limpiando procesado/$(MATERIA)/..."
	rm -rf $(DIR_PROCESADO)/$(MATERIA)
else
	@echo "Limpiando toda la carpeta procesado/..."
	rm -rf $(DIR_PROCESADO)
endif
	@echo "Limpieza completa."
