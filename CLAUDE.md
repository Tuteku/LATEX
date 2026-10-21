# Sistema de Apuntes Universitarios

## Flujo de trabajo
1. El usuario pone PDFs/DOCX en `fuentes/<materia>/`
2. Ejecuta `make procesar MATERIA=<nombre>` para extraer texto e imágenes
3. Me pide generar el resumen LaTeX — yo leo `procesado/<materia>/texto/*.txt` y las imágenes
4. Genero el `.tex` en `resumenes/<materia>/`
5. El usuario compila con `make pdf MATERIA=<nombre>`

## Reglas al generar LaTeX

### Yo NO compilo
El usuario compila con `make pdf`. Solo genero el `.tex`.

### Plantilla obligatoria
Leer `memory/latex-template.md` para el preámbulo. Puntos críticos:
- babel DEBE incluir: `[spanish,es-noquoting,es-noshorthands]` (sin esto TikZ falla)
- `\graphicspath{{../../procesado/<materia>/imagenes/}}`
- Incluir `\usepackage{float}` para `[H]` en figuras

### Contenido
- Resúmenes COMPLETOS para estudiar, no resumidos
- Respetar el orden de secciones del material original (no mezclar capítulos)
- Imágenes que son capturas de texto → extraer texto y escribirlo como texto LaTeX real
- Imágenes que son diagramas → SIEMPRE intentar recrear con TikZ si el resultado va a quedar bien y fiel al original (modelos de capas, flujos, jerarquías, tablas comparativas, estructuras de frames, topologías simples)
- Imágenes que son topologías MUY complejas (muchos dispositivos, conexiones cruzadas) o fotos reales → incluir con `\includegraphics` como último recurso
- Usar `\conceptbox{título}{contenido}` para definiciones clave
- Usar `\keybox{título}{contenido}` para datos importantes de examen

### Proceso para generar un resumen
1. Leer los `.txt` de `procesado/<materia>/texto/`
2. Ver las imágenes de `procesado/<materia>/imagenes/` para entender su contenido
3. Mapear cada imagen a su sección correcta (verificar número de sección visible en la imagen)
4. Generar el `.tex` con todo el contenido, TikZ donde corresponda, imágenes donde corresponda
5. NO compilar — el usuario lo hace

## Comandos Make disponibles
```
make setup                                    # Instala deps Python (una vez)
make procesar MATERIA=x                       # Extrae texto+imágenes
make procesar MATERIA=x ARCHIVOS="a.pdf"      # Solo archivos específicos
make pdf MATERIA=x                            # Compila .tex a PDF
make limpiar-resumenes MATERIA=x              # Borra resumenes de una materia
make limpiar-resumenes MATERIA=x ARCHIVO=y    # Borra un resumen específico
make limpiar MATERIA=x                        # Borra procesado de una materia
make help                                     # Muestra todos los comandos
```

## Materias
seguridad_e_higiene, sistemas_operativos_ii, arquitectura_de_computadores, cyberseguridad, portugues
