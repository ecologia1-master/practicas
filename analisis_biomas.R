# ============================================================
# analisis_biomas.R
# Práctica II – Eco-Inferencia (Whittaker: clima ↔ bioma)
#
# Objetivo para el estudiante:
# - Ejecutar este script paso a paso (Run) y observar:
#   (1) Vista rápida de los datos
#   (2) summary() de temperatura y precipitación
#   (3) gráfico tiempo-series (T y P)
#   (4) punto en el diagrama de Whittaker (aprox.)
#   (5) guía para redactar 3 evidencias
# ============================================================

# ---------- 0) Preparación ----------
cat("\n============================================================\n")
cat(" ECO-INFERENCIA · Análisis guiado con R\n")
cat("============================================================\n\n")

# Carpeta donde están los CSV
data_dir <- "salida_biomas"

if (!dir.exists(data_dir)) {
  stop("No encuentro la carpeta 'salida_biomas'.\n",
       "Asegúrate de estar trabajando en el proyecto/repo correcto.")
}

# Listar localidades disponibles
archivos <- list.files(data_dir, pattern = "^localidad_.*\\.csv$", full.names = TRUE)

if (length(archivos) == 0) {
  stop("No encuentro archivos 'localidad_*.csv' en la carpeta 'salida_biomas'.")
}

cat("Localidades disponibles:\n")
for (i in seq_along(archivos)) {
  cat(sprintf("  [%d] %s\n", i, basename(archivos[i])))
}
cat("\n")

# ---------- 1) Elegir una localidad ----------
# Instrucción: el estudiante cambia el número y vuelve a ejecutar esta sección.
i_localidad <- 1  # <-- CAMBIA ESTO: 1, 2, 3, ...
archivo_elegido <- archivos[i_localidad]

cat("Localidad elegida:", basename(archivo_elegido), "\n\n")

# ---------- 2) Cargar datos ----------
# Intentamos usar read.csv (base R) para que no dependa de paquetes.
datos <- read.csv(archivo_elegido, stringsAsFactors = FALSE)

cat("Primeras filas del dataset:\n")
print(head(datos, 10))
cat("\n")

cat("Estructura del dataset (tipos de columnas):\n")
str(datos)
cat("\n")

# Verificación mínima de columnas esperadas
cols_necesarias <- c("Anio", "Temp_media_C", "Precip_anual_mm", "Especie_Dominante")
faltan <- setdiff(cols_necesarias, names(datos))
if (length(faltan) > 0) {
  stop("Faltan columnas en el CSV: ", paste(faltan, collapse = ", "),
       "\nEl dataset no coincide con el formato esperado.")
}

# ---------- 3) Resúmenes (la evidencia cuantitativa) ----------
cat("============================================================\n")
cat(" RESÚMENES (usar para Evidencia 1 y 2)\n")
cat("============================================================\n\n")

cat("Summary de Temp_media_C:\n")
print(summary(datos$Temp_media_C))
cat("\n")

cat("Summary de Precip_anual_mm:\n")
print(summary(datos$Precip_anual_mm))
cat("\n")

# Medidas simples para hablar de variabilidad (Evidencia 2)
temp_sd <- sd(datos$Temp_media_C, na.rm = TRUE)
prec_sd <- sd(datos$Precip_anual_mm, na.rm = TRUE)

temp_min <- min(datos$Temp_media_C, na.rm = TRUE)
temp_max <- max(datos$Temp_media_C, na.rm = TRUE)

prec_min <- min(datos$Precip_anual_mm, na.rm = TRUE)
prec_max <- max(datos$Precip_anual_mm, na.rm = TRUE)

cat(sprintf("Rango temperatura: %.1f a %.1f °C\n", temp_min, temp_max))
cat(sprintf("Desviación estándar temperatura: %.2f °C\n\n", temp_sd))

cat(sprintf("Rango precipitación: %.0f a %.0f mm\n", prec_min, prec_max))
cat(sprintf("Desviación estándar precipitación: %.0f mm\n\n", prec_sd))

# Promedios (útiles para ubicar en Whittaker)
MAT <- mean(datos$Temp_media_C, na.rm = TRUE)
MAP <- mean(datos$Precip_anual_mm, na.rm = TRUE)

cat(sprintf("Promedio (MAT) ≈ %.1f °C\n", MAT))
cat(sprintf("Promedio (MAP) ≈ %.0f mm/año\n\n", MAP))

# ---------- 4) Evidencia biótica (especie dominante) ----------
cat("============================================================\n")
cat(" EVIDENCIA BIÓTICA (usar para Evidencia 3)\n")
cat("============================================================\n\n")

# En tus CSV la especie dominante suele ser constante; aún así lo mostramos robusto:
especies <- unique(datos$Especie_Dominante)
cat("Especie(s) dominante(s) reportada(s):\n")
print(especies)
cat("\n")

