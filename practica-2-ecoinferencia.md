Untitled
================

### **Práctica II – Eco-Inferencia: Modelando la relación clima-vegetación con R**

## **Unidad II – Ecosistemas y sus componentes**

- Factores abióticos
- Factores bióticos
- Relación entre factores abióticos y bióticos
- Biomas: características y distribución
- Ecosistemas: tipos, características y amenazas

**Objetivos de aprendizaje:**

1.  **Relacionar** factores abióticos (clima) con la distribución de
    biomas, utilizando datos simulados como evidencia.
2.  **Analizar** un set de datos simple utilizando R (funciones base de
    graficación y resumen) para identificar patrones ecológicos.
3.  **Argumentar** y defender, en una discusión grupal, la clasificación
    de un ecosistema en un bioma específico, basándose en la
    interpretación de sus propios gráficos y la literatura
    proporcionada.
4.  **Sintetizar** información de diferentes fuentes (datos analizados y
    literatura) para construir una explicación coherente sobre las
    relaciones entre factores bióticos y abióticos.

Hoy no recibirán la respuesta, sino que la construirán. El objetivo es
ser “ecólogos detectives” que usan datos y teoría para descubrir qué
bioma se esconde tras cada set de datos.

- Diagrama de Whittaker (clasificación de biomas por temperatura y
  precipitación)
- Relación fundamental: Clima (factores abióticos) + Suelo -\> Determina
  el tipo de vegetación (factor biótico) -\> Define el bioma.
- Concepto de “factores limitantes” (ej. precipitación como limitante en
  pastizales vs. bosques).

No se espera que programen, sino que *ejecuten* y *observen*.

Muestra las líneas clave:

- `datos <- read.csv("localidad_X.csv")` (cargar datos)
- `plot(datos$Temperatura_Media_Anual, datos$Precipitacion_Total_Anual)`
  (hacer gráfico)
- `summary(datos)` (estadística descriptiva) Enfatiza: “La computadora
  es su herramienta para ver el patrón. Su cerebro es para
  interpretarlo.”

**Fase 2: Desarrollo - Trabajo en Grupo (60 minutos)**

1.  **(5 min) Formación de grupos y asignación:** Se forman 3 grupos (2
    grupos de 2 y 1 grupo de 3, para cubrir las 3 localidades). Se
    asigna a cada grupo un misterio (Localidad X, Y o Z). El docente
    comparte los archivos (script y CSV) por un método offline (carpeta
    compartida en el aula, USB, o si el internet lo permite, descarga
    directa de Google Drive).
2.  **(40 min) Análisis y construcción de hipótesis:** Los grupos
    trabajan autónomamente. Deben:
    - Cargar sus datos en R y ejecutar el script.
    - Observar el gráfico: ¿Dónde se agrupan los puntos en el espacio
      temperatura-precipitación?
    - Calcular con R: ¿Cuál es la temperatura promedio? ¿Y la
      precipitación total? ¿Hay mucha variabilidad?
    - **Tarea clave:** Contrastar su gráfico y resúmenes con la
      literatura (diagramas de Whittaker en PDFs). ¿A qué bioma se
      parece más su localidad? ¿Por qué? Deben anotar 3 evidencias que
      respalden su conclusión.
    - Preparar una mini-presentación de 5 minutos para el resto de la
      clase. Deben mostrar su gráfico generado en R y explicar su
      razonamiento.
3.  **(15 min) Ronda de asesoría:** El docente circula entre los grupos,
    resolviendo dudas técnicas mínimas de R, pero sobre todo desafiando
    sus conclusiones: “¿Por qué descartan que sea un bosque lluvioso?”,
    “Miren la especie dominante en sus datos, ¿qué les sugiere?”.

**Fase 3: Socialización y Cierre (30 minutos)**

1.  **(15 min) Presentaciones grupales:** Cada grupo tiene 5 minutos
    para presentar sus conclusiones. Deben mostrar su gráfico de R y
    argumentar su clasificación del bioma. Es crucial que el docente
    fomente un ambiente de respeto y curiosidad.
