-- raise wages
WITH worker_events AS (
	SELECT
		sev.worker_id,
		COUNT(sev.service_event_id) AS events_count
	FROM service_events_v sev
	GROUP BY sev.worker_id
	ORDER BY 2 DESC LIMIT 3
)
UPDATE workers AS w
	SET wages = (wages * 1.1)::int
FROM worker_events AS we
WHERE w.worker_id = we.worker_id;

-- last month statistics
DROP VIEW IF EXISTS last_month_v;
CREATE VIEW last_month_v AS (
	SELECT
		concat(r.region, ', ', s.address) AS branch,
		count(se.service_event_id) AS service_events_count,
		sum(p.payment_value) AS payment_sum,
		sum(p.payment_value) - sum(w.wages) AS payment_sum_without_wages
	FROM service_events se
	RIGHT JOIN (
			SELECT
				*
			FROM logbook
			WHERE log_date >= date_trunc('month', current_date - interval '1' month)
		) AS l USING (logbook_id)
	JOIN payments p USING (payment_id)
	JOIN workers w USING (worker_id)
	JOIN services s USING (service_id)
	JOIN regions r USING (region_id)
	GROUP BY 1
);

-- top and antitop 10 brands
DROP VIEW IF EXISTS brand_statistics_v;
CREATE VIEW brand_statistics_v AS (
	SELECT
		b.brand,
		count(se.service_event_id) AS service_events_count
	FROM service_events se
	JOIN car_states cs USING (car_state_id)
	JOIN cars c USING (car_id)
	JOIN brands b USING (brand_id)
	GROUP BY b.brand_id
);

DROP VIEW IF EXISTS top_10_reliable_brands_v;
CREATE VIEW top_10_reliable_brands_v AS (
	SELECT
		*
	FROM brand_statistics_v bsv
	ORDER BY bsv.service_events_count
	LIMIT 10
);

DROP VIEW IF EXISTS antitop_10_reliable_brands_v;
CREATE VIEW antitop_10_reliable_brands_v AS (
	SELECT
		*
	FROM brand_statistics_v bsv
	ORDER BY bsv.service_events_count DESC
	LIMIT 10
);

-- the color with which the cars were less serviced
SELECT
	clr.color,
	count(se.service_event_id) AS service_events_count
FROM service_events se
JOIN car_states cs USING (car_state_id)
JOIN cars c USING (car_id)
JOIN colors clr USING (color_id)
GROUP BY clr.color_id
ORDER BY service_events_count
LIMIT 1