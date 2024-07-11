-- Carga de datos de un archivo CSV (previamente limpiado) a la base de datos
LOAD DATA INFILE 'VentasSQL.csv' 
INTO TABLE ventassql 
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
																				/*LIMPIEZA DE COLUMNAS*/
-- Se descubrio que la columna 'Country' tenia un salto de linea (ASCII 10) y se elimino de todos los valores.
UPDATE ventassql
SET ventassql.Country = replace(ventassql.Country,right(ventassql.Country,1),"");

-- Eliminando la hora de la columna Date para solo dejar la fecha 
-- Creacion de la nueva columna dates para reemplazar date con solo la fecha
ALTER TABLE ventassql
ADD COLUMN dates date
AFTER `﻿TransactionNo`;
-- Creacion de los datos en base de la column Date
UPDATE ventassql
SET dates = date_format(ventassql.`Date`,"%Y-%m-%d");
-- Eliminacion de la columna Date
ALTER TABLE ventassql
DROP COLUMN `Date`;

																						/*EDA*/
                                                                                        /*BASICO*/
-- Cantidad de pedidos
SELECT count(distinct ventassql.﻿TransactionNo) as cantidad_de_pedidos
FROM ventassql;                                                                                        
-- Ventas por dia
SELECT dates, count(ventassql.﻿TransactionNo) as ventas_realizadas
FROM ventassql
GROUP BY dates
ORDER BY 2;
-- Ventas por mes
SELECT date_format(dates,'%Y-%m') as dates, count(ventassql.﻿TransactionNo)
FROM ventassql
GROUP BY 1
ORDER BY 1;
-- Ventas por año
SELECT date_format(dates,'%Y') as dates, count(ventassql.﻿TransactionNo)
FROM ventassql
GROUP   BY 1
ORDER BY 1;
-- Cantidad de productos vendidos
SELECT count(distinct ventassql.`ProductNo`) as cantidad_de_productos_vendidos
FROM ventassql;
-- Productos mas vendidos
SELECT ventassql.`ProductNo`, ProductName, count(ProductNo) as ventas
FROM ventassql
GROUP BY ProductName
ORDER BY 3 DESC;
-- Suma total de las ventas
SELECT round(sum(Price),2)
FROM ventassql;
-- Total de productos vendidos
SELECT sum(Quantity)
FROM ventassql;
-- Cantidad de clientes
SELECT count(distinct CustomerNo)
FROM ventassql;
-- Cantidad de ventas por clientes
SELECT Country,count(Country) as cantidad_de_compras_realizadas
FROM ventassql
GROUP BY Country
ORDER BY 2 DESC;
-- Productos mas vendidos por mes
SELECT date_format(dates,"%Y-%m"),ProductName,count(ProductNo)
FROM ventassql
GROUP BY dates
ORDER BY 3 DESC;
-- Cantidad de ventas por pais
SELECT Country, count(Country)
FROM ventassql
GROUP BY Country;
																	/*AVANZADO*/
-- Total de venta por pedido y su fecha
WITH cte AS(
SELECT ventassql.dates,ventassql.﻿TransactionNo as id_trans, Price, Quantity, round(price*quantity,2) as total_de_venta
FROM ventassql
)SELECT dates,id_trans,round(sum(total_de_venta),2) as suma
FROM cte
GROUP BY id_trans
ORDER BY suma DESC;
-- Sumatoria de ventas por paises
WITH cte AS(
SELECT Country,round(price*quantity,2) as total_de_venta 
FROM ventassql
)SELECT Country, round(sum(total_de_venta),2) as suma
FROM cte
GROUP BY Country
ORDER BY suma DESC;
-- Producto mas popular por pais
WITH cte AS(
SELECT Country as country, ProductName as product, count(ProductNo) as amount, row_number() over(partition by Country order by count(ProductNo) DESC) as popularity
FROM ventassql
GROUP BY 1,2
)SELECT * FROM cte
WHERE popularity = 1;

																/*Traduccion de graficos a script SQL*/
-- SECCION PAIS
-- Mayor cantidad de compras
SELECT Country, count(distinct ventassql.﻿TransactionNo) as compras_realizadas
FROM ventassql
GROUP BY Country
ORDER BY 2 DESC;
-- Mayor cantidad de clientes por pais
SELECT Country,count(distinct CustomerNo) canttidad_clientes
FROM ventassql
GROUP BY 1
ORDER BY 2 DESC;
-- PRODUCTOS
-- Producto mas vendido
SELECT ProductName, count(ProductNo) as cantidad_vendida
FROM ventassql
GROUP BY 1 
ORDER BY 2 DESC;
-- Total ventas por Producto
SELECT ProductName,round(sum(Price * Quantity),2)
FROM ventassql
GROUP BY 1 
ORDER BY 2 DESC;
-- VENTAS
-- Total ganancia por pais
SELECT Country,round(sum(Price * Quantity),2) ganancia
FROM ventassql
GROUP BY 1 
ORDER BY 2 DESC;
-- Ventas con mas ganancia
SELECT ventassql.﻿TransactionNo,round(sum(Price * Quantity),2) as ganancia
FROM ventassql
GROUP BY 1 
ORDER BY 2 DESC;
-- Total ventas por año y mes
SELECT date_format(dates, "%m-%Y") as `mes-año`,round(sum(Price * Quantity),2) ganancia
FROM ventassql
GROUP BY 1 
ORDER BY 1 ASC;
-- Tarjetas
-- Total ganancia
SELECT round(sum(Price * Quantity),2) as ganancia
FROM ventassql;
-- Productos vendidos
SELECT count(ProductNo) as productos_vendidos
FROM ventassql;
-- Total ventas
SELECT count(distinct ventassql.﻿TransactionNo) 	
FROM ventassql;
-- Promedio de venta
SELECT round(sum(Price * Quantity) / count(distinct ventassql.﻿TransactionNo),2)
FROM ventassql;

SELECT * FROM ventassql;