2.  **(10 min) Discusión plenaria:** El docente guía la discusión final:
    - “El grupo de la Sabana tuvo una temperatura alta y precipitación
      media, pero en sus datos, ¿la lluvia era igual todos los meses?
      (señalando la variabilidad). ¿Cómo influye esa estacionalidad en
      el tipo de vegetación (pastos vs. bosque)?”
    - “Comparamos el gráfico de Sabana con el de Bosque Templado. Aunque
      tengan precipitaciones similares, la temperatura es muy diferente.
      ¿Qué factor es más importante aquí para definir el bioma?”
    - El docente conecta las presentaciones, formalizando los conceptos:
      “Lo que han hecho hoy es exactamente la lógica de la ecología:
      usar datos para inferir patrones. Han visto cómo la relación entre
      factores abióticos y bióticos (clima y vegetación) define los
      biomas que estudiamos en la teoría.”
3.  **(5 min) Síntesis y tarea:** El docente resume las ideas fuerza y
    conecta la actividad con la próxima clase sobre “Amenazas a
    ecosistemas”. “Ahora que saben qué condiciones necesita un bosque
    templado, ¿qué creen que pasaría si la temperatura aumenta 2°C?”.

------------------------------------------------------------------------

### **Guía de preguntas y consignas para los estudiantes**

**(Entregado por grupo al inicio de la Fase 2)**

**¡Bienvenidos, Eco-Detectives!**

Su misión, si deciden aceptarla, es descubrir la identidad de un bioma
misterioso. Se les ha entregado un set de datos (`localidad_X.csv`) con
mediciones de varios años de una localidad secreta. Su laboratorio
portátil (R) les ayudará a analizar la evidencia.

**Consignas:** 1. **Activen su laboratorio:** Abran RStudio. Carguen el
script `analisis_biomas.R` y ejecútenlo paso a paso para cargar y
explorar sus datos. 2. **Interroguen a la evidencia:** - ¿Qué nos dice
el gráfico? Marquen en el diagrama de Whittaker de sus apuntes dónde
caería esta localidad. - Usen `summary()`: ¿Cuál es el rango de
temperaturas? ¿Y el de precipitación? ¿Son muy variables? - Observen la
columna `Especie_Dominante`. ¿Qué tipo de plantas son? ¿Qué adaptaciones
podrían tener? 3. **Construyan su teoría (Argumento de 3 evidencias):**
Basándose en el análisis de datos y la literatura, ¿a qué bioma
pertenece su localidad? Escriban su conclusión y preparen 3 evidencias
sólidas que la respalden. Piensen como científicos: su evidencia debe
conectar el factor abiótico (clima) con el biótico (vegetación). -
**Evidencia 1 (Basada en temperatura y precipitación):** “La temperatura
media anual de X°C y la precipitación de Y mm se asemejan al rango del
bioma Z según Whittaker…” - **Evidencia 2 (Basada en la
variabilidad/estacionalidad):** “La alta/baja variabilidad en los datos
sugiere…” - **Evidencia 3 (Basada en la especie dominante):** “La
presencia de \[Especie\] es típica de biomas con \[característica\], lo
que refuerza nuestra hipótesis…” 4. **Preparen su informe oral:** En 5
minutos, deberán convencer a la comunidad científica (el resto de la
clase) de su hallazgo. Muestren su gráfico y expliquen su argumento.

------------------------------------------------------------------------

### **Sugerencia de Evaluación Formativa**

La evaluación debe ser continua y centrada en el proceso, no en un
producto final correcto/incorrecto. Se sugiere una **lista de cotejo**
que el docente utiliza mientras observa a los grupos y durante las
presentaciones.

