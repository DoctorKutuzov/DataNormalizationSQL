-- fill name by phone
UPDATE d9140d6a AS dda
SET "name"=dda1."name"
FROM (
  SELECT
  	DISTINCT phone, "name"
  FROM d9140d6a
  WHERE
  	phone IS NOT NULL AND
  	"name" IS NOT NULL
  	) AS dda1
WHERE dda.phone=dda1.phone;

-- fill phone by name
UPDATE d9140d6a AS dda
SET phone=dda1.phone
FROM (
  SELECT
  	DISTINCT phone, "name"
  FROM d9140d6a
  WHERE
  	phone IS NOT NULL AND
  	"name" IS NOT NULL
  	) AS dda1
WHERE dda."name"=dda1."name";

-- fill email by name
UPDATE d9140d6a AS dda
SET email=dda1.email
FROM (
  SELECT
  	DISTINCT email, "name"
  FROM d9140d6a
  WHERE
  	email IS NOT NULL AND
  	"name" IS NOT NULL
  	) AS dda1
WHERE dda."name"=dda1."name";

-- fill password by name, email, phone
UPDATE d9140d6a AS dda
SET "password"=dda1."password"
FROM (
  SELECT
  	DISTINCT "password", phone, email, "name"
  FROM d9140d6a
  WHERE
  	"password" IS NOT NULL AND
  	phone IS NOT NULL AND
  	email IS NOT NULL AND
  	"name" IS NOT NULL
  	) AS dda1
WHERE
	dda."name"=dda1."name" AND
	dda.email=dda1.email AND
	dda.phone=dda1.phone;


-- fill car by vin
UPDATE d9140d6a AS dda
SET car=dda1.car
FROM (
  SELECT
  	DISTINCT car, vin
  FROM d9140d6a
  WHERE
  	car IS NOT NULL AND
  	vin IS NOT NULL
  	) AS dda1
WHERE dda.vin=dda1.vin;

-- fill car_number by car, vin
UPDATE d9140d6a AS dda
SET car_number=dda1.car_number
FROM (
  SELECT
  	DISTINCT car_number, car, vin
  FROM d9140d6a
  WHERE
  	car IS NOT NULL AND
  	vin IS NOT NULL AND
	car_number IS NOT NULL
  	) AS dda1
WHERE
	dda.vin=dda1.vin AND
	dda.car=dda1.car;

-- fill vin by car, car_number
UPDATE d9140d6a AS dda
SET vin=dda1.vin
FROM (
  SELECT
  	DISTINCT car_number, car, vin
  FROM d9140d6a
  WHERE
  	car IS NOT NULL AND
  	vin IS NOT NULL AND
	car_number IS NOT NULL
  	) AS dda1
WHERE
	dda.car_number=dda1.car_number AND
	dda.car=dda1.car;

-- fill color by vin
UPDATE d9140d6a AS dda
SET color=dda1.color
FROM (
  SELECT
  	DISTINCT color, vin
  FROM d9140d6a
  WHERE
  	color IS NOT NULL AND
  	vin IS NOT NULL
  	) AS dda1
WHERE dda.vin=dda1.vin;

-- fill w_name by w_phone
UPDATE d9140d6a AS dda
SET w_name=dda1.w_name
FROM (
  SELECT
  	DISTINCT w_name, w_phone
  FROM d9140d6a
  WHERE
  	w_name IS NOT NULL AND
  	w_phone IS NOT NULL
  	) AS dda1
WHERE dda.w_phone=dda1.w_phone;

-- fill w_phone by w_name
UPDATE d9140d6a AS dda
SET w_phone=dda1.w_phone
FROM (
  SELECT
  	DISTINCT w_name, w_phone
  FROM d9140d6a
  WHERE
  	w_name IS NOT NULL AND
  	w_phone IS NOT NULL
  	) AS dda1
WHERE dda.w_name=dda1.w_name;

-- fill w_exp by w_name
UPDATE d9140d6a AS dda
SET w_exp=dda1.w_exp
FROM (
  SELECT
  	DISTINCT w_name, w_exp
  FROM d9140d6a
  WHERE
  	w_exp IS NOT NULL AND
  	w_name IS NOT NULL
  	) AS dda1
WHERE dda.w_name=dda1.w_name;

-- fill wages by w_name
UPDATE d9140d6a AS dda
SET wages=dda1.wages
FROM (
  SELECT
  	DISTINCT w_name, wages
  FROM d9140d6a
  WHERE
  	wages IS NOT NULL AND
  	w_name IS NOT NULL
  	) AS dda1
WHERE dda.w_name=dda1.w_name;

-- fill service_addr by w_name
UPDATE d9140d6a AS dda
SET service_addr=dda1.service_addr
FROM (
  SELECT
  	DISTINCT w_name, service_addr
  FROM d9140d6a
  WHERE
  	w_name IS NOT NULL AND
  	service_addr IS NOT NULL
  	) AS dda1
WHERE dda.w_name=dda1.w_name;

-- fill service by service_addr
UPDATE d9140d6a AS dda
SET service=dda1.service
FROM (
  SELECT
  	DISTINCT service, service_addr
  FROM d9140d6a
  WHERE
  	service IS NOT NULL AND
  	service_addr IS NOT NULL
  	) AS dda1
WHERE dda.service_addr=dda1.service_addr;