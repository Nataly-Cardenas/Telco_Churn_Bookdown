# Successive Halving dentro de la validación cruzada anidada oficial.
#
# Para Random Forest, XGBoost y SVM con SMOTE se compara, fold externo por fold externo, una
# búsqueda aleatoria a fidelidad completa (24 candidatos) con Successive Halving (27 candidatos,
# factor 3). Ambas usan el mismo Pipeline, las mismas semillas del modelo y del remuestreo que la
# unidad oficial, los mismos tres folds internos y el mismo objetivo (F1 de la clase abandono).
# Uso: source("R/complementos/multifidelidad.R"); r <- ejecutar_multifidelidad(n_nucleos = 4)

source(file.path("R", "complementos", "comun.R"))

SALIDA_MULTIFIDELIDAD <- file.path(COMPLEMENTARIOS, "multifidelidad")
FACTOR <- 3
CANDIDATOS_SH <- 27          # 27 → 9 → 3 → 1 con factor 3
CANDIDATOS_COMPLETOS <- 24   # mismo presupuesto de candidatos que la corrida oficial

# Fidelidad: número de árboles en los ensambles y tamaño de muestra en SVM.
# Cada espacio es una función que genera un candidato aleatorio con el generador ya sembrado.
ESPACIOS <- list(
  random_forest = list(recurso = "n_estimators", minimo = 12, maximo = 324, espacio = function() list(
    max_depth = sample(list(4, 6, 8, 10, 12, 16, NULL), 1)[[1]], min_samples_leaf = sample(1:20, 1),
    max_features = runif(1, 0.2, 0.8), criterion = sample(c("gini", "entropy"), 1))),
  xgboost = list(recurso = "n_estimators", minimo = 12, maximo = 324, espacio = function() list(
    max_depth = sample(2:6, 1), learning_rate = exp(runif(1, log(0.01), log(0.3))),
    subsample = runif(1, 0.6, 1), colsample_bytree = runif(1, 0.6, 1),
    min_child_weight = exp(runif(1, log(1), log(10))))),
  svm = list(recurso = "n_samples", minimo = 111, maximo = NULL, espacio = function() list(
    C = exp(runif(1, log(1e-2), log(1e3))), gamma = exp(runif(1, log(1e-3), log(1))))))

# Reconstruye los tres folds internos oficiales de un fold externo (posiciones dentro del ajuste).
plan_interno <- function(split, ajuste) {
  map(split$inner, function(interno) {
    list(ajuste = match(unlist(interno$fit_ids), ajuste$row_id),
         validacion = match(unlist(interno$eval_ids), ajuste$row_id))
  })
}

# F1 interno medio de un candidato con un recurso dado (árboles o filas de entrenamiento).
evaluar_candidato <- function(modelo, parametros, recurso, valor, ajuste, plan, semillas) {
  if (recurso == "n_estimators") parametros$n_estimators <- valor
  mean(map_dbl(plan, function(p) {
    filas <- p$ajuste
    if (recurso == "n_samples") { set.seed(semillas$modelo); filas <- sample(filas, min(valor, length(filas))) }
    flujo <- crear_flujo(modelo, "smote", parametros, semillas$modelo, semillas$balanceo)
    entrenado <- fit(flujo, select(ajuste[filas, ], -row_id))
    etiquetas <- predict(entrenado, ajuste[p$validacion, ])$.pred_class
    f_meas_vec(ajuste$Churn[p$validacion], etiquetas)
  }))
}

# Ajustes equivalentes a fidelidad completa: suma de recurso / recurso máximo por ajuste.
costo_relativo <- function(recursos, maximo) sum(recursos / maximo)

