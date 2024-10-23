-- create logbook
DROP TABLE IF EXISTS logbook;
CREATE TABLE logbook AS (
	SELECT
		ROW_NUMBER() OVER() AS logbook_id,
		lb.log_date::date
	FROM (
		SELECT
			DISTINCT dda."date" AS log_date
		FROM d9140d6a dda
		ORDER BY log_date
	) AS lb
);
DROP SEQUENCE IF EXISTS logbook_logbook_id_seq;
CREATE SEQUENCE logbook_logbook_id_seq;
SELECT setval('logbook_logbook_id_seq', max(lb.logbook_id)) FROM logbook lb;
ALTER TABLE logbook
	ADD PRIMARY KEY (logbook_id),
	ALTER COLUMN logbook_id TYPE bigint,
	ALTER COLUMN logbook_id SET DEFAULT nextval('logbook_logbook_id_seq');
ALTER SEQUENCE logbook_logbook_id_seq OWNED BY logbook.logbook_id;
CREATE INDEX IF NOT EXISTS logbook_log_date_idx ON logbook USING BRIN (log_date);

-- create regions
DROP TABLE IF EXISTS regions;
CREATE TABLE regions AS (
	SELECT
		ROW_NUMBER() OVER() AS region_id,
		r.region
	FROM (
		SELECT
			DISTINCT dda.service AS region
		FROM d9140d6a dda
		ORDER BY region
	) AS r
);
DROP SEQUENCE IF EXISTS regions_region_id_seq;
CREATE SEQUENCE regions_region_id_seq;
SELECT setval('regions_region_id_seq', max(r.region_id)) FROM regions r;
ALTER TABLE regions
	ADD PRIMARY KEY (region_id),
	ALTER COLUMN region_id TYPE bigint,
	ALTER COLUMN region_id SET DEFAULT nextval('regions_region_id_seq');
ALTER SEQUENCE regions_region_id_seq OWNED BY regions.region_id;
CREATE INDEX IF NOT EXISTS regions_region_idx ON regions USING hash (lower(region));

-- create brands
DROP TABLE IF EXISTS brands;
CREATE TABLE brands AS (
	SELECT
		ROW_NUMBER() OVER() AS brand_id,
		b."name" AS brand
	FROM (
		SELECT
			DISTINCT dda.car AS "name"
		FROM d9140d6a dda
		ORDER BY "name"
	) AS b
);
DROP SEQUENCE IF EXISTS brands_brand_id_seq;
CREATE SEQUENCE brands_brand_id_seq;
SELECT setval('brands_brand_id_seq', max(b.brand_id)) FROM brands b;
ALTER TABLE brands
	ADD PRIMARY KEY (brand_id),
	ALTER COLUMN brand_id TYPE bigint,
	ALTER COLUMN brand_id SET DEFAULT nextval('brands_brand_id_seq');
ALTER SEQUENCE brands_brand_id_seq OWNED BY brands.brand_id;
CREATE INDEX IF NOT EXISTS brands_brand_idx ON brands USING hash (brand);

-- create colors
DROP TABLE IF EXISTS colors;
CREATE TABLE colors AS (
	SELECT
		ROW_NUMBER() OVER() AS color_id,
		clr."name" AS color
	FROM (
		SELECT
			DISTINCT dda.color AS "name"
		FROM d9140d6a dda
		ORDER BY "name"
	) AS clr
);
DROP SEQUENCE IF EXISTS colors_color_id_seq;
CREATE SEQUENCE colors_color_id_seq;
SELECT setval('colors_color_id_seq', max(clr.color_id)) FROM colors clr;
ALTER TABLE colors
	ADD PRIMARY KEY (color_id),
	ALTER COLUMN color_id TYPE bigint,
	ALTER COLUMN color_id SET DEFAULT nextval('colors_color_id_seq');
