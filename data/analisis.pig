/*
 * Script de Análisis de Vocabulario (Tarea 3 SD)
 * Ejecución típica:
 * pig -param INPUT_FILE=/input/humanas.txt -param OUTPUT_DIR=/output/humanas -param STOPWORDS=/input/stopwords.txt /data/analisis.pig
 */

-- Definir valores por defecto por si acaso
%default STOPWORDS '/input/stopwords.txt'

-- 1. Cargar datos
raw_lines = LOAD '$INPUT_FILE' USING PigStorage('\n') AS (line:chararray);
stop_lines = LOAD '$STOPWORDS' USING PigStorage('\n') AS (stopword:chararray);

-- 2. Limpieza previa: minúsculas
lower_lines = FOREACH raw_lines GENERATE LOWER(line) AS line;

-- 3. Reemplazar puntuación por espacios (elimina puntos, comas, signos)
--    Mantenemos solo letras a-z y números.
clean_lines = FOREACH lower_lines GENERATE REPLACE(line, '[^a-z0-9\\s]', ' ') AS line;

-- 4. Tokenizar (separar por espacios)
tokens = FOREACH clean_lines GENERATE FLATTEN(TOKENIZE(line)) AS word;

-- 5. Filtrar tokens vacíos o muy cortos (opcional pero recomendado)
valid_tokens = FILTER tokens BY SIZE(word) > 1;

-- 6. Filtrar Stopwords usando un JOIN replicado (más rápido para archivos pequeños como stopwords)
--    Hacemos un Left Join y nos quedamos con lo que NO hizo match.
joined = JOIN valid_tokens BY word LEFT, stop_lines BY stopword USING 'replicated';
filtered_words = FILTER joined BY stop_lines::stopword IS NULL;

-- 7. Proyectar solo la palabra limpia
final_words = FOREACH filtered_words GENERATE valid_tokens::word AS word;

-- 8. Contar palabras
grouped_words = GROUP final_words BY word;
word_counts = FOREACH grouped_words GENERATE group AS word, COUNT(final_words) AS count;

-- 9. Ordenar de mayor a menor frecuencia (Top N)
ordered_counts = ORDER word_counts BY count DESC;

-- 10. Guardar
STORE ordered_counts INTO '$OUTPUT_DIR' USING PigStorage(',');
