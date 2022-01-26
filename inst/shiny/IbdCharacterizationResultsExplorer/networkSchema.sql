CREATE TABLE IbdCharacterization.time_window
(
    time_window_id integer NOT NULL,
    time_window_name character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT time_window_pkey PRIMARY KEY (time_window_id)
)

INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 1, 'Full history';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 2, '-365d to -1d';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 3, '-30d to -1d';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 4, '0d to 0d';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 5, '0d to 365d';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 6, '0d to 3y';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 7, '0d to 5y';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 8, '0d to 10y';
INSERT INTO IbdCharacterization.time_window (time_window_id, time_window_name) SELECT 9, 'Full follow-up';

DROP TABLE IbdCharacterization.cohort_xref;
CREATE TABLE IbdCharacterization.cohort_xref (
	cohort_id varchar(100),
	target_id varchar(100),
	target_name varchar(4000),
	strata_id varchar(100),
	strata_name varchar(4000),
	cohort_type varchar(4000)
)
;

-- INSERT DATA FROM SPREADSHEET

DROP TABLE IbdCharacterization.cohort;
CREATE TABLE IbdCharacterization.cohort (
	cohort_id BIGINT,
	target_id BIGINT,
	target_name varchar(4000),
	strata_id BIGINT,
	strata_name varchar(4000),
	cohort_type varchar(4000)
)
;

INSERT INTO IbdCharacterization.cohort (
	cohort_id,
	target_id,
	target_name,
	strata_id,
	strata_name,
	cohort_type
)
SELECT 
	CAST(cohort_id AS BIGINT) cohort_id,
	CAST(target_id AS BIGINT) target_id,
	target_name,
	CAST(strata_id AS BIGINT) strata_id,
	strata_name,
	cohort_type
FROM IbdCharacterization.cohort_xref
;

TRUNCATE TABLE IbdCharacterization.cohort_xref;
DROP TABLE IbdCharacterization.cohort_xref;


-- Clean up covariates
SELECT COUNT(distinct covariate_id) FROM IbdCharacterization.covariate_mark
UNION ALL
SELECT COUNT(distinct covariate_id) FROM IbdCharacterization.covariate;

-- Handle the unique values first
select c.covariate_id, c.covariate_name, c.covariate_analysis_id
into IbdCharacterization.covariate_clean
from IbdCharacterization.covariate c
INNER JOIN (
	SELECT covariate_id from IbdCharacterization.covariate group by covariate_id having count(*) = 1
) d ON c.covariate_id = d.covariate_id

-- Next handle the non-unique cohort covariates
INSERT INTO IbdCharacterization.covariate_clean (covariate_id, covariate_name, covariate_analysis_id)
SELECT c.covariate_id, c.covariate_name, c.covariate_analysis_id
FROM IbdCharacterization.covariate c
LEFT JOIN IbdCharacterization.covariate_clean cc ON cc.covariate_id = c.covariate_id
where cc.covariate_id is null
  and c.covariate_name ilike 'cohort%'
  and c.covariate_analysis_id = 10000
order by c.covariate_id, c.covariate_name
;

-- Next handle the non-unique drug/condition covariates
INSERT INTO IbdCharacterization.covariate_clean (covariate_id, covariate_name, covariate_analysis_id)
SELECT c.covariate_id, c.covariate_name, c.covariate_analysis_id
FROM IbdCharacterization.covariate c
LEFT JOIN IbdCharacterization.covariate_clean cc ON cc.covariate_id = c.covariate_id
LEFT JOIN IbdCharacterization.covariate_mark cm ON cm.covariate_id = c.covariate_id
where cc.covariate_id is null
  and cm.mark = 'ASCII'
order by c.covariate_id, c.covariate_name
;

-- Verify that all covariates are now in the "clean" table
SELECT COUNT(*)
FROM (
	SELECT DISTINCT covariate_id FROM IbdCharacterization.covariate
) AS A
LEFT JOIN 
(
	SELECT DISTINCT covariate_id FROM IbdCharacterization.covariate_mark
) B ON A.covariate_id = B.covariate_id
WHERE B.covariate_id IS NULL
;

-- MAKE THE IbdCharacterization.covariate_clean the IbdCharacterization.covariate table
TRUNCATE TABLE IbdCharacterization.covariate;
DROP TABLE IbdCharacterization.covariate;

SELECT DISTINCT covariate_id, covariate_name, covariate_analysis_id, cast(right(cast(covariate_id as varchar), 1) as int) time_window_id
INTO IbdCharacterization.covariate
FROM IbdCharacterization.covariate_clean
;



TRUNCATE TABLE IbdCharacterization.covariate_mark;
DROP TABLE IbdCharacterization.covariate_mark;
TRUNCATE TABLE IbdCharacterization.covariate_clean;
DROP TABLE IbdCharacterization.covariate_clean;


SELECT c.covariate_id, c.covariate_name, c.covariate_analysis_id
FROM IbdCharacterization.covariate c
LEFT JOIN IbdCharacterization.covariate_clean cc ON cc.covariate_id = c.covariate_id
LEFT JOIN IbdCharacterization.covariate_mark cm ON cm.covariate_id = c.covariate_id
where cc.covariate_id is null
  and cm.mark = 'ASCII'
order by c.covariate_id, c.covariate_name


ALTER TABLE IbdCharacterization.cohort ADD PRIMARY KEY (cohort_id);
CREATE INDEX idx_cohort_target_id ON IbdCharacterization.cohort (target_id);
CREATE INDEX idx_cohort_target_name ON IbdCharacterization.cohort (target_name);
CREATE INDEX idx_cohort_strata_id ON IbdCharacterization.cohort (strata_id);
CREATE INDEX idx_cohort_strata_name ON IbdCharacterization.cohort (strata_name);

ALTER TABLE IbdCharacterization.cohort_count ADD PRIMARY KEY (cohort_id, database_id);
ALTER TABLE IbdCharacterization.covariate ADD PRIMARY KEY (covariate_id, covariate_name);
CREATE INDEX idx_covariate_time_window_id ON IbdCharacterization.covariate (time_window_id);

ALTER TABLE IbdCharacterization.covariate_value ADD PRIMARY KEY (cohort_id, covariate_id, database_id);
CREATE INDEX idx_cv_cohort_id ON IbdCharacterization.covariate_value (cohort_id);
CREATE INDEX idx_cv_covariate_id ON IbdCharacterization.covariate_value (covariate_id);
CREATE INDEX idx_cv_database_id ON IbdCharacterization.covariate_value (database_id);

ALTER TABLE IbdCharacterization.database ADD PRIMARY KEY (database_id);