ALTER SEQUENCE colors_color_id_seq OWNED BY colors.color_id;
CREATE INDEX IF NOT EXISTS colors_color_idx ON colors USING hash (color);

-- create clients
DROP TABLE IF EXISTS clients;
CREATE TABLE clients AS (
	SELECT
		ROW_NUMBER() OVER() AS client_id,
		split_part(c."name", ' ', 1) AS first_name,
		split_part(c."name", ' ', 2) AS last_name,
		c."password"
	FROM (
		SELECT
			DISTINCT (dda."name"),
			dda."password"
		FROM d9140d6a dda
		ORDER BY "name"
	) AS c
);
DROP SEQUENCE IF EXISTS clients_client_id_seq;
CREATE SEQUENCE clients_client_id_seq;
SELECT setval('clients_client_id_seq', max(c.client_id)) FROM clients c;
ALTER TABLE clients
	ADD PRIMARY KEY (client_id),
	ALTER COLUMN client_id TYPE bigint,
	ALTER COLUMN client_id SET DEFAULT nextval('clients_client_id_seq');
ALTER SEQUENCE clients_client_id_seq OWNED BY clients.client_id;
CREATE INDEX IF NOT EXISTS clients_fullname_idx ON clients USING GiST (to_tsvector('russian', first_name || ' ' || last_name));

