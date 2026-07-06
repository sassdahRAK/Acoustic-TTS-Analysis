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

-- see average mos
SELECT AVG(MOS) FROM wav_analysis;
-- end: 2.70202542874039

-- see highest mos
SELECT *
FROM wav_analysis
ORDER BY MOS DESC
LIMIT 10;
