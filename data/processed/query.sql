SELECT * FROM wav_attribute;

SELECT COUNT(*) FROM wav_attribute;

-- next section 
SELECT * FROM load_raw_mos;
-- end 

-- check if duplicate 
SELECT
    file,
    COUNT(*) AS cnt
FROM load_raw_mos
GROUP BY file
HAVING COUNT(*) > 1;


-- check how many duplicate
SELECT COUNT(*)
FROM (
    SELECT file
    FROM load_raw_mos
    GROUP BY file
    HAVING COUNT(*) > 1
); 
-- end: result = 0; there are no duplicate

-- -- remove duplicate
-- DELETE FROM mos_score
-- WHERE rowid NOT IN (
--     SELECT MIN(rowid)
--     FROM mos_score
--     GROUP BY file
-- );


-- How Many MOS Records?
SELECT COUNT(*)
FROM load_raw_mos;
-- end: result = 7106;

-- How Many Audio Features?
SELECT COUNT(*)
FROM wav_attribute;
-- end: result = 3382

-- How Many Match?
SELECT COUNT(*)
FROM wav_attribute w
INNER JOIN load_raw_mos m
ON w.filename = m.file;
-- end: 3382

-- Then Create Final Analysis Table
CREATE TABLE wav_analysis AS
SELECT
    w.file,
    w.duration,
    w.pitch_std,
    w.energy_std,
    m.MOS
FROM wav_attribute w
INNER JOIN load_raw_mos m
    ON w.filename = m.file;
-- end: create new table 'wav_analysis' 

-- XXX never run this query again
-- see average mos
SELECT AVG(MOS) FROM wav_analysis;
-- end: 2.70202542874039

-- see highest mos
SELECT *
FROM wav_analysis
ORDER BY MOS DESC
LIMIT 10;

-- XXX never run this query agian
-- add new atribute
ALTER TABLE wav_attribute ADD COLUMN pitch_mean REAL;
ALTER TABLE wav_attribute ADD COLUMN pitch_min REAL;
ALTER TABLE wav_attribute ADD COLUMN pitch_max REAL;
ALTER TABLE wav_attribute ADD COLUMN pitch_range REAL;

ALTER TABLE wav_attribute ADD COLUMN energy_mean REAL;
ALTER TABLE wav_attribute ADD COLUMN energy_range REAL;

ALTER TABLE wav_attribute ADD COLUMN spectral_centroid REAL;
ALTER TABLE wav_attribute ADD COLUMN spectral_bandwidth REAL;

ALTER TABLE wav_attribute ADD COLUMN zcr REAL;


--- sesect table row 
SELECT COUNT(*)
FROM wav_attribute;

-- to show the info of table 
PRAGMA table_info(wav_attribute);


-- create new table 
DROP TABLE IF EXISTS wav_analysis;

CREATE TABLE wav_analysis AS
SELECT
    w.*,
    m.MOS
FROM wav_attribute w
INNER JOIN load_raw_mos m
ON w.file = m.file;