-- create services
DROP TABLE IF EXISTS services;
CREATE TABLE services AS (
	SELECT
		ROW_NUMBER() OVER() AS service_id,
		s.service_addr AS address,
		r.region_id
	FROM (
		SELECT
			DISTINCT (dda.service_addr),
			dda.service
		FROM d9140d6a dda
		ORDER BY dda.service_addr
	) AS s
	JOIN regions r ON s.service = r.region
);
DROP SEQUENCE IF EXISTS services_service_id_seq;
CREATE SEQUENCE services_service_id_seq;
SELECT setval('services_service_id_seq', max(s.service_id)) FROM services s;
ALTER TABLE services
	ADD PRIMARY KEY (service_id),
	ALTER COLUMN service_id TYPE bigint,
	ALTER COLUMN region_id TYPE bigint,
	ALTER COLUMN service_id SET DEFAULT nextval('services_service_id_seq'),
	ADD CONSTRAINT fk_services_regions FOREIGN KEY (region_id) REFERENCES regions (region_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE services_service_id_seq OWNED BY services.service_id;
CREATE INDEX IF NOT EXISTS services_address_idx ON services USING GiST (to_tsvector('russian', address));

-- create workers
DROP TABLE IF EXISTS workers;
CREATE TABLE workers AS (
	SELECT
		ROW_NUMBER() OVER() AS worker_id,
		split_part(w.w_name, ' ', 1) AS first_name,
		split_part(w.w_name, ' ', 2) AS last_name,
		w.w_exp AS experience,
		w.wages AS wages,
		s.service_id
	FROM (
		SELECT
			DISTINCT (dda.w_name),
			dda.w_exp,
			dda.wages,
			dda.service_addr
		FROM d9140d6a dda
		ORDER BY dda.w_name
	) AS w
	JOIN services s ON w.service_addr = s.address
);
DROP SEQUENCE IF EXISTS workers_worker_id_seq;
CREATE SEQUENCE workers_worker_id_seq;
SELECT setval('workers_worker_id_seq', max(w.worker_id)) FROM workers w;
ALTER TABLE workers
	ADD PRIMARY KEY (worker_id),
	ALTER COLUMN worker_id TYPE bigint,
	ALTER COLUMN service_id TYPE bigint,
	ALTER COLUMN worker_id SET DEFAULT nextval('workers_worker_id_seq'),
	ADD CONSTRAINT fk_workers_services FOREIGN KEY (service_id) REFERENCES services (service_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE workers_worker_id_seq OWNED BY workers.worker_id;
CREATE INDEX IF NOT EXISTS workers_experience_idx ON workers USING btree (experience);

-- create worker_phones
DROP TABLE IF EXISTS worker_phones;
CREATE TABLE worker_phones AS (
	SELECT
		ROW_NUMBER() OVER() AS worker_phone_id,
		wp.w_phone AS phone,
		w.worker_id
	FROM (
		SELECT
			DISTINCT (dda.w_name),
			dda.w_phone
		FROM d9140d6a dda
		ORDER BY dda.w_name
	) AS wp
	JOIN workers w ON wp.w_name = concat(w.first_name, ' ', w.last_name)
);
DROP SEQUENCE IF EXISTS worker_phones_worker_phone_id_seq;
CREATE SEQUENCE worker_phones_worker_phone_id_seq;
SELECT setval('worker_phones_worker_phone_id_seq', max(wp.worker_phone_id)) FROM worker_phones wp;
ALTER TABLE worker_phones
	ADD PRIMARY KEY (worker_phone_id),
	ALTER COLUMN worker_phone_id TYPE bigint,
	ALTER COLUMN worker_id TYPE bigint,
	ALTER COLUMN worker_phone_id SET DEFAULT nextval('worker_phones_worker_phone_id_seq'),
	ADD CONSTRAINT fk_worker_phones_workers FOREIGN KEY (worker_id) REFERENCES workers (worker_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE worker_phones_worker_phone_id_seq OWNED BY worker_phones.worker_phone_id;
CREATE INDEX IF NOT EXISTS worker_phones_phone_idx ON worker_phones USING hash (phone);

-- create client_phones
DROP TABLE IF EXISTS client_phones;
CREATE TABLE client_phones AS (
	SELECT
		ROW_NUMBER() OVER() AS client_phone_id,
		cp.phone AS phone,
		c.client_id
	FROM (
		SELECT
			DISTINCT (dda."name"),
			dda.phone
		FROM d9140d6a dda
		ORDER BY dda."name"
	) AS cp
	JOIN clients c ON cp."name" = concat(c.first_name, ' ', c.last_name)
);
DROP SEQUENCE IF EXISTS client_phones_client_phone_id_seq;
CREATE SEQUENCE client_phones_client_phone_id_seq;
SELECT setval('client_phones_client_phone_id_seq', max(cp.client_phone_id)) FROM client_phones cp;
ALTER TABLE client_phones
	ADD PRIMARY KEY (client_phone_id),
	ALTER COLUMN client_phone_id TYPE bigint,
	ALTER COLUMN client_id TYPE bigint,
	ALTER COLUMN client_phone_id SET DEFAULT nextval('client_phones_client_phone_id_seq'),
	ADD CONSTRAINT fk_client_phones_clients FOREIGN KEY (client_id) REFERENCES clients (client_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE client_phones_client_phone_id_seq OWNED BY client_phones.client_phone_id;
CREATE INDEX IF NOT EXISTS client_phones_phone_idx ON client_phones USING hash (phone);

-- create client_emails
DROP TABLE IF EXISTS client_emails;
CREATE TABLE client_emails AS (
	SELECT
		ROW_NUMBER() OVER() AS client_email_id,
		ce.email AS email,
		c.client_id
	FROM (
		SELECT
			DISTINCT (dda."name"),
			dda.email
		FROM d9140d6a dda
		ORDER BY dda."name"
	) AS ce
	JOIN clients c ON ce."name" = concat(c.first_name, ' ', c.last_name)
);
DROP SEQUENCE IF EXISTS client_emails_client_email_id_seq;
CREATE SEQUENCE client_emails_client_email_id_seq;
SELECT setval('client_emails_client_email_id_seq', max(ce.client_email_id)) FROM client_emails ce;
ALTER TABLE client_emails
	ADD PRIMARY KEY (client_email_id),
	ALTER COLUMN client_email_id TYPE bigint,
	ALTER COLUMN client_id TYPE bigint,
	ALTER COLUMN client_email_id SET DEFAULT nextval('client_emails_client_email_id_seq'),
	ADD CONSTRAINT fk_client_emails_clients FOREIGN KEY (client_id) REFERENCES clients (client_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE client_emails_client_email_id_seq OWNED BY client_emails.client_email_id;
CREATE INDEX IF NOT EXISTS client_emails_email_idx ON client_emails USING GiST (to_tsvector('english', email));

-- create client_cards
DROP TABLE IF EXISTS client_cards;
CREATE TABLE client_cards AS (
	SELECT
		ROW_NUMBER() OVER() AS client_card_id,
		cc.card AS card,
		c.client_id
	FROM (
		SELECT
			DISTINCT dda."name", dda.card
		FROM d9140d6a dda
		ORDER BY dda."name"
	) AS cc
	JOIN clients c ON cc."name" = concat(c.first_name, ' ', c.last_name)
);
DROP SEQUENCE IF EXISTS client_cards_client_card_id_seq;
CREATE SEQUENCE client_cards_client_card_id_seq;
SELECT setval('client_cards_client_card_id_seq', max(cc.client_card_id)) FROM client_cards cc;
ALTER TABLE client_cards
	ADD PRIMARY KEY (client_card_id),
	ALTER COLUMN client_card_id TYPE bigint,
	ALTER COLUMN client_id TYPE bigint,
	ALTER COLUMN client_card_id SET DEFAULT nextval('client_cards_client_card_id_seq'),
	ADD CONSTRAINT fk_client_cards_clients FOREIGN KEY (client_id) REFERENCES clients (client_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE client_cards_client_card_id_seq OWNED BY client_cards.client_card_id;
CREATE INDEX IF NOT EXISTS client_cards_card_idx ON client_cards USING hash (card);

-- create cars
DROP TABLE IF EXISTS cars;
CREATE TABLE cars AS (
	SELECT
		ROW_NUMBER() OVER() AS car_id,
		c_cars.vin AS vin,
		c_cars.car_number AS car_number,
		clr.color_id,
		c.client_id,
		b.brand_id
	FROM (
		SELECT
			DISTINCT dda."name",
			dda.car,
			dda.vin,
			dda.car_number,
			dda.color
		FROM d9140d6a dda
		WHERE dda.card IS NOT NULL
		ORDER BY dda.vin
	) AS c_cars
	LEFT JOIN clients c ON c_cars."name" = concat(c.first_name, ' ', c.last_name)
	LEFT JOIN brands b ON c_cars.car = b.brand
	LEFT JOIN colors clr ON c_cars.color = clr.color
);
DROP SEQUENCE IF EXISTS cars_car_id_seq;
CREATE SEQUENCE cars_car_id_seq;
SELECT setval('cars_car_id_seq', max(ca.car_id)) FROM cars ca;
ALTER TABLE cars
	ADD PRIMARY KEY (car_id),
	ALTER COLUMN car_id TYPE bigint,
	ALTER COLUMN color_id TYPE bigint,
	ALTER COLUMN client_id TYPE bigint,
	ALTER COLUMN brand_id TYPE bigint,
	ALTER COLUMN car_id SET DEFAULT nextval('cars_car_id_seq'),
	ADD CONSTRAINT fk_cars_colors FOREIGN KEY (color_id) REFERENCES colors (color_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_cars_clients FOREIGN KEY (client_id) REFERENCES clients (client_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_cars_brands FOREIGN KEY (brand_id) REFERENCES brands (brand_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE cars_car_id_seq OWNED BY cars.car_id;
CREATE INDEX IF NOT EXISTS cars_vin_idx ON cars USING hash(vin);

-- create service_events_v for CORE
DROP MATERIALIZED VIEW IF EXISTS service_events_v;
CREATE MATERIALIZED VIEW service_events_v AS (
SELECT
	ROW_NUMBER() OVER() AS service_event_id,
	se.*,
	cr.car_id,
	w.worker_id,
	c.client_id,
	cc.client_card_id,
	lb.logbook_id
FROM (
		SELECT
			DISTINCT dda.vin,
			dda.mileage,
			dda."date",
			dda.pin,
			dda.payment,
			dda.card,
			dda.w_name,
			dda."name"
		FROM d9140d6a dda
	) AS se
LEFT JOIN cars cr ON se.vin = cr.vin
LEFT JOIN workers w ON se.w_name = concat(w.first_name, ' ', w.last_name)
LEFT JOIN clients c ON se."name" = concat(c.first_name, ' ', c.last_name)
LEFT JOIN client_cards cc ON c.client_id = cc.client_id AND (se.card = cc.card OR (se.card IS NULL AND cc.card IS NULL))
LEFT JOIN logbook lb ON se."date"::date = lb.log_date
);

-- create car_states
DROP TABLE IF EXISTS car_states;
CREATE TABLE car_states AS (
	SELECT
		ROW_NUMBER() OVER() AS car_state_id,
		cs.mileage,
		cs.car_id
	FROM (
		SELECT
			DISTINCT sev.mileage, sev.car_id
		FROM service_events_v sev
		ORDER BY sev.mileage
	) AS cs
);
DROP SEQUENCE IF EXISTS car_states_car_state_id_seq;
CREATE SEQUENCE car_states_car_state_id_seq;
SELECT setval('car_states_car_state_id_seq', max(cs.car_state_id)) FROM car_states cs;
ALTER TABLE car_states
	ADD PRIMARY KEY (car_state_id),
	ALTER COLUMN car_state_id TYPE bigint,
	ALTER COLUMN car_id TYPE bigint,
	ALTER COLUMN car_state_id SET DEFAULT nextval('car_states_car_state_id_seq'),
	ADD CONSTRAINT fk_car_states_cars FOREIGN KEY (car_id) REFERENCES cars (car_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE car_states_car_state_id_seq OWNED BY car_states.car_state_id;
CREATE INDEX IF NOT EXISTS car_states_mileage_idx ON car_states USING btree (mileage);

-- create payments
DROP TABLE IF EXISTS payments;
CREATE TABLE payments AS (
	SELECT
		ROW_NUMBER() OVER() AS payment_id,
		p.pin,
		p.payment AS payment_value,
		p.client_card_id
	FROM (
		SELECT
			DISTINCT sev.pin, sev.payment, sev.client_card_id
		FROM service_events_v sev
		ORDER BY sev.payment
	) AS p
);
DROP SEQUENCE IF EXISTS payments_payment_id_seq;
CREATE SEQUENCE payments_payment_id_seq;
SELECT setval('payments_payment_id_seq', max(p.payment_id)) FROM payments p;
ALTER TABLE payments
	ADD PRIMARY KEY (payment_id),
	ALTER COLUMN payment_id TYPE bigint,
	ALTER COLUMN client_card_id TYPE bigint,
	ALTER COLUMN payment_id SET DEFAULT nextval('payments_payment_id_seq'),
	ADD CONSTRAINT fk_payments_client_cards FOREIGN KEY (client_card_id) REFERENCES client_cards (client_card_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE payments_payment_id_seq OWNED BY payments.payment_id;
CREATE INDEX IF NOT EXISTS payments_payment_value_idx ON payments USING btree (payment_value DESC);

-- create service_events
DROP TABLE IF EXISTS service_events;
CREATE TABLE service_events AS (
	SELECT
		sev.service_event_id,
		cs.car_state_id,
		sev.logbook_id,
		p.payment_id,
		sev.worker_id
	FROM service_events_v sev
	LEFT JOIN car_states cs ON sev.car_id  = cs.car_id AND (sev.mileage = cs.mileage OR (sev.mileage IS NULL AND cs.mileage IS NULL))
	LEFT JOIN payments p ON
		sev.client_card_id = p.client_card_id  AND
		(sev.pin = p.pin OR (sev.pin IS NULL AND p.pin IS NULL)) AND
		(sev.payment = p.payment_value OR (sev.payment IS NULL AND p.payment_value IS NULL))
);
DROP SEQUENCE IF EXISTS service_events_service_event_id_seq;
CREATE SEQUENCE service_events_service_event_id_seq;
SELECT setval('service_events_service_event_id_seq', max(se.service_event_id)) FROM service_events se;
ALTER TABLE service_events
	ADD PRIMARY KEY (service_event_id),
	ALTER COLUMN service_event_id TYPE bigint,
	ALTER COLUMN car_state_id TYPE bigint,
	ALTER COLUMN logbook_id TYPE bigint,
	ALTER COLUMN payment_id TYPE bigint,
	ALTER COLUMN worker_id TYPE bigint,
	ALTER COLUMN service_event_id SET DEFAULT nextval('service_events_service_event_id_seq'),
	ADD CONSTRAINT fk_service_events_car_states FOREIGN KEY (car_state_id) REFERENCES car_states (car_state_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_service_events_logbook FOREIGN KEY (logbook_id) REFERENCES logbook (logbook_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_service_events_payments FOREIGN KEY (payment_id) REFERENCES payments (payment_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_service_events_workers FOREIGN KEY (worker_id) REFERENCES workers (worker_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE;
ALTER SEQUENCE service_events_service_event_id_seq OWNED BY service_events.service_event_id;
CREATE INDEX IF NOT EXISTS service_events_comb_idx ON service_events USING btree (car_state_id, logbook_id, payment_id, worker_id);

-- create discounts
DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
	discount_id BIGSERIAL PRIMARY KEY,
	discount_size NUMERIC(3, 2) NOT NULL,
	description TEXT
);
CREATE INDEX IF NOT EXISTS discounts_discount_size_idx ON discounts USING btree (discount_size);

-- fill discounts
INSERT INTO discounts (discount_size, description)
VALUES
	(0.10, 'Для тех, кто обращался более 200 раз'),
	(0.05, 'Для тех, кто обращался более 180 раз');

-- create client_discounts
DROP TABLE IF EXISTS client_discounts;
CREATE TABLE client_discounts AS (
	SELECT
		ROW_NUMBER() OVER() AS client_discount_id,
		cd.discount_id,
		cd.client_id
	FROM (
		SELECT
			CASE
				WHEN count(sev.vin) > 200 THEN 1
				ELSE 2
			END AS discount_id,
			sev.client_id,
			count(sev.vin)
		FROM service_events_v sev
		GROUP BY client_id HAVING count(sev.vin) > 180
		ORDER BY 3 DESC
	) AS cd
);
DROP SEQUENCE IF EXISTS client_discounts_client_discount_id_seq;
CREATE SEQUENCE client_discounts_client_discount_id_seq;
SELECT setval('client_discounts_client_discount_id_seq', max(cd.client_discount_id)) FROM client_discounts cd;
ALTER TABLE client_discounts
	ADD PRIMARY KEY (client_discount_id),
	ALTER COLUMN client_discount_id TYPE bigint,
	ALTER COLUMN discount_id TYPE bigint,
	ALTER COLUMN client_id TYPE bigint,
	ALTER COLUMN client_discount_id SET DEFAULT nextval('client_discounts_client_discount_id_seq'),
	ADD CONSTRAINT fk_client_discounts_discounts FOREIGN KEY (discount_id) REFERENCES discounts (discount_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_client_discounts_clients FOREIGN KEY (client_id) REFERENCES clients (client_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD UNIQUE (discount_id, client_id);
ALTER SEQUENCE client_discounts_client_discount_id_seq OWNED BY client_discounts.client_discount_id;
CREATE INDEX IF NOT EXISTS client_discounts_comb_idx ON client_discounts USING btree (discount_id, client_id);