# Rama isotónica de calibración para las 560 unidades de la realización principal.
#
# Reutiliza el workflow base y las tres particiones internas de la rama sigmoid, de modo que
# sigmoid e isotónica solo difieren en la función de recalibración. Uso, desde la carpeta del proyecto:
#   source("R/complementos/calibracion_isotonica.R"); r <- ejecutar_isotonica(n_nucleos = 4)

source(file.path("R", "complementos", "comun.R"))
library(probably)

SALIDA_ISOTONICA <- file.path(COMPLEMENTARIOS, "calibracion_isotonica")

# ECE con diez intervalos uniformes, igual que la rama sigmoid.
ece_uniforme <- function(y, probabilidad, bins = 10) {
  indices <- pmin(floor(probabilidad * bins), bins - 1)
  sum(map_dbl(0:(bins - 1), function(b) {
    mascara <- indices == b
    if (!any(mascara)) return(0)
    mean(mascara) * abs(mean(y[mascara]) - mean(probabilidad[mascara]))
  }))
}

# Ajusta la rama isotónica de una unidad externa y la evalúa en su fold reservado.
#
# fila   : lista con una fila de unidades.csv (realización 0).
# datos  : datos de desarrollo con row_id (datos_desarrollo()).
# splits : particiones externas oficiales (splits.json).
# Devuelve una lista con las métricas de la unidad y las probabilidades isotónicas por cliente.
calibrar_unidad <- function(fila, datos, splits) {
  carpeta <- file.path(OFICIAL, chartr("\\", "/", fila$attempt_path))
  pred <- readr::read_csv(file.path(carpeta, "predictions.csv"), show_col_types = FALSE)
  guardada <- readr::read_csv(file.path(carpeta, "calibrated_predictions.csv"), show_col_types = FALSE)
  split <- splits[[fila$outer_fold + 1]]
  partes <- dividir_fold(datos, split)
  evaluacion <- partes$evaluacion[match(pred$row_id, partes$evaluacion$row_id), ]
  # Las particiones internas de calibración son las mismas que usó la rama sigmoid.
  info <- fromJSON(file.path(carpeta, "calibration_checkpoint.json"), simplifyVector = FALSE)$data$info
  particiones <- map(info$splits, function(registro) {
    calibracion <- match(unlist(registro$calibration_ids), partes$ajuste$row_id)
    stopifnot(!anyNA(calibracion))
    list(ajuste = setdiff(seq_len(nrow(partes$ajuste)), calibracion), calibracion = calibracion)
  })
  flujo <- flujo_oficial(fila)
  inicio <- Sys.time()
  # Scores fuera de muestra con las tres particiones internas (ensemble = FALSE).
  fuera <- map_dfr(particiones, function(p) {
    ajuste <- fit(flujo, select(partes$ajuste[p$ajuste, ], -row_id))
    tibble(Churn = partes$ajuste$Churn[p$calibracion],
           .pred_1 = predict(ajuste, partes$ajuste[p$calibracion, ], type = "prob")$.pred_1)
  })
  calibrador <- cal_estimate_isotonic(mutate(fuera, .pred_0 = 1 - .pred_1), truth = Churn,
                                      estimate = c(.pred_1, .pred_0))
  final <- fit(flujo, select(partes$ajuste, -row_id))   # el Pipeline base se reajusta con todo el entrenamiento externo
  segundos <- as.numeric(difftime(Sys.time(), inicio, units = "secs"))
  probabilidad <- predict(final, evaluacion, type = "prob") |>
    cal_apply(calibrador) |>
    pull(.pred_1)
  y <- as.integer(evaluacion$Churn == "1"); etiquetas <- as.integer(probabilidad >= 0.5)
  verdad <- factor(y, levels = c(1, 0)); prediccion <- factor(etiquetas, levels = c(1, 0))
  metricas <- tibble(unit_id = fila$unit_id, experiment_id = fila$experiment_id, model = fila$model,
                     balance = fila$balance, optimizer = fila$optimizer, outer_fold = fila$outer_fold,
                     iso_brier = mean((probabilidad - y)^2), iso_ece = ece_uniforme(y, probabilidad),
                     iso_accuracy = accuracy_vec(verdad, prediccion),
                     iso_precision_positive = precision_vec(verdad, prediccion),
                     iso_recall_positive = recall_vec(verdad, prediccion),
                     iso_f1_positive = f_meas_vec(verdad, prediccion),
                     iso_roc_auc = roc_auc_vec(verdad, probabilidad),
                     iso_distinct_values = n_distinct(probabilidad), iso_seconds = segundos)
  list(metricas = metricas,
       probabilidades = tibble(unit_id = fila$unit_id, row_id = pred$row_id, probability_isotonic = probabilidad))
}

# Calcula la rama isotónica para todas las unidades de la realización 0.
ejecutar_isotonica <- function(n_nucleos = 4, limite = NULL) {
  unidades <- readr::read_csv(file.path(ANALISIS, "unidades.csv"), show_col_types = FALSE)
  principal <- unidades |> filter(replicate == 0) |> arrange(experiment_id, outer_fold)
  if (!is.null(limite)) principal <- head(principal, limite)
  datos <- datos_desarrollo(); splits <- leer_splits()
  salida <- parallel::mclapply(seq_len(nrow(principal)), function(i) {
    calibrar_unidad(as.list(principal[i, ]), datos, splits)
  }, mc.cores = if (.Platform$OS.type == "windows") 1 else n_nucleos)
  list(metricas = map_dfr(salida, "metricas"), probabilidades = map_dfr(salida, "probabilidades"))
}

# Guarda los resultados con los mismos nombres de archivo que lee el capítulo de modelado.
guardar_isotonica <- function(resultado, sufijo = "") {
  dir.create(SALIDA_ISOTONICA, recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(resultado$metricas, file.path(SALIDA_ISOTONICA, paste0("unidades_isotonica", sufijo, ".csv")))
  readr::write_csv(resultado$probabilidades,
                   file.path(SALIDA_ISOTONICA, paste0("probabilidades_isotonica", sufijo, ".csv.gz")))
}
