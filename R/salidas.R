# Configuración común del libro.
#
# El código de cada capítulo se muestra plegado, como en el Jupyter Book
# ("Show code cell source"), y se ejecuta en R al construir el libro: las tablas,
# gráficas y resultados que aparecen debajo de cada bloque los genera ese código.

knitr::opts_chunk$set(eval = TRUE, echo = TRUE, comment = NA, message = FALSE, warning = FALSE,
                      results = "hold", fig.show = "hold")

local({
  apertura <- '\n\n<details class="code-fold"><summary>Show code cell source</summary>\n\n'
  cierre <- '\n\n</details>\n\n'
  fuente_original <- knitr::knit_hooks$get("source")
  knitr::knit_hooks$set(source = function(x, options) {
    codigo <- fuente_original(x, options)
    if (isFALSE(options$echo)) return(codigo)
    paste0(apertura, codigo, cierre)
  })
  # knitr llama al gancho "source" por cada expresión: se unen los bloques consecutivos
  # para que cada celda tenga un único "Show code cell source" con todo su código.
  documento_original <- knitr::knit_hooks$get("document")
  knitr::knit_hooks$set(document = function(x) {
    x <- paste(x, collapse = "\n")
    x <- gsub("\n```\\s*</details>\\s*<details class=\"code-fold\"><summary>Show code cell source</summary>\\s*```r\n",
              "\n", x, perl = TRUE)
    documento_original(x)
  })
})
