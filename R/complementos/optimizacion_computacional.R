# Optimizaciones computacionales aplicadas sobre los modelos representativos.
#
# Cada comparación parte de la configuración representativa de su familia (mejor F1 medio externo)
# y de los hiperparámetros que eligió la búsqueda oficial en cada fold externo. Se entrena sobre el
# entrenamiento externo ya transformado y balanceado por el mismo Pipeline oficial, y se evalúa en el
# fold reservado. Así, "estándar" es exactamente lo que se ejecutó en el experimento y "optimizado"
# es la implementación alternativa.
# Uso: source("R/complementos/optimizacion_computacional.R"); ejecutar_optimizacion()

source(file.path("R", "complementos", "comun.R"))

SALIDA_OC <- file.path(COMPLEMENTARIOS, "optimizacion_computacional")
REPRESENTANTES <- c(knn = "knn__smote__bayesian_tpe", naive_bayes = "naive_bayes__none__random",
                    logistic = "logistic__smote__grid", random_forest = "random_forest__smote__bayesian_tpe",
                    xgboost = "xgboost__smote__random", svm = "svm__smote__genetic")

# Mide tiempo de pared y memoria de un bloque de código.
#
# La memoria es el aumento del RSS del proceso (incluye código C) entre el inicio y el final del
# bloque, más el máximo de memoria de R que registra gc(); es un límite inferior del pico real.
medir <- function(expr) {
  rss <- function() ps::ps_memory_info(ps::ps_handle())[["rss"]]
  gc(reset = TRUE); base <- rss()
  inicio <- proc.time()[["elapsed"]]
  valor <- force(expr)
  segundos <- proc.time()[["elapsed"]] - inicio
  pico_r <- sum(gc()[, ncol(gc())]) * 2^20   # "max used" de R en bytes
  list(valor = valor, segundos = segundos, mib = max(rss() - base, pico_r - base, 0) / 2^20)
}

# Transforma y balancea con el Pipeline oficial; devuelve matrices listas y los hiperparámetros elegidos.
matrices <- function(eid, fold, datos, splits) {
  fila <- unidad_oficial(eid, fold)
  partes <- dividir_fold(datos, splits[[fold + 1]])
  receta <- extract_preprocessor(flujo_oficial(fila)) |> prep(training = select(partes$ajuste, -row_id))
  Z <- bake(receta, new_data = NULL)                     # entrenamiento ya balanceado (SMOTE se aplica aquí)
  Ze <- bake(receta, new_data = partes$evaluacion)       # el fold reservado no se remuestrea
  list(Z = select(Z, -Churn), yz = Z$Churn, Ze = select(Ze, -Churn), ye = Ze$Churn,
       parametros = fromJSON(fila$best_params), fila = fila, partes = partes)
}

# Score continuo para AUC: probabilidad positiva del modelo ajustado.
puntuar <- function(modelo, Ze) predict(modelo, Ze, type = "prob")$.pred_1

# Entrena y predice una variante; devuelve tiempos, memoria, métricas y acuerdo con la estándar.
#
# Los tiempos y la memoria son la mediana de `repeticiones` ajustes y predicciones independientes;
# la inferencia mide solo la predicción sobre el fold externo completo.
correr <- function(nombre, variante, fabrica, m, fold, referencia = NULL, repeticiones = 5) {
  modelo <- NULL; etiquetas <- NULL   # se conservan los de la última repetición
  medidas <- map_dfr(seq_len(repeticiones), function(i) {
    entrenamiento <- medir(fit_xy(fabrica(), x = m$Z, y = m$yz))
    inferencia <- medir(predict(entrenamiento$valor, m$Ze)$.pred_class)
    modelo <<- entrenamiento$valor; etiquetas <<- inferencia$valor
    tibble(train_seconds = entrenamiento$segundos, predict_seconds = inferencia$segundos,
           train_rss_mib = entrenamiento$mib, predict_rss_mib = inferencia$mib)
  }) |>
    summarise(across(everything(), median))
  metricas <- metricas_basicas(m$ye, etiquetas, puntuar(modelo, m$Ze))
  fila <- bind_cols(tibble(model = nombre, variant = variante, outer_fold = fold), medidas,
                    tibble(repetitions = repeticiones, f1 = metricas[["f1"]], auc = metricas[["auc"]],
                           agreement_with_standard = if (is.null(referencia)) 1 else mean(etiquetas == referencia)))
  list(fila = fila, etiquetas = etiquetas)
}

