# LATEX - Sistema de Procesamiento de Apuntes Universitarios

Sistema automatizado que procesa PDFs y DOCX de la facultad, extrayendo texto plano e imagenes. Luego, con Claude, se generan resumenes completos en LaTeX con diagramas TikZ para estudiar.

Compatible con **Windows** y **Linux Ubuntu**.

---

## Requisitos

### Windows

```powershell
winget install GnuWin32.Make       # Make
winget install MiKTeX.MiKTeX       # LaTeX
```
- **Python 3.8+** (ya instalado o desde python.org)
- **Git Bash** como terminal en VS Code (recomendado)
- **Tesseract OCR**: descargar desde https://github.com/UB-Mannheim/tesseract/wiki (instalar con idioma espanol)

### Linux Ubuntu

```bash
sudo apt update
sudo apt install make python3 python3-pip tesseract-ocr tesseract-ocr-spa texlive-full
```

---

## Instalacion

```bash
git clone https://github.com/Tuteku/LATEX.git
cd LATEX
make setup
```

---

## Uso

### 1. Procesar material

Poner PDFs o DOCX en `fuentes/<materia>/` y ejecutar:

```bash
# Procesar todo
make procesar

# Solo una materia
make procesar MATERIA=cyberseguridad

# Solo archivos especificos
make procesar MATERIA=cyberseguridad ARCHIVOS="tema1.pdf clase2.docx"
```

### 2. Generar resumen LaTeX

Pedirle a Claude que lea `procesado/<materia>/texto/` y las imagenes, y genere el `.tex` en `resumenes/<materia>/`.

### 3. Compilar a PDF

```bash
# Compilar los .tex de una materia
make pdf MATERIA=cyberseguridad

# Compilar todos
make pdf
```

### 4. Limpiar

```bash
# Borrar un resumen especifico
make limpiar-resumenes MATERIA=cyberseguridad ARCHIVO=cap11_redes

# Borrar todos los resumenes de una materia
make limpiar-resumenes MATERIA=cyberseguridad

# Borrar el procesado (para reprocesar)
make limpiar MATERIA=cyberseguridad
```

---

## Estructura

```
fuentes/                    # Material crudo (PDFs, DOCX)
  cyberseguridad/
  sistemas_operativos_ii/
  seguridad_e_higiene/
  arquitectura_de_computadores/
  portugues/

procesado/                  # Generado por make procesar
  <materia>/
    texto/                  # .txt extraidos de cada PDF/DOCX
    imagenes/               # .png extraidas de cada PDF/DOCX

resumenes/                  # .tex generados por Claude + .pdf compilados
  <materia>/

scripts/
  extraer_texto.py          # Extrae texto (pymupdf + OCR)
  extraer_imagenes.py       # Extrae imagenes embebidas
  requirements.txt          # Dependencias Python

Makefile                    # Orquesta todo
CLAUDE.md                   # Instrucciones para Claude
```

---

## Comandos

| Comando | Descripcion |
|---------|-------------|
| `make help` | Muestra todos los comandos |
| `make setup` | Instala dependencias Python |
| `make procesar` | Extrae texto e imagenes de PDFs/DOCX |
| `make pdf` | Compila .tex a PDF |
| `make limpiar-resumenes` | Borra resumenes (.tex, .pdf, auxiliares) |
| `make limpiar` | Borra procesado/ |
| `make estructura` | Crea carpetas iniciales |

Todos aceptan `MATERIA=<nombre>` para filtrar por materia.
