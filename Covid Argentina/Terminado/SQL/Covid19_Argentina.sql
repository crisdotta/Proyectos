-- Cargar los datos a la base de datos
LOAD DATA INFILE 'covid19_argentina.csv' 
INTO TABLE covid19_argentina 
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from covid19_argentina;

-- Copia de la tabla para trabajar 
CREATE TABLE covid19_argentina_copia LIKE covid19_argentina;
INSERT INTO covid19_argentina_copia SELECT * FROM covid19_argentina;

select * from covid19_argentina_copia;

-- Cambiar los tipos de datos de las columnas 
-- Columna fecha
UPDATE covid19_argentina_copia
SET covid19_argentina_copia.﻿fecha = str_to_date(covid19_argentina_copia.﻿fecha,"%Y-%m-%d");
ALTER TABLE covid19_argentina_copia MODIFY COLUMN ﻿fecha DATE;

-- Columna dia_inicio
SELECT cast(dia_inicio AS unsigned) FROM covid19_argentina_copia;
UPDATE covid19_argentina_copia
SET dia_inicio = cast(dia_inicio AS unsigned);
ALTER TABLE covid19_argentina_copia MODIFY COLUMN dia_inicio int;

-- Columna dia_cuarentena
UPDATE covid19_argentina_copia
SET dia_cuarentena = 0
WHERE dia_cuarentena = "";
UPDATE covid19_argentina_copia
SET dia_cuarentena = cast(dia_cuarentena AS unsigned);
ALTER TABLE covid19_argentina_copia MODIFY COLUMN dia_cuarentena int;

-- Columna indice_pobreza
UPDATE covid19_argentina_copia
SET indice_pobreza = cast(indice_pobreza AS float);
ALTER TABLE covid19_argentina_copia MODIFY COLUMN indice_pobreza float;

-- Columna total_casos_pais
UPDATE covid19_argentina_copia
SET total_casos_pais = cast(total_casos_pais AS unsigned);
ALTER TABLE covid19_argentina_copia MODIFY COLUMN total_casos_pais int;
SELECT total_casos_pais FROM covid19_argentina_copia;

-- Columna nuevos_casos
UPDATE covid19_argentina_copia
SET nuevos_casos = cast(nuevos_casos AS unsigned);
ALTER TABLE covid19_argentina_copia MODIFY COLUMN nuevos_casos int;

-- Columna nuevos_fallecidos
UPDATE covid19_argentina_copia
SET nuevos_fallecidos = cast(nuevos_fallecidos AS unsigned);
ALTER TABLE covid19_argentina_copia MODIFY COLUMN nuevos_fallecidos int;

-- Columna total_fallecidos_pais
UPDATE covid19_argentina_copia
SET total_fallecidos_pais = cast(total_fallecidos_pais AS unsigned);
ALTER TABLE covid19_argentina_copia MODIFY COLUMN total_fallecidos_pais int;

-- Columna total_recuperados
SELECT total_recuperados FROM covid19_argentina_copia;
UPDATE covid19_argentina_copia
SET total_recuperados = NULL
WHERE total_recuperados = "";
UPDATE covid19_argentina_copia
SET total_recuperados = substring_index(total_recuperados,",",1)
WHERE total_recuperados IS NOT NULL;
UPDATE covid19_argentina_copia
SET total_recuperados = cast(total_recuperados AS unsigned)
WHERE total_recuperados IS NOT NULL;
ALTER TABLE covid19_argentina_copia MODIFY COLUMN total_recuperados int;

-- Crear otra tabla para hacer el EDA 
CREATE TABLE covid19_argentina_EDA LIKE covid19_argentina_copia;
INSERT INTO covid19_argentina_EDA SELECT * FROM covid19_argentina_copia;

