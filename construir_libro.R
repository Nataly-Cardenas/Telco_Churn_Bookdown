# Construye el libro en la carpeta _book/.
# Uso (desde la carpeta del proyecto):  Rscript construir_libro.R

bookdown::render_book("index.Rmd", quiet = TRUE)

# El paper en PDF se publica en la raíz del sitio, igual que en el Jupyter Book
# (botón "Descargar paper (PDF)" y visor de la pestaña "Versión PDF").
file.copy("paper/paper.pdf", "_book/paper.pdf", overwrite = TRUE)
file.create("_book/.nojekyll")

# Librería Plotly de las gráficas interactivas (se carga como archivo aparte).
dir.create("_book/salidas/js", recursive = TRUE, showWarnings = FALSE)
file.copy("salidas/js/plotly.min.js", "_book/salidas/js/plotly.min.js", overwrite = TRUE)

message("Libro listo: abre _book/index.html en el navegador.")
