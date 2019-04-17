CREATE DATABASE movie_comics;

USE movie_comics;

-- Load Table
CREATE TABLE `character` (
  `CHARACTER_ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `CHARACTER` varchar(100),
  `ID` varchar(50),
  `ALIGN` varchar(50),
  `EYE` varchar(50),
  `HAIR` varchar(50),
  `ALIVE` varchar(50),
  PRIMARY KEY (`CHARACTER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

-- Load Table
CREATE TABLE `movie_character` (
  `MOVIE_CHARACTER_ID` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `CHARACTER` varchar(400),
  `ID` int,
  `MOVIE_CHARACTER` varchar(400),
  PRIMARY KEY (`MOVIE_CHARACTER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

-- Load Table
CREATE TABLE `movie_metadata` (
  `MOVIE_METADATA_ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `ID` int,
  `ORIGINAL_TITLE` varchar(150),
  `REVENUE` DECIMAL(18,2),
  `TITLE` varchar(150),
  `VOTE_AVERAGE` DECIMAL(18,2),
  `VOTE_COUNT` DECIMAL(18,2),
  PRIMARY KEY (`MOVIE_METADATA_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

-- Load data from character.csv, movie_character.csv, and movie_metadata.csv
-- Map to corresponding output field in the import wizard
-- when importing movie_character, dropped 2257 out of 562474
-- when importing movie_metadata, dropped 3631 out of 45466

-- Transformed table with unique records based on CHARACTER_KEY 
CREATE TABLE `character_` (
  `CHARACTER_ID` int UNSIGNED NOT NULL,
  `CHARACTER_KEY` varchar(100),
  `CHARACTER_NAME` varchar(100),
  `CHARACTER_IDENTITY` varchar(50),
  `ALIGN` varchar(50),
  `EYE` varchar(50),
  `HAIR` varchar(50),
  `ALIVE` varchar(50),
  `CNT_CHARACTER_KEY_COMIC` int,
  PRIMARY KEY (`CHARACTER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

ALTER TABLE `movie_comics`.`character_` 
ADD INDEX `idx_CHARACTER_KEY` (`CHARACTER_KEY`);

-- Transformed table with unique records based on MOVIE_ID and CHARACTER_KEY
CREATE TABLE `movie_character_min_id` (
  `MOVIE_CHARACTER_ID` int(11) UNSIGNED NOT NULL,
  `MOVIE_ID` int,
  `CHARACTER_KEY` varchar(400),
  `CNT_CHARACTER_KEY_MOVIE` int,
  PRIMARY KEY (`MOVIE_CHARACTER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

ALTER TABLE `movie_comics`.`movie_character_min_id` 
ADD INDEX `idx_CHARACTER_KEY` (`CHARACTER_KEY`);

-- Transformed table with unique records based on MOVIE_ID and CHARACTER_KEY and additional attributes
CREATE TABLE `movie_character_` (
  `MOVIE_CHARACTER_ID` int(11) UNSIGNED NOT NULL,
  `CHARACTER_KEY` varchar(400),
  `CHARACTER_NAME` varchar(400),
  `MOVIE_ID` int,
  `MOVIE_CHARACTER` varchar(400),
  `CNT_CHARACTER_KEY_MOVIE` int,
  PRIMARY KEY (`MOVIE_CHARACTER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

ALTER TABLE `movie_comics`.`movie_character_` 
ADD INDEX `idx_CHARACTER_KEY` (`CHARACTER_KEY`);

ALTER TABLE `movie_comics`.`movie_character_` 
ADD INDEX `idx_MOVIE_ID` (`MOVIE_ID`);

-- Transformed table with unique records based on MOVIE_ID
CREATE TABLE `movie_metadata_` (
  `MOVIE_METADATA_ID` int UNSIGNED NOT NULL,
  `MOVIE_ID` int,
  `ORIGINAL_TITLE` varchar(150),
  `REVENUE` DECIMAL(18,2),
  `TITLE` varchar(150),
  `VOTE_AVERAGE` DECIMAL(18,2),
  `VOTE_COUNT` DECIMAL(18,2),
  `CNT_MOVIE_METADATA` int,
  PRIMARY KEY (`MOVIE_METADATA_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

ALTER TABLE `movie_comics`.`movie_metadata_` 
ADD INDEX `idx_MOVIE_ID` (`MOVIE_ID`);

INSERT INTO `movie_comics`.`character_`
(
    `CHARACTER_ID`,
    `CHARACTER_KEY`,
    `CHARACTER_NAME`,
    `CHARACTER_IDENTITY`,
    `ALIGN`,
    `EYE`,
    `HAIR`,
    `ALIVE`,
    `CNT_CHARACTER_KEY_COMIC`
)
-- Eliminates duplicates by selecting only the lowest CHARACTER_ID for any given CHARACTER_KEY
SELECT 
    a.CHARACTER_ID,
    UPPER(TRIM(REPLACE(REPLACE(a.CHARACTER,'-',''),' ',''))) AS CHARACTER_KEY,
    a.CHARACTER AS CHARACTER_NAME,
    a.ID AS CHARACTER_IDENTITY,
    a.ALIGN,
    a.EYE,
    a.HAIR,
    a.ALIVE,
    b.CNT AS CNT_CHARACTER_KEY_COMIC
FROM movie_comics.character a
-- Identifies lowest CHARACTER_ID for any given CHARACTER_KEY
JOIN ( SELECT
		   MIN(b1.CHARACTER_ID) AS CHARACTER_ID,
           UPPER(TRIM(REPLACE(REPLACE(b1.CHARACTER,'-',''),' ',''))) AS CHARACTER_KEY,
           COUNT(*) AS CNT
	   FROM movie_comics.character b1
       WHERE IFNULL(TRIM(b1.CHARACTER),'') != ''
       GROUP BY
           UPPER(TRIM(REPLACE(REPLACE(b1.CHARACTER,'-',''),' ','')))
	  ) b
  ON a.CHARACTER_ID = b.CHARACTER_ID;

INSERT INTO `movie_comics`.`movie_character_min_id`
(
  `MOVIE_CHARACTER_ID`,
  `MOVIE_ID`,
  `CHARACTER_KEY`,
  `CNT_CHARACTER_KEY_MOVIE`
)
-- Identifies lowest MOVIE_CHARACTER_ID for any given CHARACTER_KEY
SELECT
	MIN(b1.MOVIE_CHARACTER_ID) AS MOVIE_CHARACTER_ID,
	b1.ID AS MOVIE_ID,
    UPPER(TRIM(REPLACE(REPLACE(b1.MOVIE_CHARACTER,'-',''),' ',''))) AS CHARACTER_KEY,
    COUNT(*) AS CNT_CHARACTER_KEY_MOVIE
FROM movie_comics.movie_character b1
WHERE IFNULL(TRIM(UPPER(TRIM(REPLACE(REPLACE(b1.MOVIE_CHARACTER,'-',''),' ','')))),'') != ''
GROUP BY
	b1.ID,
    UPPER(TRIM(REPLACE(REPLACE(b1.MOVIE_CHARACTER,'-',''),' ','')));

INSERT INTO `movie_comics`.`movie_character_`
(
  `MOVIE_CHARACTER_ID`,
  `CHARACTER_KEY`,
  `CHARACTER_NAME`,
  `MOVIE_ID`,
  `MOVIE_CHARACTER`,
  `CNT_CHARACTER_KEY_MOVIE`
)
-- Eliminates duplicates by selecting only the lowest MOVIE_CHARACTER_ID for any given CHARACTER_KEY
SELECT 
	a.MOVIE_CHARACTER_ID,
    UPPER(TRIM(REPLACE(REPLACE(a.MOVIE_CHARACTER,'-',''),' ',''))) AS CHARACTER_KEY,
	a.CHARACTER AS CHARACTER_NAME,
	a.ID AS MOVIE_ID,
	a.MOVIE_CHARACTER,
    b.CNT_CHARACTER_KEY_MOVIE
FROM movie_comics.movie_character a
JOIN movie_comics.movie_character_min_id b
  ON a.MOVIE_CHARACTER_ID = b.MOVIE_CHARACTER_ID;

INSERT INTO `movie_comics`.`movie_metadata_`
(
  `MOVIE_METADATA_ID`,
  `MOVIE_ID`,
  `ORIGINAL_TITLE`,
  `REVENUE`,
  `TITLE`,
  `VOTE_AVERAGE`,
  `VOTE_COUNT`,
  `CNT_MOVIE_METADATA`
)
-- Eliminates duplicates by selecting only the lowest MOVIE_METADATA_ID for any given MOVIE_ID
SELECT 
	a.MOVIE_METADATA_ID,
	a.ID AS MOVIE_ID,
	a.ORIGINAL_TITLE,
	a.REVENUE,
	a.TITLE,
	a.VOTE_AVERAGE,
	a.VOTE_COUNT,
	b.CNT AS MOVIE_METADATA_CNT
FROM movie_comics.movie_metadata a
-- Identifies lowest MOVIE_METADATA_ID for any given MOVIE_ID
JOIN ( SELECT
		   MIN(b1.MOVIE_METADATA_ID) AS MOVIE_METADATA_ID,
	       b1.ID AS MOVIE_ID,
           COUNT(*) AS CNT
	   FROM movie_comics.movie_metadata b1
      --  WHERE IFNULL(TRIM(b1.MOVIE_METADATA_ID),'') = ''
       GROUP BY
	       b1.ID
	  ) b
  ON a.MOVIE_METADATA_ID = b.MOVIE_METADATA_ID;

-- All columns from Joining tables
SELECT 
    a.CHARACTER_ID,
    a.CHARACTER_KEY,
    a.CHARACTER_NAME AS COMIC_CHARACTER_NAME,
    a.CHARACTER_IDENTITY,
    a.ALIGN,
    a.EYE,
    a.HAIR,
    a.ALIVE,
    a.CNT_CHARACTER_KEY_COMIC,
    b.MOVIE_CHARACTER_ID,
    b.CHARACTER_KEY,
    b.CHARACTER_NAME AS MOVIE_CHARACTER_NAME,
    b.MOVIE_ID,
    b.MOVIE_CHARACTER,
    b.CNT_CHARACTER_KEY_MOVIE,
    c.MOVIE_METADATA_ID,
    c.MOVIE_ID,
    c.ORIGINAL_TITLE,
    c.REVENUE,
    c.TITLE,
    c.VOTE_AVERAGE,
    c.VOTE_COUNT,
    c.CNT_MOVIE_METADATA
FROM movie_comics.character_ a
JOIN movie_comics.movie_character_ b
  ON a.CHARACTER_KEY = b.CHARACTER_KEY
JOIN movie_comics.movie_metadata_ c
  ON b.MOVIE_ID = c.MOVIE_ID
-- WHERE a.CHARACTER_ID = 15363
LIMIT 1000;

SELECT 
    a.CHARACTER_ID,
    a.CHARACTER_KEY,
    a.CHARACTER_NAME AS COMIC_CHARACTER_NAME,
    a.CHARACTER_IDENTITY,
    a.ALIGN,
    a.EYE,
    a.HAIR,
    a.ALIVE,
    SUM(c.REVENUE) AS TOTAL_REVENUE
FROM movie_comics.character_ a
JOIN movie_comics.movie_character_ b
  ON a.CHARACTER_KEY = b.CHARACTER_KEY
JOIN movie_comics.movie_metadata_ c
  ON b.MOVIE_ID = c.MOVIE_ID
WHERE a.CHARACTER_KEY IN ('SPIDERMAN','CAPTAINAMERICA','WOLVERINE','IRONMAN','THOR','HULK','VISION','HERCULES','DEADPOOL','VENOM','THANOS','MEPHISTO','MANDARIN','ULTRON','PLUTO','LORELEI')
GROUP BY
    a.CHARACTER_ID,
    a.CHARACTER_KEY,
    a.CHARACTER_NAME,
    a.CHARACTER_IDENTITY,
    a.ALIGN,
    a.EYE,
    a.HAIR,
    a.ALIVE
ORDER BY
    9 DESC,
    a.CHARACTER_NAME;

