# Funciones compartidas por los experimentos complementarios.
#
# Cada módulo parte de las unidades oficiales de la realización 0: mismas particiones externas
# (splits.json), mismos hiperparámetros elegidos por la búsqueda (best_params de unidades.csv) y
# mismas semillas. Así, lo que se compara en cada experimento es solo el procedimiento añadido.

suppressPackageStartupMessages({
  library(tidymodels)
  library(themis)
  library(discrim)
  library(jsonlite)
  library(dplyr)
  library(purrr)
})

ROOT <- getwd()
OFICIAL <- file.path(ROOT, "resultados_modelado/oficial/20260920T030103_517c8c6b7906_69c6c7")
ANALISIS <- file.path(ROOT, "resultados_modelado/analisis_final")
COMPLEMENTARIOS <- file.path(ROOT, "resultados_modelado/complementarios")
SEMILLA_GLOBAL <- 42
NUMERICAS <- c("tenure", "MonthlyCharges", "TotalCharges")

# Variables originales y etiqueta de los 5.634 clientes de desarrollo, en el orden oficial.
datos_desarrollo <- function() {
  raw <- readr::read_csv(file.path(ROOT, "WA_Fn-UseC_-Telco-Customer-Churn.csv"), show_col_types = FALSE,
                         col_types = readr::cols(.default = "c", SeniorCitizen = "c", tenure = "i",
                                                 MonthlyCharges = "d"))
  orden <- readr::read_csv(file.path(ROOT, "train_index.csv"), show_col_types = FALSE)[[1]]
  datos <- raw[orden + 1, ] |>
    mutate(row_id = orden, Churn = factor(if_else(Churn == "Yes", "1", "0"), levels = c("1", "0")),
           TotalCharges = suppressWarnings(as.numeric(TotalCharges))) |>
    select(-customerID)
  datos
}

# Particiones externas oficiales (posiciones 0-indexadas sobre los datos de desarrollo).
leer_splits <- function() fromJSON(file.path(OFICIAL, "splits.json"), simplifyVector = FALSE)

# Fila oficial de una configuración en un fold de la realización 0.
unidad_oficial <- function(eid, fold) {
  unidades <- readr::read_csv(file.path(ANALISIS, "unidades.csv"), show_col_types = FALSE)
  fila <- filter(unidades, experiment_id == eid, replicate == 0, outer_fold == fold)
  stopifnot(nrow(fila) == 1)
  as.list(fila)
}

# Modelo parsnip de cada familia con los hiperparámetros elegidos.
#
# n_predictores y n_filas traducen los hiperparámetros de scikit-learn a las bibliotecas de R:
# max_features es una fracción de los predictores y C de la logística equivale en glmnet a
# lambda = 1 / (C · n), sin estandarizar (el Pipeline ya escala).
especificar_modelo <- function(modelo, p, semilla, n_predictores = 24, n_filas = 4507) {
  mtry <- if (identical(p$max_features, "sqrt")) floor(sqrt(n_predictores)) else
    max(1, floor(as.numeric(p$max_features %||% 1) * n_predictores))
  switch(modelo,
    knn = nearest_neighbor(neighbors = p$n_neighbors, dist_power = p$p,
                           weight_func = if (p$weights == "distance") "inv" else "rectangular") |>
      set_engine("kknn"),
    naive_bayes = naive_Bayes() |> set_engine("naivebayes", usekernel = FALSE),
    logistic = logistic_reg(penalty = 1 / (p$C * n_filas), mixture = as.numeric(p$penalty == "l1")) |>
      set_engine("glmnet", standardize = FALSE),
    decision_tree = decision_tree(tree_depth = p$max_depth %||% 30, min_n = p$min_samples_leaf,
                                  cost_complexity = 0) |>
      set_engine("rpart", parms = list(split = if (identical(p$criterion, "entropy")) "information" else "gini")),
    random_forest = rand_forest(trees = p$n_estimators, min_n = p$min_samples_leaf, mtry = mtry) |>
      set_engine("ranger", max.depth = p$max_depth %||% 0, seed = semilla, num.threads = 1,
                 splitrule = if (identical(p$criterion, "entropy")) "hellinger" else "gini"),
    xgboost = boost_tree(trees = p$n_estimators, tree_depth = p$max_depth, learn_rate = p$learning_rate,
                         sample_size = p$subsample %||% 1, mtry = p$colsample_bytree %||% 1,
                         min_n = p$min_child_weight %||% 1) |>   # en parsnip min_n es min_child_weight
      set_engine("xgboost", counts = FALSE, tree_method = "hist", nthread = 1, seed = semilla),
    svm = svm_rbf(cost = p$C, rbf_sigma = p$gamma) |> set_engine("kernlab"),
    stop("Modelo desconocido: ", modelo)
  ) |>
    set_mode("classification")
}

