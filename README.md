# Telco Customer Churn — Bookdown

Versión en Bookdown (R) del Jupyter Book [Telco_Churn_JBook](https://nataly-cardenas.github.io/Telco_Churn_Bookdown/eda.html). El libro tiene el mismo contenido, las mismas secciones, interpretaciones y el mismo diseño (incluido el modo oscuro por defecto). El código de los capítulos está escrito en R y se muestra plegado con "Show code cell source"; al construir el libro, ese código se ejecuta y genera todas las tablas y gráficas.

## Estructura

```text
Telco_Churn_Bookdown/
│
├── .github/workflows/book.yml   # Construye el libro y lo publica en GitHub Pages al actualizar main
├── index.Rmd                    # Portada e introducción
├── 01-eda.Rmd                   # Análisis exploratorio de datos
├── 02-preprocesamiento.Rmd      # Preprocesamiento de datos
├── 03-modelado-avanzado.Rmd     # Modelamiento avanzado
├── 04-codigo-experimento.Rmd    # Apéndice: código del entrenamiento de las 112 configuraciones
├── 05-paper.Rmd                 # Paper
├── 06-guia-repositorio.Rmd      # Guía del repositorio
├── R/salidas.R                  # Opciones de knitr (ejecución del código) y código plegable
├── R/estilos.R                  # Estilos, barra superior y pie de página del libro
├── R/complementos/              # Calibración isotónica, Successive Halving y optimización computacional
├── WA_Fn-UseC_-Telco-Customer-Churn.csv   # Datos originales (Telco Customer Churn, IBM)
├── train_index.csv, test_index.csv       # Índices de la partición 80/20 del proyecto
├── resultados_modelado/         # Resultados guardados del experimento de 112 configuraciones
├── Imagenes/, paper/            # Logo, favicon, PDF y figuras del paper
├── _bookdown.yml, _output.yml   # Configuración de Bookdown
└── construir_libro.R            # Construye el libro en _book/
```

Al construir el libro se ejecuta el código R de cada capítulo. El EDA y el preprocesamiento parten del CSV original. El modelado avanzado trabaja sobre los resultados guardados del experimento en `resultados_modelado/` (las 112 configuraciones con validación cruzada anidada tardan varios días en entrenarse, por eso no se vuelven a entrenar en cada construcción).

El apéndice del código del experimento reproduce tal cual, igual que en el Jupyter Book, las celdas originales que entrenaron las 112 configuraciones (guardadas en `source_snapshot.json`); sus celdas no se ejecutan al construir el libro.

## Ver el libro en tu computador

Se necesita R (4.4 o superior). RStudio ya incluye Pandoc; si no usas RStudio, instala también [Pandoc](https://pandoc.org/installing.html).

```r
install.packages(c("bookdown", "rmarkdown", "knitr", "htmltools", "bslib", "downlit", "xml2",
                   "readr", "dplyr", "tidyr", "purrr", "stringr", "tibble", "plotly", "digest", "moments",
                   "jsonlite", "ggplot2", "patchwork", "tidymodels", "glmnet", "kableExtra", "shapviz"))
```

Desde la carpeta del proyecto:

```bash
Rscript construir_libro.R
```

Luego abre `_book/index.html` en el navegador.

## Publicación

Al actualizar la rama `main`, GitHub Actions construye el libro y lo publica en GitHub Pages. En la configuración del repositorio, en Settings → Pages, la opción Source debe estar en "GitHub Actions".
