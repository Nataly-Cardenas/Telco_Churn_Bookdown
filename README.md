# Telco Customer Churn — Bookdown

Versión en Bookdown (R) del Jupyter Book [Telco_Churn_JBook](https://github.com/Nataly-Cardenas/Telco_Churn_JBook). El libro tiene el mismo contenido, las mismas tablas, gráficas e interpretaciones, y el mismo diseño (incluido el modo oscuro por defecto); el código de cada capítulo está escrito en R y se muestra plegado con "Show code cell source".

## Estructura

```text
Telco_Churn_Bookdown/
│
├── .github/workflows/book.yml   # Publica el libro en GitHub Pages al actualizar main
├── index.Rmd                    # Portada e introducción
├── 01-eda.Rmd                   # Análisis exploratorio de datos
├── 02-preprocesamiento.Rmd      # Preprocesamiento de datos
├── 03-modelado-avanzado.Rmd     # Modelamiento avanzado
├── 04-paper.Rmd                 # Paper
├── 05-guia-repositorio.Rmd      # Guía del repositorio
├── R/salidas.R                  # Código plegable e inserción de las salidas guardadas
├── salidas/                     # Salidas del Jupyter Book (tablas, figuras Plotly e imágenes)
├── style/                       # Estilos y barra superior del libro
├── Imagenes/, paper/            # Logo, favicon, PDF y figuras del paper
├── _bookdown.yml, _output.yml   # Configuración de Bookdown
└── construir_libro.R            # Construye el libro en _book/
```

Igual que el Jupyter Book (que se publica con `execute_notebooks: off`), el libro no vuelve a ejecutar los análisis al construirse: los bloques de código R tienen `eval = FALSE` y las salidas se insertan desde `salidas/`.

## Ver el libro en tu computador

Se necesita R (4.1 o superior). RStudio ya incluye Pandoc; si no usas RStudio, instala también [Pandoc](https://pandoc.org/installing.html).

```r
install.packages(c("bookdown", "rmarkdown", "knitr", "htmltools", "bslib", "downlit", "xml2"))
```

Desde la carpeta del proyecto:

```bash
Rscript construir_libro.R
```

Luego abre `_book/index.html` en el navegador.

## Publicación

Al actualizar la rama `main`, GitHub Actions construye el libro y lo publica en GitHub Pages. En la configuración del repositorio, en Settings → Pages, la opción Source debe estar en "GitHub Actions".