-- Hacer una suma acumulativa de los nuevos casos dependiendo de la provincia 
with cte as (
SELECT *, sum(nuevos_casos) over(partition by provincia order by covid19_argentina_eda.﻿fecha) as suma_acum
from covid19_argentina_eda)
SELECT * FROM cte;
-- Se crea una copia de la tabla para crear la columna de casos_por_provincia, es la unica forma de hacerlo ya que MySQL no acepta UPDATE desde una cte.
CREATE TABLE `covid19_argentina_eda2` (
  `﻿fecha` date DEFAULT NULL,
  `dia_inicio` int DEFAULT NULL,
  `dia_cuarentena` int DEFAULT NULL,
  `provincia` text,
  `semestre` text,
  `indice_pobreza` float DEFAULT NULL,
  `total_casos_pais` int DEFAULT NULL,
  `nuevos_casos` int DEFAULT NULL,
  `nuevos_fallecidos` int DEFAULT NULL,
  `total_fallecidos_pais` int DEFAULT NULL,
  `total_recuperados` int DEFAULT NULL,
  `casos_por_provincia` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO covid19_argentina_eda2 
SELECT *, sum(nuevos_casos) over(partition by provincia order by covid19_argentina_eda.﻿fecha) as suma_acum
from covid19_argentina_eda;
-- La columna tiene mucha falta de datos se tiene que borrar
ALTER TABLE covid19_argentina_eda2
DROP COLUMN total_recuperados;

-- Hacer una suma acumulativa de los nuevos fallecidos dependiendo de la provincia 
with cte as (
SELECT *, sum(nuevos_fallecidos) over(partition by provincia order by covid19_argentina_eda2.﻿fecha) as suma_acum
from covid19_argentina_eda2)
SELECT * FROM cte;
-- Se crea una copia de la tabla para crear la columna de fallecidos_por_provincia, es la unica forma de hacerlo ya que MySQL no acepta UPDATE desde una cte.
CREATE TABLE `covid19_argentina_eda3` (
  `﻿fecha` date DEFAULT NULL,
  `dia_inicio` int DEFAULT NULL,
  `dia_cuarentena` int DEFAULT NULL,
  `provincia` text,
  `semestre` text,
  `indice_pobreza` float DEFAULT NULL,
  `total_casos_pais` int DEFAULT NULL,
  `nuevos_casos` int DEFAULT NULL,
  `nuevos_fallecidos` int DEFAULT NULL,
  `total_fallecidos_pais` int DEFAULT NULL,
  `casos_por_provincia` int DEFAULT NULL,
  `fallecidos_por_provincia` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO covid19_argentina_eda3
SELECT *, sum(nuevos_fallecidos) over(partition by provincia order by covid19_argentina_eda2.﻿fecha) as suma_acum
from covid19_argentina_eda2;



-- -------------------------------------------------------------------------------------------- EXPLORATORY DATA ANALYSIS (EDA) --------------------------------------------------------------------------------------------
SELECT * FROM covid19_argentina_eda3;
-- --------------------------------------------------------------------------------------------           VISTA GENERAL         -------------------------------------------------------------------------------------------- 
-- Fecha y lugar del primer caso de covid 
SELECT min((date_format(covid19_argentina_eda3.﻿fecha, "%d/%m/%Y"))) as primer_caso, provincia
FROM covid19_argentina_eda3;

-- Fecha del primer dia de cuarentena 
SELECT date_format(covid19_argentina_eda3.﻿fecha, "%d/%m/%Y") as primer_dia_cuarentena
FROM covid19_argentina_eda3
WHERE dia_cuarentena = 1
LIMIT 1;
-- Fecha del uiltimo dia de cuarentena
	-- Se averigua el valor mas alto de la columna dia_cuarentena para saber la fecha  
SELECT max(dia_cuarentena)																										
FROM covid19_argentina_eda3;
	-- Una vez averiguado el valor se hace la consulta del ultimo dia de cuarentena
SELECT date_format(covid19_argentina_eda3.﻿fecha, "%d/%m/%Y") as ultimo_dia_cuarentena
FROM covid19_argentina_eda3
WHERE dia_cuarentena = 234
LIMIT 1;
-- Fecha del ultimo registro
SELECT date_format(max(covid19_argentina_eda3.﻿fecha),"%d/%m/%Y") ultimo_registro
FROM covid19_argentina_eda3;

-- Cantidad de casos y fallecidos
SELECT max(total_casos_pais) mayor_cantidad_casos, max(total_fallecidos_pais) mayor_cantidad_fallecidos, round((max(total_fallecidos_pais)/max(total_casos_pais))*100,2) as porcentaje_fallecidos
FROM covid19_argentina_eda3;		

-- Promedio de casos y fallecidos
SELECT avg(nuevos_casos) avg_casos, avg(nuevos_fallecidos) avg_fallecidos
FROM covid19_argentina_eda3;												 
-- --------------------------------------------------------------------------------------------           VISTA POR PROVINCIA          --------------------------------------------------------------------------------------------
-- Resumen de casos en el pais por año y provincia
SELECT year(covid19_argentina_eda3.﻿fecha) anio, provincia, sum(nuevos_casos) as total_casos_por_provincia_y_año
FROM covid19_argentina_eda3
GROUP BY anio, provincia;
-- Resumen de casos en el pais durante la cuarentena separados por provincia
SELECT provincia, sum(nuevos_casos) casos_por_provincia_en_cuarentena
FROM covid19_argentina_eda3
WHERE dia_cuarentena > 0
GROUP BY provincia;
-- Resumen de casos en el pais fuera de la cuarentena separado por provincia
SELECT provincia, sum(nuevos_casos) casos_por_provincia_fuera_cuarentena
FROM covid19_argentina_eda3
WHERE dia_cuarentena = 0
GROUP BY provincia;

-- Resumen de fallecidos en el pais por año y provincia
SELECT year(covid19_argentina_eda3.﻿fecha) anio, provincia, sum(nuevos_fallecidos) as fallecidos_por_anio_provincia
FROM covid19_argentina_eda3
GROUP BY anio, provincia;

-- Resumen de fallecidos en el pais durante la cuarentena separado por provincia
SELECT provincia, sum(nuevos_fallecidos) fallecidos_por_provincia_en_cuarentena
FROM covid19_argentina_eda3
WHERE dia_cuarentena > 0
GROUP BY provincia;

-- Resumen de fallecidos en el pais fuera de la cuarentena separado por provincia
SELECT provincia, sum(nuevos_fallecidos) fallecidos_por_provincia_fuera_cuarentena
FROM covid19_argentina_eda3
WHERE dia_cuarentena = 0
GROUP BY provincia;

-- Mayor cantidad de casos y fallecidos por provincia
SELECT provincia, max(casos_por_provincia) total_casos_provincia, max(fallecidos_por_provincia) total_fallecidos_provincia
FROM covid19_argentina_eda3
GROUP BY provincia;

-- Resumen de las fluctuaciones en el indice de pobreza pór semestre 
	-- Suba o baja del indice de pobreza 
SELECT provincia,semestre,indice_pobreza,RIGHT(semestre, 4) as anio, (indice_pobreza - lag(indice_pobreza) over(partition by provincia)) as diferencia_indice_pobreza_con_semestre_previo
FROM covid19_argentina_eda3
WHERE indice_pobreza > 0
GROUP BY provincia, semestre
ORDER BY provincia, anio, semestre;
	-- Maximo cambio en el indice
WITH cte as (
SELECT provincia,semestre,indice_pobreza,RIGHT(semestre, 4) as anio, (indice_pobreza - lag(indice_pobreza) over(partition by provincia)) as diferencia_indice_pobreza_con_semestre_previo
FROM covid19_argentina_eda3
WHERE indice_pobreza > 0
GROUP BY provincia, semestre
ORDER BY provincia, anio, semestre
)SELECT *, max(diferencia_indice_pobreza_con_semestre_previo) as maximo_suba_indice_pobreza
FROM cte
GROUP BY provincia
ORDER BY maximo_suba_indice_pobreza DESC;
	-- Minimo cambio en el indice
WITH cte AS (
SELECT provincia,semestre,indice_pobreza,RIGHT(semestre, 4) as anio, (indice_pobreza - lag(indice_pobreza) over(partition by provincia)) as diferencia_indice_pobreza_con_semestre_previo
FROM covid19_argentina_eda3
WHERE indice_pobreza > 0
GROUP BY provincia, semestre
ORDER BY provincia, anio, semestre
)SELECT *, min(diferencia_indice_pobreza_con_semestre_previo) as minimo_suba_indice_pobreza
FROM cte
GROUP BY provincia
ORDER BY minimo_suba_indice_pobreza ASC;

-- Fecha de cuando surgio el primer caso registrado de cada provincia
SELECT date_format(min(covid19_argentina_eda3.﻿fecha),"%d/%m/%Y") fecha, provincia
FROM covid19_argentina_eda3
GROUP BY provincia;
-- --------------------------------------------------------------------------------------------           VISTA POR SEMESTRE          --------------------------------------------------------------------------------------------
-- Cantidad de casos y fallecidos por semestre 
SELECT provincia, semestre, max(casos_por_provincia) as max_casos, max(fallecidos_por_provincia) as max_fallecidos
FROM covid19_argentina_eda3
GROUP BY provincia, semestre;
-- Porcentaje de fallecidos por provincia  y semestre
SELECT provincia, semestre, round(((sum(covid19_argentina_eda3.nuevos_fallecidos)/sum(covid19_argentina_eda3.nuevos_casos))*100),2) as porcentaje_fallecidos_por_provincia
FROM covid19_argentina_eda3
GROUP BY provincia, semestre;

-- Porcentaje de casos por poblacion y semestre
SELECT c.provincia, semestre, round((sum(c.nuevos_casos)/p.poblacion)*100,2) as porcentaje_casos
FROM covid19_argentina_eda3 c
JOIN poblacion_argentina p
	ON c.provincia = p.﻿provincia
GROUP BY c.provincia, semestre;
-- Promedio de casos por provincia y semestre
SELECT provincia, semestre,round(avg(covid19_argentina_eda3.nuevos_casos),2) promedio_casos
FROM covid19_argentina_eda3
GROUP BY provincia, semestre;
-- Promedio de fallecidos por provincia y semestre
SELECT provincia, semestre,round(avg(covid19_argentina_eda3.nuevos_fallecidos),2) promedio_fallecidos
FROM covid19_argentina_eda3
GROUP BY provincia,semestre;

-- Suba o baja de casos por semestre y provincia mostrado en porcentaje
WITH cte as (
SELECT provincia,semestre, sum(nuevos_casos),
round((sum(nuevos_casos) / lag(sum(nuevos_casos)) over(partition by provincia))*100,2) as porcentaje_diferencia_de_casos_con_semestre_previo
FROM covid19_argentina_eda3
GROUP BY provincia, semestre
ORDER BY provincia
) SELECT *
FROM cte;

-- Suba o baja de casos por semestre y provincia mostrado en porcentaje
WITH cte as (
SELECT provincia,semestre,sum(nuevos_fallecidos),
round((sum(nuevos_fallecidos) / lag(sum(nuevos_fallecidos)) over(partition by provincia))*100,2) as porcentaje_diferencia_de_fallecidos_con_semestre_previo
FROM covid19_argentina_eda3
GROUP BY provincia, semestre
ORDER BY provincia
) SELECT *
FROM cte;