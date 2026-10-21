"""
Extrae todas las imágenes embebidas de un PDF o DOCX y las guarda como archivos.

Uso:
    python extraer_imagenes.py <ruta_archivo> <carpeta_destino>
"""

import sys
from pathlib import Path

import fitz  # pymupdf
from docx import Document
from docx.opc.constants import RELATIONSHIP_TYPE as RT


# Tamaño mínimo en bytes para guardar una imagen (ignora íconos pequeños)
TAMANO_MIN_BYTES = 5000


def extraer_imagenes_pdf(ruta, carpeta_destino):
    """Extrae imágenes embebidas de un PDF."""
    doc = fitz.open(str(ruta))
    nombre_base = ruta.stem
    contador = 0

    for num_pag in range(len(doc)):
        pagina = doc[num_pag]
        imagenes = pagina.get_images(full=True)

        for img_info in imagenes:
            xref = img_info[0]

            try:
                img_data = doc.extract_image(xref)
            except Exception:
                continue

            if not img_data or len(img_data["image"]) < TAMANO_MIN_BYTES:
                continue

            contador += 1
            extension = img_data["ext"]
            nombre_archivo = f"{nombre_base}_img{contador}.{extension}"
            ruta_imagen = carpeta_destino / nombre_archivo
            ruta_imagen.write_bytes(img_data["image"])

    doc.close()
    return contador


def extraer_imagenes_docx(ruta, carpeta_destino):
    """Extrae imágenes embebidas de un DOCX."""
    doc = Document(str(ruta))
    nombre_base = ruta.stem
    contador = 0

    for rel in doc.part.rels.values():
        if "image" in rel.reltype:
            img_data = rel.target_part.blob

            if len(img_data) < TAMANO_MIN_BYTES:
                continue

            contador += 1
            content_type = rel.target_part.content_type
            extension = content_type.split("/")[-1].replace("jpeg", "jpg")
            nombre_archivo = f"{nombre_base}_img{contador}.{extension}"
            ruta_imagen = carpeta_destino / nombre_archivo
            ruta_imagen.write_bytes(img_data)

    return contador


def extraer_imagenes(ruta_archivo, carpeta_destino):
    """Detecta el tipo de archivo y extrae imágenes."""
    ruta = Path(ruta_archivo)
    carpeta_destino = Path(carpeta_destino)
    carpeta_destino.mkdir(parents=True, exist_ok=True)

    extension = ruta.suffix.lower()

    if extension == ".pdf":
        contador = extraer_imagenes_pdf(ruta, carpeta_destino)
    elif extension == ".docx":
        contador = extraer_imagenes_docx(ruta, carpeta_destino)
    else:
        print(f"  Formato no soportado: {ruta.name}")
        return

    if contador > 0:
        print(f"  {contador} imágenes extraídas en: {carpeta_destino}")
    else:
        print(f"  Sin imágenes relevantes en: {ruta.name}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Uso: python {sys.argv[0]} <ruta_archivo> <carpeta_destino>")
        sys.exit(1)

    extraer_imagenes(sys.argv[1], sys.argv[2])
