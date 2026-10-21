"""
Extrae texto de un PDF o DOCX y lo guarda como .txt en la carpeta destino.
- PDF: usa pymupdf para texto nativo y pytesseract OCR para páginas escaneadas.
- DOCX: usa python-docx para extraer párrafos y texto de tablas.

Uso:
    python extraer_texto.py <ruta_archivo> <carpeta_destino>
"""

import sys
from pathlib import Path

import fitz  # pymupdf
import pytesseract
from PIL import Image
import io
from docx import Document


# Umbral mínimo de caracteres para considerar que una página tiene texto útil.
UMBRAL_TEXTO_MIN = 30


def extraer_texto_pagina_pdf(pagina):
    """Extrae texto de una página PDF. Si no tiene suficiente texto nativo, usa OCR."""
    texto = pagina.get_text().strip()

    if len(texto) >= UMBRAL_TEXTO_MIN:
        return texto

    pix = pagina.get_pixmap(dpi=300)
    img = Image.open(io.BytesIO(pix.tobytes("png")))
    texto_ocr = pytesseract.image_to_string(img, lang="spa+eng")
    return texto_ocr.strip()


def procesar_pdf(ruta, carpeta_destino):
    """Procesa un PDF completo y guarda el texto extraído en un .txt."""
    doc = fitz.open(str(ruta))
    textos = []

    for num_pag in range(len(doc)):
        pagina = doc[num_pag]
        texto = extraer_texto_pagina_pdf(pagina)
        if texto:
            textos.append(f"--- Página {num_pag + 1} ---\n{texto}")

    doc.close()
    return "\n\n".join(textos)


def procesar_docx(ruta):
    """Procesa un DOCX y devuelve todo el texto (párrafos + tablas)."""
    doc = Document(str(ruta))
    textos = []

    # Párrafos
    for parrafo in doc.paragraphs:
        texto = parrafo.text.strip()
        if texto:
            textos.append(texto)

    # Tablas
    for tabla in doc.tables:
        for fila in tabla.rows:
            celdas = [celda.text.strip() for celda in fila.cells if celda.text.strip()]
            if celdas:
                textos.append(" | ".join(celdas))

    return "\n".join(textos)


def procesar_archivo(ruta_archivo, carpeta_destino):
    """Detecta el tipo de archivo y extrae el texto."""
    ruta = Path(ruta_archivo)
    carpeta_destino = Path(carpeta_destino)
    carpeta_destino.mkdir(parents=True, exist_ok=True)

    extension = ruta.suffix.lower()

    if extension == ".pdf":
        contenido = procesar_pdf(ruta, carpeta_destino)
    elif extension == ".docx":
        contenido = procesar_docx(ruta)
    else:
        print(f"  Formato no soportado: {ruta.name}")
        return

    ruta_salida = carpeta_destino / (ruta.stem + ".txt")
    ruta_salida.write_text(contenido, encoding="utf-8")
    print(f"  Texto extraído: {ruta_salida}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Uso: python {sys.argv[0]} <ruta_archivo> <carpeta_destino>")
        sys.exit(1)

    procesar_archivo(sys.argv[1], sys.argv[2])
