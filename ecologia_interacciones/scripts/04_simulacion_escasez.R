# ============================================================================
# PRÁCTICA ECOLOGÍA GENERAL
# Script 04: Simulación de escenarios de escasez de recursos
# ============================================================================
# Este script simula diferentes escenarios de disponibilidad de recursos
# para evaluar cómo cambia la superposición de nicho bajo condiciones
# de estrés ambiental (sequía, reducción de frutos).
# ============================================================================

# 1. CONFIGURACIÓN INICIAL ---------------------------------------------------

# Limpiar el entorno de trabajo
rm(list = ls())

# Cargar librerías
library(tidyverse)
library(ggplot2)
library(patchwork)  # Para combinar gráficos

# Cargar datos procesados
if (file.exists("ecologia_interacciones/datos/datos_procesados.rds")) {
  datos <- readRDS("ecologia_interacciones/datos/datos_procesados.rds")
  cat("✅ Datos cargados desde 'ecologia_interacciones/datos/datos_procesados.rds'\n")
} else {
  stop("❌ No se encuentra el archivo 'ecologia_interacciones/datos/datos_procesados.rds'. Ejecuta primero el Script 01.")
}

# 2. FUNCIONES PARA CÁLCULO DE ÍNDICES ---------------------------------------

# Función para calcular el índice de superposición de Pianka
calcular_pianka <- function(p1, p2) {
  numerador <- sum(p1 * p2)
  denominador <- sqrt(sum(p1^2) * sum(p2^2))
  if (denominador == 0) return(0)
  return(numerador / denominador)
}