cat("Pista:\n")
cat("- ¿Qué tipo de planta es? (árbol, cactus, gramínea, conífera…)\n")
cat("- ¿Qué adaptación sugiere? (hojas pequeñas, espinas, caducifolia, etc.)\n\n")

# ---------- 5) Gráficos: ver el patrón ----------
cat("============================================================\n")
cat(" GRÁFICOS\n")
cat("============================================================\n\n")

op <- par(no.readonly = TRUE)
on.exit(par(op), add = TRUE)

par(mfrow = c(2,1), mar = c(4,4,2,1))

plot(datos$Anio, datos$Temp_media_C,
     type = "b", pch = 16,
     xlab = "Año", ylab = "Temperatura media (°C)",
     main = "Serie temporal: Temperatura")
grid()

plot(datos$Anio, datos$Precip_anual_mm,
     type = "b", pch = 16,
     xlab = "Año", ylab = "Precipitación anual (mm)",
     main = "Serie temporal: Precipitación")
grid()

par(mfrow = c(1,1))

cat("✅ Se mostraron dos gráficos: temperatura y precipitación a través del tiempo.\n")
cat("   Interpreta: ¿hay estabilidad? ¿años extremos? ¿mucha variación?\n\n")

# ---------- 6) Ubicación aproximada en Whittaker ----------
cat("============================================================\n")
cat(" WHITTAKER (ubicación aproximada)\n")
cat("============================================================\n\n")

# Si existe la imagen ya generada, se muestra para userse como referencia.
img_path <- file.path(data_dir, "whittaker_localidades.png")
if (file.exists(img_path)) {
  cat("Se encontró el diagrama: ", img_path, "\n")
  cat("Se intentará abrir en una ventana de gráficos.\n\n")
  
  # Mostrar imagen (sin paquetes extra)
  # Nota: en algunos entornos puede requerir png/jpeg; aquí usamos png.
  if (capabilities("png")) {
    # Abrir y dibujar la imagen
    img <- try(png::readPNG(img_path), silent = TRUE)
    
    if (inherits(img, "try-error")) {
      # Si no está el paquete png, lo instalamos (CRAN)
      if (!requireNamespace("png", quietly = TRUE)) install.packages("png")
      img <- png::readPNG(img_path)
    }
    
    plot.new()
    rasterImage(img, 0, 0, 1, 1)
    title(main = "Whittaker (referencia) – mira dónde cae tu punto")
    
    cat("Ahora ubica tu punto con estos valores promedio:\n")
    cat(sprintf("  MAT ≈ %.1f °C\n", MAT))
    cat(sprintf("  MAP ≈ %.0f mm/año\n\n", MAP))
  } else {
    cat("Tu R no tiene soporte para 'png' en este entorno.\n")
    cat("Abre manualmente 'salida_biomas/whittaker_localidades.png'.\n\n")
  }
} else {
  cat("No se encontró 'whittaker_localidades.png' en salida_biomas.\n")
  cat("Usa el diagrama de tus apuntes y ubica el punto con:\n")
  cat(sprintf("  MAT ≈ %.1f °C\n", MAT))
  cat(sprintf("  MAP ≈ %.0f mm/año\n\n", MAP))
}

# ---------- 7) Plantilla para el argumento (3 evidencias) ----------
cat("============================================================\n")
cat(" PLANTILLA (para escribir su argumento)\n")
cat("============================================================\n\n")

cat("Completen (en su cuaderno o documento):\n\n")

cat("Conclusión: El bioma más probable es: _______________________________\n\n")

cat("Evidencia 1 (clima – Whittaker):\n")
cat(sprintf("- MAT ≈ %.1f °C; MAP ≈ %.0f mm/año.\n", MAT, MAP))
cat("- Esto se parece al rango del bioma __________________ según Whittaker.\n\n")

cat("Evidencia 2 (variabilidad/estacionalidad):\n")
cat(sprintf("- Temp: rango %.1f–%.1f °C; sd %.2f °C.\n", temp_min, temp_max, temp_sd))
cat(sprintf("- Prec: rango %.0f–%.0f mm; sd %.0f mm.\n", prec_min, prec_max, prec_sd))
cat("- Interpreten: ¿alta/baja variabilidad? ¿años extremos? ¿qué implica?\n\n")

cat("Evidencia 3 (biótica – especie dominante):\n")
cat("- Especie dominante reportada:\n")
print(especies)
cat("- ¿Qué tipo de planta es y qué adaptaciones sugiere?\n\n")

cat("============================================================\n")
cat(" FIN. Ahora preparen su informe oral (5 min): gráfico + 3 evidencias.\n")
cat("============================================================\n\n")