# Ejecuta SH y Random completo en un fold externo y evalúa ambos en el fold reservado.
evaluar_fold <- function(modelo, fold) {
  datos <- datos_desarrollo(); split <- leer_splits()[[fold + 1]]
  partes <- dividir_fold(datos, split)
  fila <- unidad_oficial(paste0(modelo, "__smote__random"), fold)
  semillas <- list(modelo = semilla_r(fila$model_seed), balanceo = semilla_r(fila$sampler_seed))
  plan <- plan_interno(split, partes$ajuste)
  spec <- ESPACIOS[[modelo]]
  maximo <- spec$maximo %||% min(map_int(plan, ~ length(.x$ajuste)))
  semilla <- as.integer(digest::digest2int(paste(SEMILLA_GLOBAL, 7, fold, match(modelo, names(ESPACIOS)) - 1)))
  map_dfr(c("successive_halving", "random_completo"), function(metodo) {
    set.seed(semilla)
    inicio <- Sys.time()
    if (metodo == "successive_halving") {
      candidatos <- map(seq_len(CANDIDATOS_SH), ~ spec$espacio())
      registro <- tibble(); ronda <- 0; valor <- spec$minimo; vivos <- seq_along(candidatos)
      repeat {
        puntajes <- map_dbl(vivos, ~ evaluar_candidato(modelo, candidatos[[.x]], spec$recurso, valor,
                                                       partes$ajuste, plan, semillas))
        registro <- bind_rows(registro, tibble(iter = ronda, candidato = vivos, recurso = valor, score = puntajes))
        if (length(vivos) <= 1 || valor >= maximo) break
        vivos <- vivos[order(-puntajes)][seq_len(max(1, length(vivos) %/% FACTOR))]
        ronda <- ronda + 1; valor <- min(valor * FACTOR, maximo)
      }
      ultima <- filter(registro, iter == max(iter)) |> slice_max(score, n = 1, with_ties = FALSE)
      mejor <- candidatos[[ultima$candidato]]; recurso_final <- ultima$recurso
      # Concordancia entre rondas: candidatos evaluados en la ronda k y en la k + 1.
      pares <- map_dbl(seq_len(max(registro$iter)) - 1, function(k) {
        comun <- inner_join(filter(registro, iter == k), filter(registro, iter == k + 1), by = "candidato")
        if (nrow(comun) >= 3) cor(comun$score.x, comun$score.y, method = "spearman") else NA_real_
      })
      rangos <- if (all(is.na(pares))) NA_real_ else mean(pares, na.rm = TRUE)
      recursos <- registro$recurso
    } else {
      candidatos <- map(seq_len(CANDIDATOS_COMPLETOS), ~ spec$espacio())
      puntajes <- map_dbl(candidatos, ~ evaluar_candidato(modelo, .x, spec$recurso, maximo,
                                                          partes$ajuste, plan, semillas))
      registro <- tibble(iter = 0, candidato = seq_along(candidatos), recurso = maximo, score = puntajes)
      mejor <- candidatos[[which.max(puntajes)]]; recurso_final <- maximo; rangos <- NA_real_
      recursos <- registro$recurso
    }
    if (spec$recurso == "n_estimators") mejor$n_estimators <- recurso_final
    final <- fit(crear_flujo(modelo, "smote", mejor, semillas$modelo, semillas$balanceo), select(partes$ajuste, -row_id))
    segundos <- as.numeric(difftime(Sys.time(), inicio, units = "secs"))
    probabilidades <- predict(final, partes$evaluacion, type = "prob")$.pred_1
    etiquetas <- predict(final, partes$evaluacion)$.pred_class
    externas <- metricas_basicas(partes$evaluacion$Churn, etiquetas, probabilidades)
    tibble(model = modelo, outer_fold = fold, method = metodo, search_seconds = segundos,
           candidates = n_distinct(registro$candidato), inner_fits = nrow(registro) * length(plan),
           full_fidelity_fit_equivalents = costo_relativo(recursos, maximo) * length(plan),
           best_inner_f1 = max(filter(registro, iter == max(iter))$score),
           outer_f1 = externas[["f1"]], outer_auc = externas[["auc"]], rounds = max(registro$iter) + 1,
           resource_name = spec$recurso, max_resource = maximo, final_resource = recurso_final,
           rung_spearman = rangos, best_params = toJSON(mejor, auto_unbox = TRUE), seed = semilla)
  })
}

# Recorre las tres familias y los cinco folds externos de la realización 0.
ejecutar_multifidelidad <- function(n_nucleos = 4) {
  tareas <- expand.grid(modelo = names(ESPACIOS), fold = 0:4, stringsAsFactors = FALSE)
  salida <- parallel::mclapply(seq_len(nrow(tareas)), function(i) evaluar_fold(tareas$modelo[i], tareas$fold[i]),
                               mc.cores = if (.Platform$OS.type == "windows") 1 else n_nucleos)
  bind_rows(salida)
}

# Guarda el resultado con el nombre de archivo que lee el capítulo de modelado.
guardar_multifidelidad <- function(resultado) {
  dir.create(SALIDA_MULTIFIDELIDAD, recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(resultado, file.path(SALIDA_MULTIFIDELIDAD, "multifidelidad_por_fold.csv"))
}
