# ============================================================================
# PRÁCTICA ECOLOGÍA GENERAL
# Script 02: Análisis exploratorio de datos
# ============================================================================
# Este script realiza visualizaciones exploratorias para identificar patrones
# de abundancia, distribución y relaciones entre variables.
# ============================================================================

# 1. CONFIGURACIÓN INICIAL ---------------------------------------------------

# Limpiar el entorno de trabajo
rm(list = ls())

# Cargar librerías
library(tidyverse)
library(ggplot2)
library(lubridate)

# Cargar datos procesados
if (file.exists("ecologia_interacciones/datos/datos_procesados.rds")) {
  datos <- readRDS("ecologia_interacciones/datos/datos_procesados.rds")
  cat("✅ Datos cargados desde 'ecologia_interacciones/datos/datos_procesados.rds'\n")
} else {
  stop("❌ No se encuentra el archivo 'ecologia_interacciones/datos/datos_procesados.rds'. Ejecuta primero el Script 01.")
}

# 2. GRÁFICO 1: ABUNDANCIA POR ESPECIE Y TIPO DE VEGETACIÓN ------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📊 GENERANDO VISUALIZACIONES\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Gráfico de cajas (boxplot)
g1_boxplot <- ggplot(datos, aes(x = tipo_vegetacion, y = abundancia, fill = especie)) +
  geom_boxplot(alpha = 0.8, outlier.size = 2) +
  labs(
    title = "Abundancia de murciélagos por tipo de vegetación",
    subtitle = "Comparación entre Artibeus jamaicensis y Carollia perspicillata",
    x = "Tipo de vegetación",
    y = "Abundancia (individuos capturados)",
    fill = "Especie"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    legend.position = "top",
    axis.text = element_text(size = 10),
    axis.title = element_text(face = "bold")
  ) +
  scale_fill_manual(
    values = c("Artibeus_jamaicensis" = "#2c7bb6",
               "Carollia_perspicillata" = "#d7191c"),
    labels = c("Artibeus jamaicensis", "Carollia perspicillata")
  )

print(g1_boxplot)
ggsave("ecologia_interacciones/figuras/01_abundancia_por_vegetacion.png",
       g1_boxplot, width = 8, height = 6, dpi = 300)
cat("✅ Figura 01 guardada: 'ecologia_interacciones/figuras/01_abundancia_por_vegetacion.png'\n")

# 3. GRÁFICO 2: DINÁMICA TEMPORAL DE ABUNDANCIA ------------------------------

# Agregar datos por mes
datos_mensual <- datos %>%
  group_by(mes_nombre, mes, especie) %>%
  summarise(abundancia_total = sum(abundancia), .groups = "drop") %>%
  arrange(mes)  # Ordenar por número de mes

# Ordenar meses cronológicamente
orden_meses <- c("enero", "febrero", "marzo", "abril")
datos_mensual$mes_nombre <- factor(datos_mensual$mes_nombre, levels = orden_meses)

g2_temporal <- ggplot(datos_mensual, aes(x = mes_nombre, y = abundancia_total,
                                         color = especie, group = especie)) +
  geom_line(size = 1.5) +
  geom_point(size = 4, alpha = 0.8) +
  labs(
    title = "Dinámica temporal de abundancia",
    subtitle = "Enero - Abril 2024",
    x = "Mes",
    y = "Abundancia total (individuos)",
    color = "Especie"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    legend.position = "top",
    axis.text = element_text(size = 10),
    axis.title = element_text(face = "bold")
  ) +
  scale_color_manual(
    values = c("Artibeus_jamaicensis" = "#2c7bb6",
               "Carollia_perspicillata" = "#d7191c"),
    labels = c("Artibeus jamaicensis", "Carollia perspicillata")
  )

print(g2_temporal)
ggsave("ecologia_interacciones/figuras/02_dinamica_temporal.png",
       g2_temporal, width = 8, height = 5, dpi = 300)
cat("✅ Figura 02 guardada: 'ecologia_interacciones/figuras/02_dinamica_temporal.png'\n")

# 4. GRÁFICO 3: RELACIÓN CON DISPONIBILIDAD DE FRUTOS ------------------------

# Transformar datos para visualizar dieta
datos_dieta <- datos %>%
  pivot_longer(
    cols = c(piper_disponible, ficus_disponible),
    names_to = "tipo_fruto",
    values_to = "disponibilidad"
  ) %>%
  mutate(
    tipo_fruto = ifelse(tipo_fruto == "piper_disponible", "Piper", "Ficus"),
    tipo_fruto = factor(tipo_fruto, levels = c("Piper", "Ficus"))
  )

g3_dieta <- ggplot(datos_dieta, aes(x = disponibilidad, y = abundancia,
                                    color = especie, shape = tipo_fruto)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, linetype = "dashed", size = 0.8) +
  facet_wrap(~especie, scales = "free_x",
             labeller = labeller(especie = c(
               "Artibeus_jamaicensis" = "Artibeus jamaicensis",
               "Carollia_perspicillata" = "Carollia perspicillata"
             ))) +
  labs(
    title = "Relación entre disponibilidad de frutos y abundancia",
    subtitle = "Respuesta diferencial de cada especie a recursos alimenticios",
    x = "Disponibilidad de frutos (kg/ha)",
    y = "Abundancia de murciélagos",
    color = "Especie",
    shape = "Tipo de fruto"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    legend.position = "bottom",
    strip.text = element_text(face = "bold", size = 11),
    axis.text = element_text(size = 9)
  ) +
  scale_color_manual(
    values = c("Artibeus_jamaicensis" = "#2c7bb6",
               "Carollia_perspicillata" = "#d7191c"),
    labels = c("Artibeus jamaicensis", "Carollia perspicillata")
  )

