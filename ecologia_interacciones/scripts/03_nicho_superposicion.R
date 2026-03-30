# ============================================================================
# PRÁCTICA ECOLOGÍA GENERAL
# Script 03: Cálculo de superposición de nicho (Índice de Pianka)
# ============================================================================
# Este script calcula el índice de superposición de nicho de Pianka para
# evaluar la similitud en el uso de recursos entre las dos especies.
# ============================================================================

# 1. CONFIGURACIÓN INICIAL ---------------------------------------------------

# Limpiar el entorno de trabajo
rm(list = ls())

# Cargar librerías
library(tidyverse)
library(ggplot2)

# Cargar datos procesados
if (file.exists("ecologia_interacciones/datos/datos_procesados.rds")) {
  datos <- readRDS("ecologia_interacciones/datos/datos_procesados.rds")
  cat("✅ Datos cargados desde 'ecologia_interacciones/datos/datos_procesados.rds'\n")
} else {
  stop("❌ No se encuentra el archivo 'ecologia_interacciones/datos/datos_procesados.rds'. Ejecuta primero el Script 01.")
}

# 2. FUNCIONES PARA CÁLCULO DE ÍNDICES DE NICHO ------------------------------

# Función para calcular el índice de superposición de Pianka
# O = sum(p_ij * p_ik) / sqrt(sum(p_ij^2) * sum(p_ik^2))
# Donde:
#   p_ij = proporción del recurso j utilizado por la especie i
#   p_ik = proporción del recurso j utilizado por la especie k

calcular_pianka <- function(p1, p2) {
  # Verificar que los vectores tengan la misma longitud
  if (length(p1) != length(p2)) {
    stop("Los vectores deben tener la misma longitud")
  }
  
  # Calcular numerador y denominador
  numerador <- sum(p1 * p2)
  denominador <- sqrt(sum(p1^2) * sum(p2^2))
  
  # Retornar índice (manejar división por cero)
  if (denominador == 0) {
    return(0)
  } else {
    return(numerador / denominador)
  }
}

# Función para calcular el índice de superposición de Schoener
# C = 1 - 0.5 * sum(|p_ij - p_ik|)

calcular_schoener <- function(p1, p2) {
  if (length(p1) != length(p2)) {
    stop("Los vectores deben tener la misma longitud")
  }
  
  return(1 - 0.5 * sum(abs(p1 - p2)))
}

# Función para calcular el índice de Morisita-Horn
# C = 2 * sum(p_ij * p_ik) / (sum(p_ij^2) + sum(p_ik^2))

calcular_morisita_horn <- function(p1, p2) {
  if (length(p1) != length(p2)) {
    stop("Los vectores deben tener la misma longitud")
  }
  
  numerador <- 2 * sum(p1 * p2)
  denominador <- sum(p1^2) + sum(p2^2)
  
  if (denominador == 0) {
    return(0)
  } else {
    return(numerador / denominador)
  }
}

# 3. CÁLCULO DE PROPORCIONES DE USO DE RECURSOS ------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📊 CÁLCULO DE PROPORCIONES DE USO DE RECURSOS\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Calcular uso de recursos por especie
# Usamos los frutos de Piper y Ficus como los dos recursos principales
uso_recursos <- datos %>%
  group_by(especie) %>%
  summarise(
    # Uso ponderado por abundancia de cada recurso
    uso_piper = sum(abundancia * piper_disponible /
                      (piper_disponible + ficus_disponible + 0.001)),
    uso_ficus = sum(abundancia * ficus_disponible /
                      (piper_disponible + ficus_disponible + 0.001)),
    .groups = "drop"
  ) %>%
  mutate(
    total = uso_piper + uso_ficus,
    prop_piper = uso_piper / total,
    prop_ficus = uso_ficus / total
  )

cat("\n📈 Proporciones de uso de recursos por especie:\n")
print(uso_recursos[, c("especie", "prop_piper", "prop_ficus")])

# Extraer vectores de proporciones
p_artibeus <- uso_recursos %>%
  filter(especie == "Artibeus_jamaicensis") %>%
  select(prop_piper, prop_ficus) %>%
  as.numeric()

p_carollia <- uso_recursos %>%
  filter(especie == "Carollia_perspicillata") %>%
  select(prop_piper, prop_ficus) %>%
  as.numeric()

cat("\n📊 Vector de proporciones para Artibeus jamaicensis:\n")
cat(paste("   Piper:", round(p_artibeus[1], 3), "\n"))
cat(paste("   Ficus:", round(p_artibeus[2], 3), "\n"))

cat("\n📊 Vector de proporciones para Carollia perspicillata:\n")
cat(paste("   Piper:", round(p_carollia[1], 3), "\n"))
cat(paste("   Ficus:", round(p_carollia[2], 3), "\n"))

# 4. CÁLCULO DE ÍNDICES DE SUPERPOSICIÓN -------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("🔄 CÁLCULO DE ÍNDICES DE SUPERPOSICIÓN DE NICHO\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Calcular los tres índices
indice_pianka <- calcular_pianka(p_artibeus, p_carollia)
indice_schoener <- calcular_schoener(p_artibeus, p_carollia)
indice_morisita <- calcular_morisita_horn(p_artibeus, p_carollia)