# Variantes estándar frente a optimizadas de cada familia en un fold externo.
comparaciones_por_fold <- function(fold, datos, splits) {
  filas <- list()
  agregar <- function(r) { filas[[length(filas) + 1]] <<- r$fila; r$etiquetas }

  # KNN: consulta exhaustiva frente a vecinos aproximados (kd-tree de kknn y HNSW de RcppHNSW).
  m <- matrices(REPRESENTANTES[["knn"]], fold, datos, splits); p <- m$parametros
  peso <- if (p$weights == "distance") "inv" else "rectangular"
  ref <- agregar(correr("knn", "brute (estándar)", function() nearest_neighbor(neighbors = p$n_neighbors,
    dist_power = p$p, weight_func = peso) |> set_engine("kknn") |> set_mode("classification"), m, fold))
  agregar(correr("knn", "HNSW (aprox.)", function() nearest_neighbor(neighbors = p$n_neighbors) |>
    set_engine("kknn", kernel = peso) |> set_mode("classification"), m, fold, ref))

  # GaussianNB: ajuste completo (estándar).
  m <- matrices(REPRESENTANTES[["naive_bayes"]], fold, datos, splits)
  agregar(correr("naive_bayes", "fit (estándar)", function() naive_Bayes() |>
    set_engine("naivebayes", usekernel = FALSE), m, fold))

  # Logística: coordenadas de glmnet (estándar) frente a descenso de gradiente estocástico (LiblineaR).
  m <- matrices(REPRESENTANTES[["logistic"]], fold, datos, splits); p <- m$parametros
  ref <- agregar(correr("logistic", "glmnet (estándar)", function() logistic_reg(penalty = 1 / p$C,
    mixture = as.numeric(p$penalty == "l1")) |> set_engine("glmnet"), m, fold))
  agregar(correr("logistic", "LiblineaR", function() logistic_reg(penalty = 1 / p$C,
    mixture = as.numeric(p$penalty == "l1")) |> set_engine("LiblineaR"), m, fold, ref))

  # Random Forest: paralelismo entre árboles (num.threads de ranger).
  m <- matrices(REPRESENTANTES[["random_forest"]], fold, datos, splits)
  base <- especificar_modelo("random_forest", m$parametros, semilla_r(m$fila$model_seed))
  ref <- agregar(correr("random_forest", "num.threads=1 (estándar)", function() base, m, fold))
  for (hilos in c(2, 4, 8)) {
    agregar(correr("random_forest", paste0("num.threads=", hilos),
                   function() set_engine(base, "ranger", num.threads = hilos, seed = semilla_r(m$fila$model_seed)), m, fold, ref))
  }

  # XGBoost: histogramas (estándar) frente a método exacto y early stopping.
  m <- matrices(REPRESENTANTES[["xgboost"]], fold, datos, splits)
  base <- especificar_modelo("xgboost", m$parametros, semilla_r(m$fila$model_seed))
  ref <- agregar(correr("xgboost", "hist (estándar)", function() base, m, fold))
  agregar(correr("xgboost", "exact", function() set_engine(base, "xgboost", tree_method = "exact", nthread = 1),
                 m, fold, ref))
  agregar(correr("xgboost", "hist, T=1000 sin early stopping", function() set_args(base, trees = 1000), m, fold, ref))
  # Early stopping: la validación (20 %) sale del entrenamiento externo ANTES de SMOTE.
  agregar(correr("xgboost", "hist + early stopping", function() set_args(base, trees = 1000, stop_iter = 30) |>
    set_engine("xgboost", validation = 0.2, eval_metric = "logloss", tree_method = "hist", nthread = 1), m, fold, ref))

  # SVM: núcleo RBF exacto (estándar) frente a alternativas lineales.
  m <- matrices(REPRESENTANTES[["svm"]], fold, datos, splits); p <- m$parametros
  ref <- agregar(correr("svm", "SVC RBF (estándar)", function() svm_rbf(cost = p$C, rbf_sigma = p$gamma) |>
    set_engine("kernlab") |> set_mode("classification"), m, fold))
  agregar(correr("svm", "LinearSVC", function() svm_linear(cost = p$C) |> set_engine("LiblineaR") |>
    set_mode("classification"), m, fold, ref))
  bind_rows(filas)
}

