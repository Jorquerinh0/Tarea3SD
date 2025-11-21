# Tarea 3: Análisis Lingüístico Offline con Hadoop y Pig

Este proyecto implementa un servicio de análisis batch para procesar grandes volúmenes de texto utilizando el ecosistema de **Apache Hadoop** (HDFS, YARN, MapReduce) y **Apache Pig**. 

El objetivo es comparar el vocabulario y patrones lingüísticos entre respuestas humanas históricas (Yahoo! Answers) y respuestas sintéticas generadas por un LLM (Gemini).

## Integrantes
* Vicente Jorquera

## Requisitos Previos
* **Docker** (versión 19.03 o superior)
* **Docker Compose**
* **Git**

## Estructura del Repositorio
* `docker-compose.yml`: Orquestación del clúster Hadoop (Namenode, Datanode, ResourceManager, NodeManager) y el cliente Pig.
* `Dockerfile`: Definición de la imagen para el cliente de Pig (basada en Hadoop con Pig 0.17.0).
* `/data`: Carpeta compartida con el contenedor. Contiene:
    * `analisis.pig`: Script en Pig Latin para el procesamiento ETL (Tokenización, Limpieza, WordCount).
    * `llm.txt`: Dataset de respuestas de la IA.
    * `stopwords.txt`: Lista de palabras vacías para filtrado..

## Instrucciones de Instalación y Despliegue

### 1. Clonar el repositorio
git clone [https://github.com/Jorquerinh0/Tarea3SD.git](https://github.com/Jorquerinh0/Tarea3SD.git)
cd Tarea3SD


### 2. Paso Crítico: Archivos Grandes (No incluidos en el repo)

Debido a las limitaciones de tamaño de GitHub, los siguientes archivos deben ser descargados/copiados manualmente antes de iniciar:

**pig-0.17.0.tar.gz**: Descargar de los archivos del curso o mirrors de Apache y colocar en la raíz del proyecto (junto al Dockerfile).

**humanas.txt**: Colocar el dataset grande en la carpeta /data.

### 3. Levantar el Clúster
Construir las imágenes e iniciar los contenedores:

docker-compose up -d --build

Esperar unos segundos hasta que todos los servicios estén en estado "Healthy" y "Up". Puede verificarlo con docker ps.


## Instrucciones de Ejecución

### 1. Acceder al Cliente
Entrar a la terminal del contenedor cliente:

docker exec -it pig-client bash

### 2. Ingesta de Datos (HDFS)

Una vez dentro del contenedor, crear los directorios en el sistema de archivos distribuido y cargar los datos:

# Crear directorio de entrada
hdfs dfs -mkdir -p /input

# Subir archivos desde local (/data) a HDFS (/input)
hdfs dfs -put /data/humanas.txt /input/
hdfs dfs -put /data/llm.txt /input/
hdfs dfs -put /data/stopwords.txt /input/

### 3. Ejecutar Análisis (Scripts de Pig)

# A. Procesar Respuestas del LLM:

pig -param INPUT_FILE='/input/llm.txt' -param OUTPUT_DIR='/output/llm_res' -param STOPWORDS='/input/stopwords.txt' /data/analisis.pig

# B. Procesar Respuestas Humanas: (Este proceso puede tomar varios minutos dependiendo de los recursos asignados a Docker)

pig -param INPUT_FILE='/input/humanas.txt' -param OUTPUT_DIR='/output/humanas_res' -param STOPWORDS='/input/stopwords.txt' /data/analisis.pig

### 4. Ver Resultados

Para visualizar el Top de palabras más frecuentes directamente en la terminal:

# Ver resultados LLM
hdfs dfs -cat /output/llm_res/part-r-00000 | head -n 20

# Ver resultados Humanos
hdfs dfs -cat /output/humanas_res/part-r-00000 | head -n 20

Para extraer los resultados a un CSV local (en la carpeta data de su máquina):

hdfs dfs -getmerge /output/llm_res /data/resultados_llm_final.csv
hdfs dfs -getmerge /output/humanas_res /data/resultados_humanas_final.csv

## Tecnologías Utilizadas
**Hadoop 3.2.1**: Almacenamiento distribuido y gestión de recursos.
**Apache Pig 0.17.0**: Abstracción de MapReduce para procesamiento de datos.
**Docker**: Contenerización y despliegue.