# Función para calcular proporciones de uso de recursos
calcular_uso_recursos <- function(data) {
  data %>%
    group_by(especie) %>%
    summarise(
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
}

# 3. DEFINICIÓN DE ESCENARIOS DE SIMULACIÓN ----------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("🌍 SIMULACIÓN DE ESCENARIOS DE ESCASEZ\n")
cat("\n", rep("=", 60), "\n", sep = '')

# # Definir los factores de reducción a simular
# factores_reduccion <- c(1.0, 0.7, 0.5, 0.3, 0.2, 0.1)
# nombres_escenarios <- c("Normal", "Escasez 30%", "Escasez 50%",
#                         "Escasez 70%", "Escasez 80%", "Escasez 90%")
# 
# cat("\n📌 Escenarios simulados:\n")
# for (i in 1:length(factores_reduccion)) {
#   cat(paste0("   ", i, ". ", nombres_escenarios[i],
#              " (reducción del ", (1 - factores_reduccion[i]) * 100, "%)\n"))
# }



# Definir escenarios con escasez diferencial por recurso
escenarios <- data.frame(
  Escenario = c(
    "Normal",
    "Escasez homogénea 30%",
    "Escasez homogénea 50%",
    "Escasez selectiva Piper 70%",
    "Escasez selectiva Ficus 70%",
    "Escasez extrema Piper 90%"
  ),
  factor_piper = c(1.0, 0.7, 0.5, 0.3, 1.0, 0.1),
  factor_ficus = c(1.0, 0.7, 0.5, 1.0, 0.3, 1.0)
)

cat("\n📌 Escenarios simulados:\n")
for (i in 1:nrow(escenarios)) {
  cat(
    paste0(
      "   ", i, ". ", escenarios$Escenario[i],
      " | Piper = ", escenarios$factor_piper[i],
      " ; Ficus = ", escenarios$factor_ficus[i], "\n"
    )
  )
}




# 4. SIMULACIÓN DE ESCENARIOS ------------------------------------------------

# resultados_simulacion <- data.frame()
# 
# for (i in 1:length(factores_reduccion)) {
#   factor <- factores_reduccion[i]
#   escenario <- nombres_escenarios[i]
#   
#   # Aplicar reducción a la disponibilidad de frutos
#   datos_sim <- datos %>%
#     mutate(
#       piper_disponible = piper_disponible * factor,
#       ficus_disponible = ficus_disponible * factor,
#       frutos_totales = frutos_disponibles_kg_ha * factor
#     )
#   
#   # Calcular uso de recursos
#   uso <- calcular_uso_recursos(datos_sim)
#   
#   # Extraer proporciones
#   p_artibeus <- uso %>%
#     filter(especie == "Artibeus_jamaicensis") %>%
#     select(prop_piper, prop_ficus) %>%
#     as.numeric()
#   
#   p_carollia <- uso %>%
#     filter(especie == "Carollia_perspicillata") %>%
#     select(prop_piper, prop_ficus) %>%
#     as.numeric()
#   
#   # Calcular índices
#   pianka <- calcular_pianka(p_artibeus, p_carollia)
#   
#   # Almacenar resultados
#   resultados_simulacion <- rbind(resultados_simulacion,
#                                  data.frame(
#                                    Escenario = escenario,
#                                    Factor = factor,
#                                    Reduccion_porcentaje = (1 - factor) * 100,
#                                    Indice_Pianka = pianka,
#                                    Prop_Piper_Artibeus = p_artibeus[1],
#                                    Prop_Ficus_Artibeus = p_artibeus[2],
#                                    Prop_Piper_Carollia = p_carollia[1],
#                                    Prop_Ficus_Carollia = p_carollia[2]
#                                  ))
# }




resultados_simulacion <- data.frame()

for (i in 1:nrow(escenarios)) {
  
  escenario <- escenarios$Escenario[i]
  factor_piper <- escenarios$factor_piper[i]
  factor_ficus <- escenarios$factor_ficus[i]
  
  # Aplicar reducción diferencial a la disponibilidad de frutos
  datos_sim <- datos %>%
    mutate(
      piper_disponible = piper_disponible * factor_piper,
      ficus_disponible = ficus_disponible * factor_ficus,
      frutos_totales = piper_disponible + ficus_disponible
    )
  
  # Calcular uso de recursos
  uso <- calcular_uso_recursos(datos_sim)
  
  # Extraer proporciones
  p_artibeus <- uso %>%
    filter(especie == "Artibeus_jamaicensis") %>%
    select(prop_piper, prop_ficus) %>%
    as.numeric()
  
  p_carollia <- uso %>%
    filter(especie == "Carollia_perspicillata") %>%
    select(prop_piper, prop_ficus) %>%
    as.numeric()
  
  # Calcular índice
  pianka <- calcular_pianka(p_artibeus, p_carollia)
  
  # Reducción media solo para fines de gráfico/resumen
  reduccion_media <- (1 - mean(c(factor_piper, factor_ficus))) * 100
  
  resultados_simulacion <- rbind(
    resultados_simulacion,
    data.frame(
      Escenario = escenario,
      Factor_Piper = factor_piper,
      Factor_Ficus = factor_ficus,
      Reduccion_porcentaje = reduccion_media,
      Indice_Pianka = pianka,
      Prop_Piper_Artibeus = p_artibeus[1],
      Prop_Ficus_Artibeus = p_artibeus[2],
      Prop_Piper_Carollia = p_carollia[1],
      Prop_Ficus_Carollia = p_carollia[2]
    )
  )
}


# Calcular cambio relativo respecto al escenario normal
indice_normal <- resultados_simulacion$Indice_Pianka[1]
resultados_simulacion <- resultados_simulacion %>%
  mutate(
    Cambio_porcentual = (Indice_Pianka - indice_normal) / indice_normal * 100
  )

# 5. MOSTRAR RESULTADOS DE SIMULACIÓN ----------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📊 RESULTADOS DE SIMULACIÓN\n")
cat("\n", rep("=", 60), "\n", sep = '')

cat("\n📈 Evolución del índice de superposición de Pianka:\n")
print(resultados_simulacion[, c("Escenario", "Indice_Pianka", "Cambio_porcentual")])

# 6. VISUALIZACIÓN DE RESULTADOS ---------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📊 GENERANDO VISUALIZACIONES\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Gráfico 1: Evolución del índice de superposición
g1_evolucion <- ggplot(resultados_simulacion,
                       aes(x = Reduccion_porcentaje, y = Indice_Pianka)) +
  geom_line(size = 1.2, color = "#2c7bb6") +
  geom_point(size = 3, color = "#2c7bb6") +
  geom_hline(yintercept = 0.3, linetype = "dashed", color = "gray50", alpha = 0.7) +
  geom_hline(yintercept = 0.7, linetype = "dashed", color = "gray50", alpha = 0.7) +
  annotate("text", x = 85, y = 0.32, label = "Umbral bajo (0.3)", size = 3, color = "gray40") +
  annotate("text", x = 85, y = 0.72, label = "Umbral alto (0.7)", size = 3, color = "gray40") +
  labs(
    title = "Respuesta del índice de superposición de nicho a la escasez",
    # subtitle = "Aumento de la superposición a medida que disminuyen los recursos",
    subtitle = "Respuesta de la superposición de nicho ante distintos escenarios de escasez",
    x = "Reducción de disponibilidad de frutos (%)",
    y = "Índice de superposición de Pianka",
    caption = "Líneas punteadas: umbrales de interpretación (0.3 = baja, 0.7 = alta)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    axis.text = element_text(size = 10),
    axis.title = element_text(face = "bold")
  ) +
  xlim(0, 100) +
  ylim(0, 1)

print(g1_evolucion)
ggsave("ecologia_interacciones/figuras/09_evolucion_superposicion.png",
       g1_evolucion, width = 8, height = 6, dpi = 300)
cat("✅ Figura 09 guardada: 'ecologia_interacciones/figuras/09_evolucion_superposicion.png'\n")

# Gráfico 2: Cambio en las proporciones de uso por especie
nicho_todos <- data.frame()

for (i in 1:nrow(resultados_simulacion)) {
  temp <- data.frame(
    Escenario = resultados_simulacion$Escenario[i],
    Reduccion = resultados_simulacion$Reduccion_porcentaje[i],
    Especie = c("Artibeus", "Artibeus", "Carollia", "Carollia"),
    Recurso = c("Piper", "Ficus", "Piper", "Ficus"),
    Proporcion = c(resultados_simulacion$Prop_Piper_Artibeus[i],
                   resultados_simulacion$Prop_Ficus_Artibeus[i],
                   resultados_simulacion$Prop_Piper_Carollia[i],
                   resultados_simulacion$Prop_Ficus_Carollia[i])
  )
  nicho_todos <- rbind(nicho_todos, temp)
}

# Ordenar escenarios por nivel de reducción
# nicho_todos$Escenario <- factor(nicho_todos$Escenario,
#                                 levels = nombres_escenarios)





nicho_todos$Escenario <- factor(
  nicho_todos$Escenario,
  levels = escenarios$Escenario
)






g2_nicho_evolucion <- ggplot(nicho_todos,
                             aes(x = Recurso, y = Proporcion, fill = Especie)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  facet_wrap(~Escenario, nrow = 2) +
  labs(
    title = "Cambio en la partición de nicho bajo escenarios de escasez",
    x = "Tipo de recurso",
    y = "Proporción de uso",
    fill = "Especie"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    strip.text = element_text(face = "bold", size = 10),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  scale_fill_manual(
    values = c("Artibeus" = "#2c7bb6", "Carollia" = "#d7191c"),
    labels = c("Artibeus jamaicensis", "Carollia perspicillata")
  ) +
  ylim(0, 1)

print(g2_nicho_evolucion)
ggsave("ecologia_interacciones/figuras/10_nicho_evolucion_escasez.png",
       g2_nicho_evolucion, width = 12, height = 8, dpi = 300)
cat("✅ Figura 10 guardada: 'ecologia_interacciones/figuras/10_nicho_evolucion_escasez.png'\n")

# Gráfico 3: Resumen comparativo (solo escenarios clave)
# escenarios_clave <- c("Normal", "Escasez 50%", "Escasez 80%")


escenarios_clave <- c(
  "Normal",
  "Escasez homogénea 50%",
  "Escasez selectiva Piper 70%"
)


datos_clave <- resultados_simulacion %>%
  filter(Escenario %in% escenarios_clave)

g3_comparacion_clave <- ggplot(datos_clave,
                               aes(x = Escenario, y = Indice_Pianka, fill = Escenario)) +
  geom_bar(stat = "identity", width = 0.6, alpha = 0.8) +
  geom_text(aes(label = round(Indice_Pianka, 3)), vjust = -0.5, size = 4) +
  labs(
    title = "Comparación de superposición de nicho en escenarios clave",
    subtitle = "Normal vs. escasez moderada (50%) vs. escasez severa (80%)",
    x = "Escenario",
    y = "Índice de superposición de Pianka"
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

print(g3_comparacion_clave)
ggsave("ecologia_interacciones/figuras/11_comparacion_escenarios_clave.png",
       g3_comparacion_clave, width = 9, height = 6, dpi = 300)
cat("✅ Figura 11 guardada: 'ecologia_interacciones/figuras/11_comparacion_escenarios_clave.png'\n")

# 7. GRÁFICO COMBINADO (OPCIONAL) -------------------------------------------

# Combinar los tres gráficos principales
grafico_combinado <- (g1_evolucion + g3_comparacion_clave) /
  g2_nicho_evolucion +
  plot_annotation(
    title = "Análisis completo: Efecto de la escasez en la superposición de nicho",
    theme = theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5))
  )

ggsave("ecologia_interacciones/figuras/12_analisis_completo_escasez.png",
       grafico_combinado, width = 16, height = 12, dpi = 300)
cat("✅ Figura 12 guardada: 'ecologia_interacciones/figuras/12_analisis_completo_escasez.png'\n")

# 8. ANÁLISIS DE SENSIBILIDAD ------------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📈 ANÁLISIS DE SENSIBILIDAD\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Calcular el punto de inflexión (dónde supera el umbral de 0.7)
punto_inflexion <- NULL
for (i in 1:(nrow(resultados_simulacion) - 1)) {
  if (resultados_simulacion$Indice_Pianka[i] < 0.7 &&
      resultados_simulacion$Indice_Pianka[i + 1] >= 0.7) {
    punto_inflexion <- resultados_simulacion$Reduccion_porcentaje[i + 1]
    break
  }
}

if (!is.null(punto_inflexion)) {
  cat(paste0("\n🔍 Punto de inflexión: El índice supera 0.7 cuando la reducción de recursos es del ",
             punto_inflexion, "%\n"))
  cat("   → A partir de este punto, se considera que existe ALTA SUPERPOSICIÓN de nicho\n")
  cat("   → Potencial aumento significativo de competencia interespecífica\n")
} else {
  cat("\n🔍 No se alcanzó el umbral de 0.7 en los escenarios simulados\n")
}

# 9. GUARDAR RESULTADOS ------------------------------------------------------

resultados_completos <- list(
  simulacion = resultados_simulacion,
  punto_inflexion = punto_inflexion,
  figuras_generadas = c(
    "09_evolucion_superposicion.png",
    "10_nicho_evolucion_escasez.png",
    "11_comparacion_escenarios_clave.png",
    "12_analisis_completo_escasez.png"
  )
)

saveRDS(resultados_completos, "ecologia_interacciones/resultados/resultados_simulacion.rds")
cat("\n💾 Resultados guardados en ecologia_interacciones/'resultados/resultados_simulacion.rds'\n")

# 10. CONCLUSIONES DE LA SIMULACIÓN ------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("📌 CONCLUSIONES DE LA SIMULACIÓN\n")
cat("\n", rep("=", 60), "\n", sep = '')

# Obtener valores clave
normal <- resultados_simulacion$Indice_Pianka[1]
escasez_50 <- resultados_simulacion$Indice_Pianka[3]
escasez_80 <- resultados_simulacion$Indice_Pianka[5]

cat("\n🔬 Resumen de hallazgos:\n")
cat(paste0("   • Escenario normal: Índice de Pianka = ", round(normal, 3),
           " (", ifelse(normal < 0.3, "Baja superposición",
                        ifelse(normal < 0.7, "Superposición moderada", "Alta superposición")), ")\n"))
cat(paste0("   • Escasez 50%: Índice de Pianka = ", round(escasez_50, 3),
           " (", ifelse(escasez_50 < 0.3, "Baja superposición",
                        ifelse(escasez_50 < 0.7, "Superposición moderada", "Alta superposición")), ")\n"))
cat(paste0("   • Escasez 80%: Índice de Pianka = ", round(escasez_80, 3),
           " (", ifelse(escasez_80 < 0.3, "Baja superposición",
                        ifelse(escasez_80 < 0.7, "Superposición moderada", "Alta superposición")), ")\n"))

# cat("\n🌿 Implicaciones ecológicas:\n")
# cat("   • En condiciones normales, las especies muestran partición de nicho,\n")
# cat("     lo que permite la coexistencia sin competencia intensa.\n")
# cat("   • Bajo escenarios de escasez, la superposición aumenta,\n")
# cat("     intensificando la competencia interespecífica.\n")
# cat("   • Esto sugiere que el cambio climático (sequías más frecuentes)\n")
# cat("     podría alterar la estructura de las comunidades de murciélagos.\n")
cat("\n🌿 Implicaciones ecológicas:\n")
cat("   • La respuesta de la superposición depende de si la escasez afecta\n")
cat("     por igual a todos los recursos o de forma selectiva.\n")
cat("   • Cuando la reducción es homogénea, las proporciones de uso tienden\n")
cat("     a mantenerse y el índice de Pianka cambia poco.\n")
cat("   • Cuando la escasez afecta más a un recurso que a otro, la partición\n")
cat("     de nicho puede modificarse y la superposición variar de forma notable.\n")
cat("   • Esto permite evaluar escenarios ecológicamente más realistas de estrés ambiental.\n")

# 11. MENSAJE FINAL ----------------------------------------------------------

cat("\n", rep("=", 60), "\n", sep = '')
cat("✅ SCRIPT 04 COMPLETADO EXITOSAMENTE\n")
cat("\n", rep("=", 60), "\n", sep = '')
cat("\n📌 Todos los scripts han sido ejecutados.\n")
cat("\n📁 Estructura de archivos generados:\n")
cat("   ecologia_interacciones/datos/\n")
cat("   ├── datos_procesados.rds\n")
cat("   └── datos_procesados.csv\n")
cat("   ecologia_interacciones/figuras/\n")
cat("   ├── 01_abundancia_por_vegetacion.png\n")
cat("   ├── 02_dinamica_temporal.png\n")
cat("   ├── 03_relacion_frutos_abundancia.png\n")
cat("   ├── 04_matriz_correlaciones.png\n")
cat("   ├── 05_abundancia_por_localidad.png\n")
cat("   ├── 06_nicho_particion.png\n")
cat("   ├── 07_nicho_dispersion.png\n")
cat("   ├── 08_comparacion_indices.png\n")
cat("   ├── 09_evolucion_superposicion.png\n")
cat("   ├── 10_nicho_evolucion_escasez.png\n")
cat("   ├── 11_comparacion_escenarios_clave.png\n")
cat("   └── 12_analisis_completo_escasez.png\n")
cat("   ecologia_interacciones/resultados/\n")
cat("   ├── resumenes_descriptivos.rds\n")
cat("   ├── analisis_exploratorio.rds\n")
cat("   ├── resultados_nicho.rds\n")
cat("   └── resultados_simulacion.rds\n")
cat("\n🚀 Ahora puedes proceder con la elaboración del informe.\n")