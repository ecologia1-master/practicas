# ============================================================================
# PRÁCTICA ECOLOGÍA GENERAL
# Script 01: Cargar datos de murciélagos frugívoros
# ============================================================================
# Este script carga los datos del caso de estudio, realiza una limpieza inicial
# y guarda una versión procesada para los análisis posteriores.
# ============================================================================

# 1. CONFIGURACIÓN INICIAL ---------------------------------------------------

# Limpiar el entorno de trabajo
rm(list = ls())

# Crear carpetas necesarias si no existen
if (!dir.exists("ecologia_interacciones/datos")) {
  dir.create("ecologia_interacciones/datos")
  cat("📁 Carpeta 'datos' creada\n")
}

if (!dir.exists("ecologia_interacciones/figuras")) {
  dir.create("ecologia_interacciones/figuras")
  cat("📁 Carpeta 'figuras' creada\n")
}

if (!dir.exists("ecologia_interacciones/resultados")) {
  dir.create("ecologia_interacciones/resultados")
  cat("📁 Carpeta 'resultados' creada\n")
}

# 2. CARGAR LIBRERÍAS --------------------------------------------------------

# Verificar e instalar paquetes si es necesario
paquetes_necesarios <- c("tidyverse", "ggplot2", "dplyr", "tidyr", "lubridate")

for (paquete in paquetes_necesarios) {
  if (!require(paquete, character.only = TRUE)) {
    install.packages(paquete, dependencies = TRUE)
    library(paquete, character.only = TRUE)
    cat(paste0("📦 Paquete '", paquete, "' instalado y cargado\n"))
  } else {
    library(paquete, character.only = TRUE)
  }
}

# 3. CARGAR DATOS ------------------------------------------------------------

# Opción 1: Cargar desde archivo local (si existe)
if (file.exists("ecologia_interacciones/datos/murcielagos_interacciones.csv")) {
  datos <- read.csv("ecologia_interacciones/datos/murcielagos_interacciones.csv",
                    stringsAsFactors = FALSE,
                    fileEncoding = "UTF-8")
  cat("✅ Datos cargados desde archivo local\n")
  
  # Opción 2: Descargar desde GitHub (si el archivo local no existe)
} else {
  url_datos <- "https://raw.githubusercontent.com/ecologia1-master/practicas/refs/heads/main/ecologia_interacciones/datos/murcielagos_interacciones.csv"
  
  tryCatch({
    datos <- read.csv(url_datos, stringsAsFactors = FALSE)
    cat("✅ Datos descargados desde GitHub\n")
  }, error = function(e) {
    stop("❌ No se pudo cargar el archivo de datos. Verifica la URL o que el archivo local exista.")
  })
}

# 4. EXPLORACIÓN INICIAL DE DATOS --------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📊 EXPLORACIÓN INICIAL DE DATOS\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Estructura del dataframe
cat("\n📋 Estructura del dataset:\n")
str(datos)

# Resumen estadístico
cat("\n📈 Resumen estadístico:\n")
print(summary(datos))

# Primeras filas
cat("\n👀 Primeras 6 filas:\n")
print(head(datos))

# Últimas filas
cat("\n👀 Últimas 6 filas:\n")
print(tail(datos))

# 5. LIMPIEZA Y PREPARACIÓN DE DATOS -----------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("🛠️  PREPARACIÓN DE DATOS\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Convertir fecha a formato Date
datos$fecha <- as.Date(datos$fecha)
cat("✅ Columna 'fecha' convertida a formato Date\n")

# Extraer mes de la fecha
datos$mes <- format(datos$fecha, "%m")
datos$mes_nombre <- format(datos$fecha, "%B")
cat("✅ Columnas 'mes' y 'mes_nombre' creadas\n")

# Verificar valores faltantes
cat("\n🔍 Valores faltantes por columna:\n")
faltantes <- colSums(is.na(datos))
print(faltantes[faltantes > 0])

if (sum(faltantes) == 0) {
  cat("✅ No se encontraron valores faltantes\n")
}

# Verificar especies únicas
cat("\n🦇 Especies presentes en el dataset:\n")
especies <- unique(datos$especie)
print(especies)
cat(paste0("Total de especies: ", length(especies), "\n"))

# Verificar localidades
cat("\n📍 Localidades presentes:\n")
localidades <- unique(datos$localidad)
print(localidades)
cat(paste0("Total de localidades: ", length(localidades), "\n"))

# 6. ESTADÍSTICAS DESCRIPTIVAS BÁSICAS ---------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📊 ESTADÍSTICAS DESCRIPTIVAS\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Resumen por especie
cat("\n📈 Abundancia por especie:\n")
resumen_especie <- datos %>%
  group_by(especie) %>%
  summarise(
    abundancia_media = round(mean(abundancia), 2),
    abundancia_mediana = round(median(abundancia), 2),
    abundancia_sd = round(sd(abundancia), 2),
    abundancia_min = min(abundancia),
    abundancia_max = max(abundancia),
    total_individuos = sum(abundancia),
    n_muestreos = n(),
    .groups = "drop"
  )
print(resumen_especie)

# Resumen por localidad
cat("\n📈 Abundancia por localidad:\n")
resumen_localidad <- datos %>%
  group_by(localidad) %>%
  summarise(
    abundancia_media = round(mean(abundancia), 2),
    total_individuos = sum(abundancia),
    riqueza_especies = n_distinct(especie),
    .groups = "drop"
  )
print(resumen_localidad)

# Resumen por tipo de vegetación
cat("\n📈 Abundancia por tipo de vegetación:\n")
resumen_vegetacion <- datos %>%
  group_by(tipo_vegetacion) %>%
  summarise(
    abundancia_media = round(mean(abundancia), 2),
    total_individuos = sum(abundancia),
    .groups = "drop"
  )
print(resumen_vegetacion)

# 7. GUARDAR DATOS PROCESADOS ------------------------------------------------

# Guardar datos procesados para scripts posteriores
saveRDS(datos, "ecologia_interacciones/datos/datos_procesados.rds")
cat("\n💾 Datos procesados guardados en 'datos/datos_procesados.rds'\n")

# Guardar también en formato CSV por si se necesita
write.csv(datos, "ecologia_interacciones/datos/datos_procesados.csv", row.names = FALSE)
cat("💾 Datos procesados guardados en 'datos/datos_procesados.csv'\n")

# Guardar resúmenes
resumenes <- list(
  por_especie = resumen_especie,
  por_localidad = resumen_localidad,
  por_vegetacion = resumen_vegetacion
)
saveRDS(resumenes, "ecologia_interacciones/resultados/resumenes_descriptivos.rds")

# 8. MENSAJE FINAL -----------------------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("✅ SCRIPT 01 COMPLETADO EXITOSAMENTE\n")
cat("\n", rep("=", 60), "\n", sep = '')
cat("\n📌 Resumen de archivos generados:\n")
cat("   - ecologia_interacciones/datos/datos_procesados.rds (formato R)\n")
cat("   - ecologia_interacciones/datos/datos_procesados.csv (formato CSV)\n")
cat("   - ecologia_interacciones/resultados/resumenes_descriptivos.rds\n")
cat("\n🚀 Puedes proceder con el Script 02: ecologia_interacciones/scripts/02_analisis_exploratorio.R\n")
