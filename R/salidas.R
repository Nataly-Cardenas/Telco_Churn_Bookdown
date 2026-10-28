# Configuración común del libro.
#
# El código de cada capítulo se muestra plegado, como en el Jupyter Book
# ("Show code cell source"), y no se ejecuta al construir el libro: las tablas,
# gráficas e interpretaciones son las mismas del Jupyter Book y se insertan desde
# la carpeta salidas/, igual que el Jupyter Book publica las salidas guardadas en
# los notebooks (execute_notebooks: off).

knitr::opts_chunk$set(eval = FALSE, echo = TRUE, comment = NA)

local({
  fuente_original <- knitr::knit_hooks$get("source")
  knitr::knit_hooks$set(source = function(x, options) {
    codigo <- fuente_original(x, options)
    if (isFALSE(options$echo)) return(codigo)
    paste0('\n\n<details class="code-fold"><summary>Show code cell source</summary>\n\n',
           codigo, '\n\n</details>\n\n')
  })
})

# Inserta la salida guardada de una celda (tablas HTML, figuras Plotly o imágenes).
salida <- function(id) {
  html <- paste(readLines(file.path("salidas", paste0(id, ".html")), encoding = "UTF-8", warn = FALSE),
                collapse = "\n")
  imagenes <- regmatches(html, gregexpr('src="salidas/img/[^"]+"', html))[[1]]
  for (img in unique(imagenes)) {
    ruta <- sub('^src="(.*)"$', "\\1", img)
    html <- gsub(img, paste0('src="', knitr::image_uri(ruta), '"'), html, fixed = TRUE)
  }
  knitr::asis_output(htmltools::htmlPreserve(paste0('<div class="cell-output">', html, '</div>')))
}