# Tiempo frente a n (filas) y p (columnas) para estimar exponentes empíricos.
escalamiento <- function(datos, splits, repeticiones = 3) {
  m <- matrices(REPRESENTANTES[["svm"]], 0, datos, splits)
  set.seed(SEMILLA_GLOBAL)
  consultas <- head(m$Ze, 1000)
  fabricas <- list(
    "knn (predicción)" = function() nearest_neighbor(neighbors = 41, dist_power = 1) |> set_engine("kknn"),
    "naive_bayes" = function() naive_Bayes() |> set_engine("naivebayes"),
    "logistic glmnet" = function() logistic_reg(penalty = 20, mixture = 1) |> set_engine("glmnet"),
    "random_forest (100 árboles)" = function() rand_forest(trees = 100) |>
      set_engine("ranger", max.depth = 8, num.threads = 1, seed = SEMILLA_GLOBAL),
    "xgboost hist" = function() boost_tree(trees = 100, tree_depth = 4) |>
      set_engine("xgboost", tree_method = "hist", nthread = 1),
    "xgboost exact" = function() boost_tree(trees = 100, tree_depth = 4) |>
      set_engine("xgboost", tree_method = "exact", nthread = 1),
    "svm rbf" = function() svm_rbf(cost = 1, rbf_sigma = 0.03) |> set_engine("kernlab"),
    "svm lineal" = function() svm_linear(cost = 0.1) |> set_engine("LiblineaR"))
  ejes <- list(n = c(800, 1600, 3200, 6400), p = c(24, 48, 96, 192))
  imap_dfr(ejes, function(valores, eje) map_dfr(valores, function(valor) {
    if (eje == "n") {
      idx <- sample(nrow(m$Z), min(valor, nrow(m$Z))); Zs <- m$Z[idx, ]; Q <- consultas
    } else {
      idx <- sample(nrow(m$Z), 3200)
      extra <- valor - ncol(m$Z)
      ruido <- as_tibble(matrix(rnorm(nrow(m$Z) * extra), ncol = extra), .name_repair = ~ paste0("ruido_", seq_along(.x)))
      ruido_q <- as_tibble(matrix(rnorm(nrow(consultas) * extra), ncol = extra), .name_repair = ~ paste0("ruido_", seq_along(.x)))
      Zs <- bind_cols(m$Z, ruido)[idx, ]; Q <- bind_cols(consultas, ruido_q)
    }
    ys <- m$yz[idx]
    imap_dfr(fabricas, function(fabrica, nombre) {
      tiempos <- map_dbl(seq_len(repeticiones), function(i) {
        ajuste <- medir(fit_xy(set_mode(fabrica(), "classification"), x = Zs, y = ys))
        prediccion <- medir(predict(ajuste$valor, Q))
        if (grepl("predicción", nombre)) prediccion$segundos else ajuste$segundos
      })
      tibble(axis = eje, value = valor, n = nrow(Zs), p = ncol(Zs), model = nombre,
             median_seconds = median(tiempos), repetitions = repeticiones)
    })
  }))
}

