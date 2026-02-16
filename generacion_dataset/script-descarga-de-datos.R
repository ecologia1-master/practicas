# ==========================================================
# Generador de datasets de biomas (Whittaker)
# - Datos climáticos reales (WorldClim vía geodata)
# - Clasificación usando polígonos Whittaker
# - Sin ggbiome ni dependencias problemáticas
# ==========================================================

# ---------- 1. Paquetes ----------
# devtools::install_github("valentinitnelav/plotbiomes")
pkgs <- c("terra", "geodata", "dplyr", "readr", "ggplot2", "plotbiomes")
inst <- pkgs[!pkgs %in% installed.packages()[,1]]
if(length(inst)) install.packages(inst)

library(terra)
library(geodata)
library(dplyr)
library(readr)
library(ggplot2)
library(plotbiomes)

set.seed(2026)

out_dir <- "salida_biomas"
dir.create(out_dir, showWarnings = FALSE)

# ---------- 2. Coordenadas de prueba ----------
locs <- data.frame(
  Localidad = c("localidad_A","localidad_B","localidad_C",
                "localidad_D","localidad_E","localidad_F"),
  lon = c(-60, 10, 37, -150, 0, -71),
  lat = c(-3, 20, -2, 61, 52, -49)
)

# ---------- 3. Descargar WorldClim (una sola vez) ----------
bio <- geodata::worldclim_global(var="bio", res=10, path=".")

# BIO1 = temperatura media anual (°C)
# BIO12 = precipitación anual (mm)

bio1 <- bio[[1]]
bio1
bio12 <- bio[[12]]

# ---------- 4. Extraer clima ----------
pts <- vect(locs, geom=c("lon","lat"), crs="EPSG:4326")

clima <- extract(c(bio1, bio12), pts)

locs$MAT <- round(clima[,2],1)
locs$MAP_mm <- round(clima[,3])
locs$MAP_cm <- locs$MAP_mm/10

# ---------- 5. Clasificar bioma ----------
# Usamos polígonos clásicos del diagrama de Whittaker

biomes_poly <- plotbiomes::Whittaker_biomes

# clasificar_bioma <- function(temp, prec_cm) {
#   point <- data.frame(temp=temp, prec=prec_cm)
#   for(i in 1:nrow(biomes_poly)) {
#     poly <- biomes_poly[i,]
#     if(sp::point.in.polygon(point$temp, point$prec,
#                             poly$temp, poly$prec) > 0) {
#       return(as.character(poly$biome))
#     }
#   }
#   return("Indeterminado")
# }


# Necesita sp
if(!"sp" %in% installed.packages()[,1]) install.packages("sp")
library(sp)



# ---------- 5. Clasificar bioma (Whittaker) ----------

# Necesita sp
if(!"sp" %in% installed.packages()[,1]) install.packages("sp")
library(sp)

biomes_poly <- plotbiomes::Whittaker_biomes

# Importante: Whittaker_biomes tiene MUCHAS filas por bioma (vértices).
# Por tanto, hay que agrupar por 'biome' y usar todos los puntos.

clasificar_bioma <- function(temp_c, prec_cm) {
  
  # si cae fuera del rango típico del gráfico, marcar indeterminado
  if (is.na(temp_c) || is.na(prec_cm)) return(NA_character_)
  
  biomas <- unique(biomes_poly$biome)
  
  for (b in biomas) {
    poly <- biomes_poly[biomes_poly$biome == b, ]
    
    inside <- sp::point.in.polygon(
      point.x = temp_c,
      point.y = prec_cm,
      pol.x   = poly$temp_c,
      pol.y   = poly$precp_cm
    )
    
    if (inside > 0) return(as.character(b))
  }
  
  "Indeterminado"
}

locs$Bioma <- mapply(clasificar_bioma, locs$MAT, locs$MAP_cm)
locs$Bioma

# ---------- 6. Especies didácticas ----------
dominantes <- c(
  "Tropical rain forest"="Swietenia macrophylla",
  "Savanna"="Acacia spp.",
  "Subtropical desert"="Larrea tridentata",
  "Temperate seasonal forest"="Quercus spp.",
  "Temperate rain forest"="Pseudotsuga menziesii",
  "Woodland/shrubland"="Quercus coccifera",
  "Temperate grassland/desert"="Stipa spp.",
  "Boreal forest"="Picea mariana",
  "Tundra"="Betula nana"
)

locs$Especie_Dominante <- dominantes[locs$Bioma]
locs$Especie_Dominante[is.na(locs$Especie_Dominante)] <- "Especie típica del bioma"

# ---------- 7. Generar series anuales ----------
years <- 2010:2021

for(i in 1:nrow(locs)) {
  
  temp_series <- rnorm(length(years), locs$MAT[i], 1.2)
  precip_series <- rlnorm(length(years),
                          log(locs$MAP_mm[i]) - 0.02,
                          0.2)
  
  df <- data.frame(
    Localidad = locs$Localidad[i],
    Anio = years,
    Temp_media_C = round(temp_series,1),
    Precip_anual_mm = round(precip_series),
    Bioma_Whittaker = locs$Bioma[i],
    Especie_Dominante = locs$Especie_Dominante[i]
  )
  
  write_csv(df, file.path(out_dir,
                          paste0(locs$Localidad[i],".csv")))
}

# ---------- 8. Guardar resumen ----------
write_csv(locs, file.path(out_dir,
                          "resumen_localidades.csv"))

# ---------- 9. Graficar diagrama ----------
p <- whittaker_base_plot() +
  geom_point(data = locs, aes(x = MAT, y = MAP_cm)) +
  geom_text(data = locs, aes(x = MAT, y = MAP_cm, label = Localidad), nudge_y = 10) +
  labs(
    x = "Temperatura media anual (°C)",
    y = "Precipitación anual (cm)",
    title = "Diagrama de Whittaker"
  )


ggsave(file.path(out_dir, "whittaker_localidades.png"),
       p, width=9, height=6)

cat("\n✔ Todo listo. Archivos creados en carpeta:",
    out_dir,"\n")
