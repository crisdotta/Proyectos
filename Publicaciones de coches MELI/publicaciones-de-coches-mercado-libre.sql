/*
	Carga del archivo CSV a la base de datos
*/

LOAD DATA INFILE 'MeliCarPublicactions.csv' 
INTO TABLE melicarpublicactions 
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/*
	EDA BASICO
*/

-- Cantidad de publicaciones
SELECT count(melicarpublicactions.﻿id) as cantidad_de_publicaciones
FROM melicarpublicactions;

-- Cantidad de coches usados o nuevos
SELECT `condition`, count(`condition`) count_condition
FROM melicarpublicactions
GROUP BY `condition`;

-- Cantidad de coches por año
SELECT car_year, count(car_year) count_car_year
FROM melicarpublicactions
GROUP BY car_year
ORDER BY count_car_year DESC;

-- Cantidad de coches por marca
SELECT brand, count(brand) count_brand
FROM melicarpublicactions
GROUP BY brand
ORDER BY count_brand DESC;

-- Cantidad de coches segun marca, modelo y año
SELECT car_year,brand, model, count(model)
FROM melicarpublicactions
GROUP BY car_year,brand,model;

-- Kilometraje por modelo de coche
SELECT car_year,brand,model,min(km) min,max(km) max,round(avg(km),2) as avg_km
FROM melicarpublicactions
GROUP BY car_year,brand,model
ORDER BY avg_km;  

-- Cantidad de publicaciones en dolares o pesos
SELECT currency, count(currency)
FROM melicarpublicactions
GROUP BY currency;

/*
	PRECIOS
*/

-- Vista general de los precios
SELECT currency, sum(price) total_price, min(price) min_price, max(price) max_price, avg(price) avg_price
FROM melicarpublicactions
GROUP BY currency;

-- Vista general de los precios basado en año,marca,modelo del coche y moneda
SELECT `car_year`,brand,model,currency,min(price) min,max(price) max,round(avg(price),2) as avg
FROM melicarpublicactions
GROUP BY `car_year`,brand,model,currency
ORDER BY brand, car_year;

-- Que marca es la mas barata o cara para comprar
SELECT brand, currency, min(price) min,max(price) max,round(avg(price),2) as avge
FROM melicarpublicactions
GROUP BY brand, currency
ORDER BY currency,avge;

-- Cantidad de concesionarios
SELECT is_car_shop,count(is_car_shop) 
FROM melicarpublicactions
GROUP BY is_car_shop;

-- Cantidad de publiciones en base a provincia
SELECT seller_state, count(seller_state) as count
FROM melicarpublicactions
GROUP BY seller_state
ORDER BY seller_state;

-- Promedio de años por provincia
SELECT round(avg(car_year),0) avge, seller_state
FROM melicarpublicactions
GROUP BY seller_state
order by avge;



/*
	EDA AVANZADO
*/
-- Cantidad de publiciones en base a provincia con los datos segmentados de Buenos Aires sumados y agrupados en una sola fila 
SELECT IF(seller_state = "Bs.As. G.B.A. Sur", "Buenos Aires", "Bs.As. G.B.A. Sur") as seller_state, count(seller_state) as count
FROM melicarpublicactions
WHERE seller_state LIKE "B%" OR seller_state LIKE "Capital%"
UNION
SELECT seller_state, count(seller_state)
FROM melicarpublicactions
GROUP BY seller_state
ORDER BY count DESC;

-- Marca mas vendida en cada provincia
WITH cte AS(
SELECT ROW_NUMBER() OVER(PARTITION BY seller_state ORDER BY count(brand) DESC) id,seller_state,brand, count(brand) count
FROM melicarpublicactions
GROUP BY seller_state, brand
ORDER BY seller_state ASC
) SELECT * FROM cte WHERE id = 1;
-- Modelo mas vendido en cada provincia
WITH cte AS(
SELECT ROW_NUMBER() over(partition by seller_state ORDER BY count(brand) DESC) id,seller_state,brand,model, count(brand) count
FROM melicarpublicactions
GROUP BY seller_state, brand,model
ORDER BY seller_state ASC
) SELECT * FROM cte WHERE id=1;
-- Mayor kilometraje por provincia
WITH cte AS(
SELECT ROW_NUMBER() over(partition by km ORDER BY count(km) DESC) id,seller_state,round(avg(km),2) avg_km
FROM melicarpublicactions
GROUP BY seller_state
ORDER BY avg_km asc
) SELECT * FROM cte WHERE id=1;

-- En donde es mas barato comprar un coche
WITH cte AS(
SELECT ROW_NUMBER() over(partition by seller_state ORDER BY avg(price) DESC) id,seller_state,currency,avg(price) avg_price
FROM melicarpublicactions
GROUP BY seller_state, currency
ORDER BY currency, avg_price ASC
) SELECT * FROM cte;

-- Mayor cantidad de publicaciones por usuario
WITH cte AS(
SELECT ROW_NUMBER() OVER(PARTITION BY is_car_shop ORDER BY count(seller_nickname) DESC) id,seller_nickname, is_car_shop,count(seller_nickname) count
FROM melicarpublicactions
GROUP BY seller_nickname
)SELECT * FROM cte
WHERE id <= 5;

-- Mayor cantidad de publicaciones por zona y los 5 usuarios con mas actividad
WITH cte AS(
SELECT ROW_NUMBER() OVER(PARTITION BY is_car_shop,seller_state ORDER BY count(seller_nickname) DESC) id,seller_nickname, is_car_shop,count(seller_nickname) count, seller_state
FROM melicarpublicactions
GROUP BY seller_nickname
)SELECT * FROM cte
WHERE id <= 5;


SELECT * FROM melicarpublicactions;