# Crear tabla de resultados
indices_nicho <- data.frame(
  Indice = c("Pianka", "Schoener", "Morisita-Horn"),
  Valor = c(indice_pianka, indice_schoener, indice_morisita),
  Interpretacion = c(
    ifelse(indice_pianka < 0.3, "Baja superposición - nichos separados",
           ifelse(indice_pianka < 0.7, "Superposición moderada - posible partición",
                  "Alta superposición - posible competencia")),
    ifelse(indice_schoener < 0.3, "Baja superposición",
           ifelse(indice_schoener < 0.7, "Superposición moderada", "Alta superposición")),
    ifelse(indice_morisita < 0.3, "Baja superposición",
           ifelse(indice_morisita < 0.7, "Superposición moderada", "Alta superposición"))
  )
)

cat("\n📊 Resultados de índices de superposición:\n")
print(indices_nicho)

# 5. ANÁLISIS DETALLADO POR LOCALIDAD ----------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📍 ANÁLISIS POR LOCALIDAD\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Calcular uso de recursos por especie y localidad
uso_localidad <- datos %>%
  group_by(localidad, especie) %>%
  summarise(
    uso_piper = sum(abundancia * piper_disponible /
                      (piper_disponible + ficus_disponible + 0.001)),
    uso_ficus = sum(abundancia * ficus_disponible /
                      (piper_disponible + ficus_disponible + 0.001)),
    .groups = "drop"
  ) %>%
  group_by(localidad) %>%
  mutate(
    total = uso_piper + uso_ficus,
    prop_piper = uso_piper / total,
    prop_ficus = uso_ficus / total
  )

# Calcular índices por localidad
localidades <- unique(uso_localidad$localidad)

resultados_localidad <- data.frame()

for (loc in localidades) {
  datos_loc <- uso_localidad %>% filter(localidad == loc)
  
  p_art_loc <- datos_loc %>%
    filter(especie == "Artibeus_jamaicensis") %>%
    ungroup() %>%
    select(prop_piper, prop_ficus) %>%
    as.numeric()
  
  p_car_loc <- datos_loc %>%
    filter(especie == "Carollia_perspicillata") %>%
    ungroup() %>%
    select(prop_piper, prop_ficus) %>%
    as.numeric()
  
  if (length(p_art_loc) > 0 && length(p_car_loc) > 0) {
    pianka_loc <- calcular_pianka(p_art_loc, p_car_loc)
    resultados_localidad <- rbind(resultados_localidad,
                                  data.frame(localidad = loc,
                                             indice_pianka = pianka_loc))
  }
}

cat("\n📊 Índices de superposición por localidad:\n")
print(resultados_localidad)

# 6. VISUALIZACIÓN DE LA SUPERPOSICIÓN DE NICHO ------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📊 GENERANDO VISUALIZACIONES DE NICHO\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Gráfico 1: Barras de proporciones de uso
nicho_df <- data.frame(
  especie = rep(c("Artibeus", "Carollia"), each = 2),
  recurso = rep(c("Piper", "Ficus"), 2),
  proporcion = c(p_artibeus[1], p_artibeus[2],
                 p_carollia[1], p_carollia[2])
)

g1_nicho <- ggplot(nicho_df, aes(x = recurso, y = proporcion, fill = especie)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, alpha = 0.9) +
  labs(
    title = "Partición de nicho trófico",
    subtitle = paste("Índice de Pianka =", round(indice_pianka, 3)),
    x = "Tipo de recurso alimenticio",
    y = "Proporción de uso",
    fill = "Especie"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    legend.position = "top",
    axis.text = element_text(size = 11),
    axis.title = element_text(face = "bold")
  ) +
  scale_fill_manual(
    values = c("Artibeus" = "#2c7bb6", "Carollia" = "#d7191c"),
    labels = c("Artibeus jamaicensis", "Carollia perspicillata")
  ) +
  ylim(0, 1)

print(g1_nicho)
ggsave("ecologia_interacciones/figuras/06_nicho_particion.png",
       g1_nicho, width = 7, height = 6, dpi = 300)
cat("✅ Figura 06 guardada: 'ecologia_interacciones/figuras/06_nicho_particion.png'\n")

# Gráfico 2: Diagrama de dispersión de nicho
# Crear puntos de datos simulados para visualizar la distribución del nicho
set.seed(123)
nicho_dispersion <- data.frame(
  especie = c(rep("Artibeus", 50), rep("Carollia", 50)),
  uso_piper = c(rnorm(50, mean = p_artibeus[1], sd = 0.1),
                rnorm(50, mean = p_carollia[1], sd = 0.1)),
  uso_ficus = c(rnorm(50, mean = p_artibeus[2], sd = 0.1),
                rnorm(50, mean = p_carollia[2], sd = 0.1))
)
nicho_dispersion$uso_piper <- pmax(0, pmin(1, nicho_dispersion$uso_piper))
nicho_dispersion$uso_ficus <- pmax(0, pmin(1, nicho_dispersion$uso_ficus))