# Pesos de clase "balanced" (n / (2 · n_clase)) para la estrategia de ponderación.
agregar_pesos <- function(datos) {
  conteo <- table(datos$Churn)
  mutate(datos, peso = hardhat::importance_weights(as.numeric(nrow(datos) / (2 * conteo[as.character(Churn)]))))
}

# Pipeline oficial: reglas deterministas → escalado/codificación → balanceo del entrenamiento → clasificador.
# Con balanceo "balanced" los datos de ajuste deben llevar la columna peso (agregar_pesos()).
crear_flujo <- function(modelo, balanceo, parametros, semilla_modelo, semilla_balanceo,
                        n_predictores = 24, n_filas = 4507) {
  plantilla <- select(datos_desarrollo(), -row_id)
  if (balanceo == "balanced") plantilla <- agregar_pesos(plantilla)
  receta <- recipe(Churn ~ ., data = plantilla) |>
    step_mutate(TotalCharges = if_else(tenure == 0, 0, TotalCharges),
                AvgChargePerMonth = if_else(tenure > 0, TotalCharges / tenure, MonthlyCharges)) |>
    step_normalize(all_numeric_predictors()) |>
    step_dummy(all_nominal_predictors(), one_hot = FALSE)
  receta <- switch(balanceo,
    smote = step_smote(receta, Churn, over_ratio = 1, neighbors = 5, seed = semilla_balanceo),
    adasyn = step_adasyn(receta, Churn, over_ratio = 1, neighbors = 5, seed = semilla_balanceo),
    receta)
  # XGBoost recibe una matriz densa: con la matriz dispersa por defecto, xgboost trataría los ceros
  # de las variables codificadas como valores faltantes.
  composicion <- if (modelo == "xgboost") "matrix" else "tibble"
  flujo <- workflow() |>
    add_recipe(receta, blueprint = hardhat::default_recipe_blueprint(composition = composicion)) |>
    add_model(especificar_modelo(modelo, parametros, semilla_modelo, n_predictores, n_filas))
  if (balanceo == "balanced") flujo <- add_case_weights(flujo, peso)
  flujo
}

# Las semillas del registro son uint32; R usa enteros con signo de 32 bits.
semilla_r <- function(semilla) as.integer(as.numeric(semilla) %% .Machine$integer.max)

# Workflow sin ajustar de una unidad oficial, reconstruido desde su registro.
flujo_oficial <- function(fila) {
  crear_flujo(fila$model, fila$balance, fromJSON(fila$best_params),
              semilla_r(fila$model_seed), semilla_r(fila$sampler_seed), fila$p, fila$n_effective)
}

# Datos de ajuste listos para un workflow: sin row_id y con pesos si la estrategia es "balanced".
datos_ajuste <- function(datos, balanceo) {
  datos <- select(datos, -row_id)
  if (balanceo == "balanced") agregar_pesos(datos) else datos
}

# Divide los datos de desarrollo según un fold externo oficial.
dividir_fold <- function(datos, split) {
  list(ajuste = datos[unlist(split$fit_pos) + 1, ], evaluacion = datos[unlist(split$eval_pos) + 1, ])
}

# F1 de la clase abandono y AUC a partir de etiquetas y score continuo.
metricas_basicas <- function(verdad, etiquetas, score) {
  verdad <- factor(verdad, levels = c("1", "0")); etiquetas <- factor(etiquetas, levels = c("1", "0"))
  c(f1 = f_meas_vec(verdad, etiquetas), auc = roc_auc_vec(verdad, score))
}
