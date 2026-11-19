# Predicción de abandono de clientes en Telco Customer Churn (Bookdown)

[![R 4.4](https://img.shields.io/badge/R-4.4-276DC3?style=for-the-badge&logo=r&logoColor=white)](https://www.r-project.org/)
[![Bookdown](https://img.shields.io/badge/Bookdown-bs4__book-1B4F72?style=for-the-badge&logo=rstudioide&logoColor=white)](https://nataly-cardenas.github.io/Telco_Churn_Bookdown/)
[![Dataset](https://img.shields.io/badge/Dataset-Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24268653.svg)](https://doi.org/10.5281/zenodo.24268653)

Este repositorio contiene el libro del proyecto de Machine Learning sobre el abandono de clientes (*churn*) de una
empresa de telecomunicaciones, escrito en R con Bookdown. Es la edición en R del
[Jupyter Book del proyecto](https://nataly-cardenas.github.io/Telco_Churn_JBook/): cada capítulo es un archivo R
Markdown cuyo código se ejecuta al construir el libro y genera todas las tablas y gráficas.

- **Libro en línea:** <https://nataly-cardenas.github.io/Telco_Churn_Bookdown/>
- **Dashboard:** <https://telco-churn-dashboard-hom3.onrender.com/>
- **Repositorio de los experimentos (Python):** [Telco_Churn_JBook](https://github.com/Nataly-Cardenas/Telco_Churn_JBook)

---

## De qué trata el proyecto

El conjunto público Telco Customer Churn de IBM describe a 7043 clientes con 21 columnas: servicios contratados, datos
de la cuenta, datos demográficos y si el cliente abandonó el servicio en el último mes (26,5 % lo hizo). El objetivo es
identificar a los clientes con mayor riesgo de abandono y los factores asociados, sin generar un exceso de falsas
alertas. El trabajo tiene dos etapas.

**1. Comparación de modelos de referencia.** Tras un análisis exploratorio hecho solo con el conjunto de entrenamiento y
un preprocesamiento sin fuga de información, se evaluaron 112 configuraciones (7 modelos, 4 técnicas de balanceo y 4
métodos de optimización de hiperparámetros) con validación cruzada anidada. Random Forest y XGBoost con SMOTE
alcanzaron el mayor F1 de la clase de abandono (0,638), seguidos de la regresión logística (0,634), sin diferencias
estadísticamente detectables entre ellos.

**2. Modelo propio: RegionalMAPEM.** Es una regla para combinar clasificadores calibrados con pesos que cambian según la
región del espacio de clientes, estimados por máxima posterior con EM y un prior de Dirichlet hacia los pesos globales.
Se comparó con 11 benchmarks bajo un protocolo pre-registrado en Telco y en tres conjuntos adicionales. Empata con el
mejor benchmark, la logística con splines (log-loss de 0,41127 frente a 0,41130), supera a 7 de los 11 benchmarks y no
cumple la definición de superioridad.

---

## Contenido del libro

| Archivo | Capítulo |
|---|---|
| `index.Rmd` | Portada, resumen ejecutivo, introducción, marco teórico y diccionario de variables |
| `01-correcciones.Rmd` | Trazabilidad de correcciones y auditoría de fuga de información |
| `02-eda.Rmd` | Análisis exploratorio de datos |
| `03-preprocesamiento.Rmd` | Preprocesamiento y modelo base |
| `04-modelado-avanzado.Rmd` | Modelado avanzado: las 112 configuraciones, pruebas estadísticas, calibración e interpretabilidad |
| `05-literatura.Rmd` | Revisión de literatura y novedad |
| `06-modelo-propio.Rmd` | Modelo propio: ponderación por regiones con MAP-EM |
| `07-validacion.Rmd` | Protocolo y validación estadística |
| `08-evaluacion-ampliada.Rmd` | Evaluación ampliada y robustez |
| `09-dashboard.Rmd` | Dashboard y despliegue |
| `10-conclusiones.Rmd` | Conclusiones y limitaciones |
| `11-reproducibilidad.Rmd` | Reproducibilidad y bibliografía |
| `12-codigo-experimento.Rmd` | Apéndice: código del entrenamiento de las 112 configuraciones |
| `13-paper.Rmd` | Apéndice: versión web del paper |
| `14-guia-repositorio.Rmd` | Apéndice: guía del repositorio |

---

## Estructura del repositorio

```text
Telco_Churn_Bookdown/
│
├── index.Rmd, 01-...Rmd a 14-...Rmd     # Capítulos del libro (ver la tabla anterior)
├── _bookdown.yml, _output.yml           # Configuración e índice del libro
├── construir_libro.R                    # Construye el libro en _book/
├── references.bib                       # Bibliografía
│
├── R/salidas.R                          # Opciones de knitr y código plegable
├── R/estilos.R                          # Estilos, barra superior y pie de página
├── R/presentacion.R                     # Formato de tablas y figuras de los capítulos de resultados
├── R/complementos/                      # Calibración isotónica, Successive Halving y optimización computacional
│
├── WA_Fn-UseC_-Telco-Customer-Churn.csv # Datos originales (IBM)
├── train_index.csv, test_index.csv      # Partición 80/20 (desarrollo y hold-out)
├── resultados_modelado/                 # Resultados guardados de las 112 configuraciones
├── experiments/                         # Tablas de la evaluación del modelo propio y de la revisión de literatura
├── resultados_modelo_propio/            # Salidas guardadas del piloto de RegionalMAPEM
├── Imagenes/, paper/                    # Logo, capturas del dashboard, figuras y papers en PDF
│
└── .github/workflows/book.yml           # Construye y publica el libro en GitHub Pages
```

El análisis exploratorio y el preprocesamiento parten del CSV original. Los demás capítulos trabajan sobre los
resultados guardados de los experimentos (`resultados_modelado/`, `experiments/` y `resultados_modelo_propio/`), porque
volver a entrenar todos los modelos toma varios días; el código R los lee y genera con ellos las tablas y las gráficas.
El código que entrenó los modelos está en el repositorio
[Telco_Churn_JBook](https://github.com/Nataly-Cardenas/Telco_Churn_JBook).

---

## Construir el libro en tu computador

Se necesita R 4.4 o superior. RStudio ya incluye Pandoc; si no usas RStudio, instala también
[Pandoc](https://pandoc.org/installing.html).

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

Al actualizar la rama `main`, GitHub Actions construye el libro y lo publica en GitHub Pages (en Settings, Pages, la
opción Source debe estar en "GitHub Actions").

---

## Cómo citar

Rivera Figueredo, L. S. y Cárdenas Izaquita, N. A. (2026). *Predicción de abandono de clientes en Telco Customer Churn
y modelo RegionalMAPEM* (v1.0.0) [Software]. Zenodo. https://doi.org/10.5281/zenodo.24268653

---

## Autoras

- Laura S. Rivera Figueredo (`sriveral@uninorte.edu.co`)
- Natalý A. Cárdenas Izaquita (`nizaquita@uninorte.edu.co`)

Departamento de Matemáticas, Física y Ciencia de Datos, Universidad del Norte, Barranquilla, Colombia.
