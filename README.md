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
├── 04-codigo-experimento.Rmd    # Apéndice: código del entrenamiento de las 112 configuraciones
├── 05-paper.Rmd                 # Paper
├── 06-guia-repositorio.Rmd      # Guía del repositorio
├── R/salidas.R                  # Opciones de knitr (ejecución del código) y código plegable
├── WA_Fn-UseC_-Telco-Customer-Churn.csv   # Datos originales (Telco Customer Churn, IBM)
├── train_index.csv, test_index.csv       # Índices de la partición 80/20 del proyecto
├── resultados_modelado/         # Resultados guardados del experimento de 112 configuraciones
├── complementos/                # Código Python de los experimentos complementarios (se muestra en el libro)
├── style/                       # Estilos y barra superior del libro
├── Imagenes/, paper/            # Logo, favicon, PDF y figuras del paper
├── _bookdown.yml, _output.yml   # Configuración de Bookdown
└── construir_libro.R            # Construye el libro en _book/
```

Al construir el libro se ejecuta el código R de cada capítulo: todas las tablas, gráficas y resultados que se publican los genera R en ese momento a partir de los datos. El EDA y el preprocesamiento parten del CSV original; el modelado avanzado lee los resultados guardados del experimento en `resultados_modelado/` (las 112 configuraciones se entrenaron en Python y no se vuelven a entrenar) y, mediante `reticulate`, carga los pipelines finales de scikit-learn para las explicaciones SHAP. `reticulate` crea automáticamente, con `uv`, un entorno de Python con las versiones del experimento.

El apéndice del código del experimento es la excepción al código en R: igual que en el Jupyter Book, reproduce tal cual las celdas de Python que entrenaron las 112 configuraciones (guardadas en `source_snapshot.json`), porque su objetivo es mostrar el código exacto que se ejecutó. En el modelado avanzado, las funciones de los experimentos complementarios (`complementos/`, también en Python) se muestran del mismo modo.

## Ver el libro en tu computador

Se necesita R (4.1 o superior). RStudio ya incluye Pandoc; si no usas RStudio, instala también [Pandoc](https://pandoc.org/installing.html).

```r
install.packages(c("bookdown", "rmarkdown", "knitr", "htmltools", "bslib", "downlit", "xml2",
                   "readr", "dplyr", "tidyr", "purrr", "stringr", "tibble", "plotly", "digest", "moments",
                   "jsonlite", "ggplot2", "patchwork", "tidymodels", "glmnet", "kableExtra", "reticulate", "shapviz"))
```

Desde la carpeta del proyecto:

```bash
Rscript construir_libro.R
```

Luego abre `_book/index.html` en el navegador.

## Publicación

Al actualizar la rama `main`, GitHub Actions construye el libro y lo publica en GitHub Pages. En la configuración del repositorio, en Settings → Pages, la opción Source debe estar en "GitHub Actions".
