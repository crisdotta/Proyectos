																		/*TRANSFORMACION DE DATOS*/
/*CREACION DE UNA NUEVA COLUMNA GDP_PER_CAPITA*/
/* 
	Esta columna se crea para que en la futura visualizacion de los datos se vea mejor, 
	ya que el gdp tiene valores muy altos y puede quedar no muy legible, 
	a diferencia de valores bajos 
*/

ALTER TABLE `datos-provinciales`
ADD COLUMN gdp_per_capita double AFTER gdp;

UPDATE `datos-provinciales` 
SET gdp_per_capita = round(gdp/pop,2);

/*CREACION DE UNA NUEVA COLUMNA POP_PERCENTAGE*/
/*
	Esta columna se crea para ver el porcentaje que ocupa cada provincia en el pais
*/
SET @total := (SELECT SUM(pop) FROM `datos-provinciales`);
SELECT province, pop, (pop/@total)*100 as perce
FROM `datos-provinciales`;

ALTER TABLE `datos-provinciales`
ADD COLUMN pop_percentage double AFTER pop;

UPDATE `datos-provinciales` 
SET pop_percentage = round((pop/@total)*100,2);

SELECT * FROM `datos-provinciales`;

