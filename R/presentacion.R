# Presentación compartida de los capítulos de resultados (4 a 10): tablas, notas y estilo de figuras.
#
# Reproduce el formato de las tablas del libro (clase `eda-table`): título, buscador, orden por columna
# y números con formato en español (coma decimal, punto de miles, signo menos tipográfico). No modifica
# los valores de origen: solo cambia cómo se muestran.

suppressPackageStartupMessages({
  library(htmltools)
  library(jsonlite)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(patchwork)
})

AZUL <- "#1B4F72"; ACENTO <- "#06B6D4"; RIESGO <- "#E4572E"; GRIS <- "#8A9BA8"
CICLO <- c(AZUL, RIESGO, ACENTO, "#F4B183", "#5B6B7C", "#2E86AB", "#9B59B6")

NOMBRES <- c(
  knn = "kNN", naive_bayes = "Naive Bayes", logistic = "Logística", decision_tree = "Árbol de decisión",
  random_forest = "Random Forest", xgboost = "XGBoost", svm = "SVM", logistic_splines = "Logística con splines",
  hist_gb = "HistGB", lightgbm = "LightGBM", catboost = "CatBoost", RegionalMAPEM = "RegionalMAPEM",
  mapem_sin_prior = "MAP-EM sin prior", mapem_K1 = "Pesos globales (K = 1)",
  mapem_regiones_duras = "Regiones duras", promedio_simple = "Promedio simple",
  stacking_logistico = "Stacking logístico"
)
CONJUNTOS <- c(telco = "Telco", uci_563_iranian = "Iranian (UCI 563)", openml_40701_churn = "Churn (OpenML 40701)",
               openml_1112_kddcup09_churn = "KDDCup09 (OpenML 1112)", `4_conjuntos` = "Los 4 conjuntos",
               telco_holdout = "Telco, hold-out")

# Traduce claves con un diccionario; deja intactas las que no están.
nombre <- function(x, dic = NOMBRES) ifelse(x %in% names(dic), unname(dic[x]), x)

# Lectura de tablas versionadas (sin convertir textos en factores).
# Las columnas con True/False (como las escribe pandas) se leen como lógicas.
leer_csv <- function(ruta, ...) {
  d <- utils::read.csv(ruta, check.names = FALSE, stringsAsFactors = FALSE, encoding = "UTF-8", ...)
  for (col in names(d)) {
    v <- d[[col]]
    if (is.character(v) && length(v) > 0 && all(v %in% c("True", "False"))) d[[col]] <- v == "True"
  }
  d
}
leer_json <- function(ruta) jsonlite::fromJSON(ruta, simplifyVector = TRUE)

menos <- function(s) gsub("-", "−", s, fixed = TRUE)

# Número con coma decimal; notación científica para valores muy pequeños.
numero <- function(x, decimales = 4) {
  if (is.list(x)) x <- unlist(x)
  if (is.logical(x)) return(ifelse(is.na(x), "—", ifelse(x, "Sí", "No")))
  if (is.character(x)) return(ifelse(is.na(x), "—", x))
  if (is.integer(x)) {
    return(ifelse(is.na(x), "—", menos(formatC(x, format = "d", big.mark = "."))))
  }
  vapply(x, function(v) {
    if (is.na(v)) return("—")
    if (v != 0 && abs(v) < 10^(-decimales)) {
      return(menos(gsub(".", ",", formatC(v, format = "e", digits = 2), fixed = TRUE)))
    }
    s <- formatC(v, format = "f", digits = decimales, big.mark = "_")
    s <- gsub(".", ",", s, fixed = TRUE)
    menos(gsub("_", ".", s, fixed = TRUE))
  }, character(1))
}

valor_p <- function(p) {
  vapply(p, function(v) {
    if (is.na(v)) return("—")
    if (v == 0) return("< 1e−16")
    if (v >= 0.001) return(numero(v, 4))
    menos(gsub(".", ",", formatC(v, format = "e", digits = 2), fixed = TRUE))
  }, character(1))
}

# Media ± desviación estándar con el formato del libro.
media_de <- function(m, s, decimales = 4) paste0(numero(m, decimales), " ± ", numero(s, decimales))