print(g3_dieta)
ggsave("ecologia_interacciones/figuras/03_relacion_frutos_abundancia.png",
       g3_dieta, width = 10, height = 6, dpi = 300)
cat("✅ Figura 03 guardada: 'ecologia_interacciones/figuras/03_relacion_frutos_abundancia.png'\n")

# 5. GRÁFICO 4: MATRIZ DE CORRELACIONES --------------------------------------

# Seleccionar variables numéricas para correlación
variables_numericas <- datos %>%
  select(abundancia, altitud_m, precipitacion_mm,
         frutos_disponibles_kg_ha, temperatura_c)

# Calcular matriz de correlación
matriz_cor <- cor(variables_numericas, use = "complete.obs")

# Convertir a formato largo para visualización
library(reshape2)
matriz_cor_long <- melt(matriz_cor)

g4_correlacion <- ggplot(matriz_cor_long, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), size = 3) +
  scale_fill_gradient2(
    low = "#d7191c", mid = "white", high = "#2c7bb6",
    midpoint = 0, limit = c(-1, 1),
    name = "Correlación"
  ) +
  labs(
    title = "Matriz de correlaciones entre variables ambientales",
    subtitle = "Relaciones lineales entre variables numéricas",
    x = "", y = ""
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right"
  )

print(g4_correlacion)
ggsave("ecologia_interacciones/figuras/04_matriz_correlaciones.png",
       g4_correlacion, width = 8, height = 6, dpi = 300)
cat("✅ Figura 04 guardada: 'ecologia_interacciones/figuras/04_matriz_correlaciones.png'\n")

# 6. GRÁFICO 5: DISTRIBUCIÓN POR LOCALIDAD -----------------------------------

g5_localidad <- ggplot(datos, aes(x = localidad, y = abundancia, fill = especie)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  labs(
    title = "Abundancia total por localidad",
    x = "Localidad",
    y = "Abundancia total de individuos",
    fill = "Especie"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "top",
    axis.text = element_text(size = 10),
    axis.title = element_text(face = "bold")
  ) +
  scale_fill_manual(
    values = c("Artibeus_jamaicensis" = "#2c7bb6",
               "Carollia_perspicillata" = "#d7191c"),
    labels = c("Artibeus jamaicensis", "Carollia perspicillata")
  )

print(g5_localidad)
ggsave("ecologia_interacciones/figuras/05_abundancia_por_localidad.png",
       g5_localidad, width = 7, height = 5, dpi = 300)
cat("✅ Figura 05 guardada: 'ecologia_interacciones/figuras/05_abundancia_por_localidad.png'\n")

# 7. ANÁLISIS ESTADÍSTICO COMPLEMENTARIO -------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📈 ANÁLISIS ESTADÍSTICO\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Prueba t para comparar abundancia entre especies
cat("\n🔬 Prueba t de Student (abundancia entre especies):\n")
t_test <- t.test(abundancia ~ especie, data = datos)
print(t_test)

# ANOVA para comparar abundancia entre tipos de vegetación
cat("\n🔬 ANOVA (abundancia por tipo de vegetación):\n")
anova_veg <- aov(abundancia ~ tipo_vegetacion, data = datos)
print(summary(anova_veg))

# Correlación entre disponibilidad de frutos y abundancia por especie
cat("\n🔬 Correlación disponibilidad de frutos vs abundancia:\n")

cor_artibeus <- datos %>%
  filter(especie == "Artibeus_jamaicensis") %>%
  summarise(
    cor_piper = cor(piper_disponible, abundancia),
    cor_ficus = cor(ficus_disponible, abundancia)
  )
print(paste("Artibeus - Piper:", round(cor_artibeus$cor_piper, 3)))
print(paste("Artibeus - Ficus:", round(cor_artibeus$cor_ficus, 3)))

cor_carollia <- datos %>%
  filter(especie == "Carollia_perspicillata") %>%
  summarise(
    cor_piper = cor(piper_disponible, abundancia),
    cor_ficus = cor(ficus_disponible, abundancia)
  )
print(paste("Carollia - Piper:", round(cor_carollia$cor_piper, 3)))
print(paste("Carollia - Ficus:", round(cor_carollia$cor_ficus, 3)))

# 8. GUARDAR RESULTADOS DEL ANÁLISIS -----------------------------------------

resultados_analisis <- list(
  t_test = t_test,
  anova_veg = summary(anova_veg),
  correlaciones = list(
    Artibeus = cor_artibeus,
    Carollia = cor_carollia
  ),
  figuras = c(
    "01_abundancia_por_vegetacion.png",
    "02_dinamica_temporal.png",
    "03_relacion_frutos_abundancia.png",
    "04_matriz_correlaciones.png",
    "05_abundancia_por_localidad.png"
  )
)

saveRDS(resultados_analisis, "ecologia_interacciones/resultados/analisis_exploratorio.rds")
cat("\n💾 Resultados guardados en 'ecologia_interacciones/resultados/analisis_exploratorio.rds'\n")

# 9. MENSAJE FINAL -----------------------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("✅ SCRIPT 02 COMPLETADO EXITOSAMENTE\n")
cat("\n", rep("=", 60), "\n", sep = '')
cat("\n📌 Figuras generadas (carpeta 'ecologia_interacciones/figuras/'):\n")
for (fig in resultados_analisis$figuras) {
  cat(paste0("   - ", fig, "\n"))
}
cat("\n🚀 Puedes proceder con el Script 03: ecologia_interacciones/scripts/03_nicho_superposicion.R\n")