| Criterio                          | Lo hace con solidez (2 pts)                                                                                                          | Lo hace parcialmente (1 pt)                                                                     | No lo hace (0 pts)                                                      |
|:----------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------|
| **Uso de R como herramienta**     | Ejecuta el script sin dificultad y utiliza los outputs (gráfico, summary) para guiar su análisis.                                    | Ejecuta el script pero necesita ayuda para interpretar los outputs.                             | Se enfoca en el código y no logra usar los resultados para el análisis. |
| **Análisis e Interpretación**     | Conecta correctamente los patrones de los datos (temperatura, precipitación) con las características de los biomas de la literatura. | Reconoce los patrones en los datos pero tiene dificultades para asociarlos a un bioma concreto. | Describe los datos sin conectarlos a los conceptos ecológicos.          |
| **Construcción del Argumento**    | El argumento integra al menos dos líneas de evidencia (datos y literatura) de forma coherente y lógica.                              | El argumento se basa en una sola línea de evidencia o es débil.                                 | No presenta un argumento claro, solo una afirmación.                    |
| **Participación en la Discusión** | El grupo presenta con claridad y participa activamente en la discusión plenaria, escuchando a los demás.                             | El grupo presenta pero no interactúa en la discusión.                                           | El grupo no logra comunicar sus ideas.                                  |

------------------------------------------------------------------------

### **Variantes o Ajustes**

- **Si un grupo termina muy rápido:** El docente puede plantearle una
  pregunta de profundización: “Muy bien, han identificado el bioma.
  Ahora, basándose en las amenazas que vimos, ¿cuál creen que es la
  principal presión antrópica sobre *su* bioma y cómo creen que
  afectaría a los datos que acaban de analizar (ej. ¿aumentaría la
  temperatura media, disminuiría la precipitación)?”
- **Si la conexión a internet falla por completo:** El docente debe
  haber previsto una carpeta compartida en las computadoras o haber
  distribuido los archivos en un USB al inicio. El script de R y los
  CSVs son locales, por lo que internet no es necesario para la
  actividad central.
- **Si el nivel de R es más bajo de lo esperado:** El docente puede
  “antropomorfizar” el script, convirtiéndolo en una receta de cocina.
  En lugar de explicar cada función, dice: “La línea 3 es la que
  ‘hornea’ los datos para hacer el gráfico. No se preocupen por los
  ingredientes ahora, solo miren el pastel que les da”. El foco sigue
  siendo la interpretación, no la programación.
- **Para un nivel avanzado:** En lugar de dar el script, se podría dar
  una “chuleta” de comandos de R y que los estudiantes construyan su
  propio pequeño análisis, fomentando la autonomía en la herramienta.

------------------------------------------------------------------------

### **Consigna para Google Classroom**

**Título:** Actividad en clase: Eco-Inferencia (Traer laptop)

**<Estimad@s> estudiantes,**

La próxima clase pondremos en práctica nuestros conocimientos de la
Unidad II. Serán **ecólogos por un día** y utilizarán datos reales
(simulados) para inferir a qué bioma pertenece una localidad misteriosa.

**Objetivo:** Aplicar los conceptos de factores abióticos y bióticos, y
dar nuestros primeros pasos en R para analizar datos ecológicos.

**Preparación (IMPORTANTE):** 1. **Traigan su laptop** con **R** y
**RStudio** ya instalados y funcionando. Si tienen problemas con la
instalación, avísenme con anticipación para resolverlo antes de la
clase. 2. Repasen los **PDFs de la Unidad II**, en especial las
secciones sobre **Biomas (clasificación de Whittaker)** y la **relación
clima-vegetación**. Esto les dará la base teórica para resolver el
misterio.

**Dinámica:** Trabajarán en grupos pequeños. Se les entregará un script
de R y un archivo de datos. Siguiendo las consignas, deberán: - Usar R
para graficar y resumir sus datos. - Contrastar sus resultados con la
literatura. - Construir un argumento sólido para defender su conclusión
ante el resto de la clase.

No se preocupen si es su primera vez con R. La actividad está diseñada
para que aprendan haciendo, y yo estaré ahí para guiarlos. El foco
estará en la **interpretación ecológica**, no en la programación.

¡Los espero! Será una clase dinámica y desafiante.