.contador_res <- 0
.script_tabla <- "(function(){const root=document.getElementById('%s');
const body=root.querySelector('tbody'),input=root.querySelector('input');
input.addEventListener('input',()=>{for(const r of body.rows)r.hidden=!r.textContent.toLowerCase().includes(input.value.toLowerCase());});
root.querySelectorAll('thead th').forEach((h,i)=>{let asc=true;h.tabIndex=0;h.title='Ordenar columna';
const num=t=>Number(t.replaceAll('.','').replace(',','.').replace('−','-').split(' ')[0]);
const sort=()=>{const rows=Array.from(body.rows);rows.sort((a,b)=>{const x=a.cells[i].textContent,y=b.cells[i].textContent;
const nx=num(x),ny=num(y);const c=(Number.isFinite(nx)&&Number.isFinite(ny))?nx-ny:x.localeCompare(y,'es');return asc?c:-c;});
rows.forEach(r=>body.appendChild(r));asc=!asc;};h.addEventListener('click',sort);h.addEventListener('keydown',e=>{if(e.key==='Enter')sort();});});})();"

# Tabla HTML con el formato del libro (sin índice): título, buscador opcional, orden por columna y nota.
tabla <- function(datos, titulo, decimales = 4, columnas_p = character(0), nota = NULL, buscar = TRUE) {
  .contador_res <<- .contador_res + 1
  ident <- paste0("tabla-res-", .contador_res)
  datos <- as.data.frame(datos, check.names = FALSE, stringsAsFactors = FALSE)
  vista <- lapply(names(datos), function(col) {
    if (col %in% columnas_p) valor_p(datos[[col]]) else numero(datos[[col]], decimales)
  })
  celda <- function(v) {
    if (nchar(v) <= 26) tags$td(style = "white-space:nowrap !important", v) else tags$td(style = "min-width:190px", v)
  }
  filas <- lapply(seq_len(nrow(datos)), function(i) tags$tr(lapply(vista, function(col) celda(col[[i]]))))
  entrada <- if (buscar) tags$input(`aria-label` = paste("Buscar en", titulo), placeholder = "Buscar en esta tabla…") else
    tags$input(hidden = NA)
  browsable(tagList(
    div(class = "eda-table", id = ident,
        span(class = "eda-table-title", titulo), entrada,
        tags$table(class = "dataframe", tags$thead(tags$tr(lapply(names(datos), tags$th))), tags$tbody(filas)),
        if (!is.null(nota)) span(class = "eda-table-note", nota)),
    tags$script(HTML(sprintf(.script_tabla, ident)))
  ))
}

# Recuadro de lectura (tc-note); tipo "" (informativo), "ok" o "warn".
nota <- function(texto_html, tipo = "") browsable(div(class = trimws(paste("tc-note", tipo)), HTML(texto_html)))

# Estilo de las figuras: títulos en azul y en negrita, rejilla suave y fondo blanco.
tema_libro <- function(base = 12) {
  theme_minimal(base_size = base, base_family = "sans") +
    theme(plot.title = element_text(face = "bold", colour = AZUL, size = rel(1.05)),
          plot.subtitle = element_text(colour = "#243B53"),
          axis.title = element_text(colour = "#243B53"), axis.text = element_text(colour = "#334E68"),
          axis.line = element_line(colour = "#9FB3C8", linewidth = 0.4),
          panel.grid.major = element_line(colour = "#E4EBF0", linewidth = 0.5), panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white", colour = NA),
          panel.background = element_rect(fill = "white", colour = NA),
          legend.key = element_blank(), legend.title = element_text(colour = "#243B53"),
          plot.title.position = "plot")
}

titulo_figura <- function(texto) {
  plot_annotation(title = texto, theme = theme(plot.title = element_text(face = "bold", colour = AZUL, size = 13),
                                               plot.background = element_rect(fill = "white", colour = NA)))
}

# Formato de ejes en español.
eje_es <- function(decimales = NULL) {
  function(x) {
    if (is.null(decimales)) {
      s <- format(x, trim = TRUE, scientific = FALSE, drop0trailing = TRUE, big.mark = "_")
      s <- gsub(".", ",", s, fixed = TRUE); s <- gsub("_", ".", s, fixed = TRUE)
    } else s <- numero(x, decimales)
    menos(s)
  }
}

# Orden con desempate fijo. pandas ordena con un algoritmo no estable, así que en los empates exactos el orden
# publicado no sigue el de los datos; `empates` lista las claves en el orden en que aparecen en el Jupyter Book.
ordenar <- function(valores, claves, empates, decreciente = FALSE) {
  order(if (decreciente) -valores else valores, match(claves, empates))
}