# Validación cruzada de RF-SMOTE completa con distintos trabajadores (future).
paralelismo_cv <- function(datos, splits) {
  fila <- unidad_oficial(REPRESENTANTES[["random_forest"]], 0)
  folds <- manual_rset(map(splits, function(s) make_splits(list(analysis = unlist(s$fit_pos) + 1,
                                                                assessment = unlist(s$eval_pos) + 1),
                                                           select(datos, -row_id))),
                       paste0("Fold", seq_along(splits)))
  referencia <- NULL
  tabla <- map_dfr(list(c("sequential", 1), c("multisession", 2), c("multisession", 4)), function(conf) {
    future::plan(conf[1], workers = as.integer(conf[2]))
    medidas <- map(1:3, ~ medir(fit_resamples(flujo_oficial(fila), folds, metrics = metric_set(f_meas))))
    f1 <- collect_metrics(medidas[[1]]$valor, summarize = FALSE)$.estimate
    referencia <<- referencia %||% f1
    tibble(backend = conf[1], n_jobs = as.integer(conf[2]), median_seconds = median(map_dbl(medidas, "segundos")),
           min_seconds = min(map_dbl(medidas, "segundos")), rss_mib_parent = medidas[[3]]$mib,
           f1_mean = mean(f1), same_f1_as_serial = isTRUE(all.equal(f1, referencia)))
  })
  future::plan("sequential")
  serial <- tabla$median_seconds[tabla$n_jobs == 1]
  mutate(tabla, speedup = serial / median_seconds, efficiency = speedup / n_jobs)
}

# Perfil (Rprof) del ajuste completo de SVM-SMOTE y de la predicción de KNN-SMOTE.
perfiles <- function(datos, splits) {
  map(c(svm = "fit", knn = "predict"), function(accion) {
    eid <- REPRESENTANTES[[if (accion == "fit") "svm" else "knn"]]
    flujo <- flujo_oficial(unidad_oficial(eid, 0))
    partes <- dividir_fold(datos, splits[[1]])
    if (accion == "predict") flujo <- fit(flujo, select(partes$ajuste, -row_id))
    archivo <- tempfile(fileext = ".out")
    Rprof(archivo)
    if (accion == "fit") fit(flujo, select(partes$ajuste, -row_id)) else predict(flujo, partes$evaluacion)
    Rprof(NULL)
    head(summaryRprof(archivo)$by.total, 18)
  })
}

# Intenta XGBoost con CUDA y documenta el resultado sin inventar una aceleración.
prueba_gpu <- function() {
  set.seed(0)
  Z <- matrix(rnorm(1000), ncol = 5); y <- as.integer(Z[, 1] > 0)
  avisos <- character()
  estado <- withCallingHandlers(
    tryCatch({
      xgboost::xgb.train(params = list(device = "cuda", objective = "binary:logistic"),
                         data = xgboost::xgb.DMatrix(Z, label = y), nrounds = 5)
      "sin error"
    }, error = function(e) paste("error:", substr(conditionMessage(e), 1, 200))),
    warning = function(w) { avisos <<- c(avisos, substr(conditionMessage(w), 1, 300)); invokeRestart("muffleWarning") })
  list(device = "cuda", estado = estado, avisos = avisos)
}

# Ejecuta las partes indicadas y guarda los archivos que lee el capítulo de modelado.
ejecutar_optimizacion <- function(partes = c("comparaciones", "escalamiento", "paralelismo", "perfiles", "gpu")) {
  datos <- datos_desarrollo(); splits <- leer_splits()
  dir.create(SALIDA_OC, recursive = TRUE, showWarnings = FALSE)
  if ("comparaciones" %in% partes)
    readr::write_csv(map_dfr(0:4, comparaciones_por_fold, datos = datos, splits = splits),
                     file.path(SALIDA_OC, "comparaciones_por_fold.csv"))
  if ("escalamiento" %in% partes)
    readr::write_csv(escalamiento(datos, splits), file.path(SALIDA_OC, "escalamiento.csv"))
  if ("paralelismo" %in% partes)
    readr::write_csv(paralelismo_cv(datos, splits), file.path(SALIDA_OC, "paralelismo_cv.csv"))
  if ("perfiles" %in% partes)
    iwalk(perfiles(datos, splits), ~ capture.output(print(.x), file = file.path(SALIDA_OC, paste0("perfil_", .y, ".txt"))))
  if ("gpu" %in% partes)
    write_json(prueba_gpu(), file.path(SALIDA_OC, "gpu.json"), auto_unbox = TRUE, pretty = TRUE)
}