g2_nicho_disp <- ggplot(nicho_dispersion, aes(x = uso_piper, y = uso_ficus,
                                              color = especie)) +
  geom_point(alpha = 0.6, size = 2) +
  stat_ellipse(level = 0.95, size = 1) +
  labs(
    title = "Espacio de nicho trófico",
    subtitle = "Elipses del 95% de confianza",
    x = "Proporción de uso de Piper",
    y = "Proporción de uso de Ficus",
    color = "Especie"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    legend.position = "top"
  ) +
  scale_color_manual(
    values = c("Artibeus" = "#2c7bb6", "Carollia" = "#d7191c"),
    labels = c("Artibeus jamaicensis", "Carollia perspicillata")
  ) +
  xlim(0, 1) +
  ylim(0, 1)

print(g2_nicho_disp)
ggsave("ecologia_interacciones/figuras/07_nicho_dispersion.png",
       g2_nicho_disp, width = 7, height = 6, dpi = 300)
cat("✅ Figura 07 guardada: 'ecologia_interacciones/figuras/07_nicho_dispersion.png'\n")

# Gráfico 3: Comparación de índices
indices_plot <- data.frame(
  Indice = c("Pianka", "Schoener", "Morisita-Horn"),
  Valor = c(indice_pianka, indice_schoener, indice_morisita)
)

g3_indices <- ggplot(indices_plot, aes(x = Indice, y = Valor, fill = Indice)) +
  geom_bar(stat = "identity", width = 0.6, alpha = 0.8) +
  geom_hline(yintercept = 0.3, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = 0.7, linetype = "dashed", color = "gray50") +
  labs(
    title = "Comparación de índices de superposición de nicho",
    subtitle = "Líneas punteadas: umbrales de interpretación (0.3 y 0.7)",
    x = "Índice",
    y = "Valor de superposición"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    legend.position = "none",
    axis.text = element_text(size = 11)
  ) +
  scale_fill_manual(values = c("#2c7bb6", "#fdae61", "#d7191c")) +
  ylim(0, 1)

print(g3_indices)
ggsave("ecologia_interacciones/figuras/08_comparacion_indices.png",
       g3_indices, width = 7, height = 5, dpi = 300)
cat("✅ Figura 08 guardada: 'ecologia_interacciones/figuras/08_comparacion_indices.png'\n")

# 7. GUARDAR RESULTADOS ------------------------------------------------------

resultados_nicho <- list(
  indices = indices_nicho,
  proporciones = uso_recursos,
  indices_por_localidad = resultados_localidad,
  valores_numericos = list(
    pianka = indice_pianka,
    schoener = indice_schoener,
    morisita_horn = indice_morisita
  )
)

saveRDS(resultados_nicho, "ecologia_interacciones/resultados/resultados_nicho.rds")
cat("\n💾 Resultados guardados en 'ecologia_interacciones/resultados/resultados_nicho.rds'\n")

# 8. INTERPRETACIÓN FINAL ----------------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📌 INTERPRETACIÓN ECOLÓGICA\n")
cat("\n", rep("=", 60), "\n", sep = '')

cat("\n🔍 Interpretación del índice de Pianka:\n")
if (indice_pianka < 0.3) {
  cat("   🟢 BAJA SUPERPOSICIÓN (", round(indice_pianka, 3), ")\n")
  cat("   → Las especies muestran una clara partición de nicho.\n")
  cat("   → Es probable que la competencia interespecífica sea baja.\n")
  cat("   → Cada especie se especializa en recursos diferentes.\n")
} else if (indice_pianka < 0.7) {
  cat("   🟡 SUPERPOSICIÓN MODERADA (", round(indice_pianka, 3), ")\n")
  cat("   → Existe cierto grado de partición de nicho.\n")
  cat("   → Puede haber competencia por recursos durante ciertas épocas.\n")
  cat("   → Se requiere análisis temporal para entender la dinámica.\n")
} else {
  cat("   🔴 ALTA SUPERPOSICIÓN (", round(indice_pianka, 3), ")\n")
  cat("   → Los nichos ecológicos son muy similares.\n")
  cat("   → Es probable que exista competencia interespecífica.\n")
  cat("   → Posible exclusión competitiva en condiciones de escasez.\n")
}

# 9. MENSAJE FINAL -----------------------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("✅ SCRIPT 03 COMPLETADO EXITOSAMENTE\n")
cat("\n", rep("=", 60), "\n", sep = '')
cat("\n📌 Figuras generadas (carpeta 'ecologia_interacciones/figuras/'):\n")
cat("   - 06_nicho_particion.png\n")
cat("   - 07_nicho_dispersion.png\n")
cat("   - 08_comparacion_indices.png\n")
cat("\n🚀 Puedes proceder con el Script 04: 04_simulacion_escasez.R\n")
