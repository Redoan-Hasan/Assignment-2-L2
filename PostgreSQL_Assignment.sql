-- Active: 1747767812993@@localhost@5432@conservation_db

-- Create the database
CREATE DATABASE conservation_db;

-- Creating rangers table
CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);


--creating species table
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) NOT NULL CHECK (conservation_status IN ('Endangered', 'Vulnerable', 'Historic'))
);

--creating sightings table
CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    ranger_id INT REFERENCES rangers(ranger_id) ON DELETE CASCADE,
    species_id INT REFERENCES species(species_id) ON DELETE CASCADE,
    sighting_time TIMESTAMP NOT NULL,
    location VARCHAR(100) NOT NULL,
    notes TEXT
);


--inserting data into rangers table 
INSERT INTO rangers (name, region)
VALUES
    ('Alice Green', 'Northern Hills'),
    ('Bob White', 'River Delta'),
    ('Carol King', 'Mountain Range');



--inserting data into species table
INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status)
VALUES
    ('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
    ('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
    ('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
    ('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');



--inserting data into sightings table
INSERT INTO sightings (ranger_id, species_id, sighting_time, location, notes)
VALUES
    (1, 1, '2024-05-10 07:45:00', 'Peak Ridge', 'Camera trap image captured'),
    (2, 2, '2024-05-12 16:20:00', 'Bankwood Area', 'Juvenile seen'),
    (3, 3, '2024-05-15 09:10:00', 'Bamboo Grove East', 'Feeding observed'),
    (2, 1, '2024-05-18 18:30:00', 'Snowfall Pass', NULL);


--problem 1️⃣ Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'
INSERT INTO rangers(name,region) VALUES('Derek Fox','Coastal Plains');


--problem 2️⃣ Count unique species ever sighted.
SELECT COUNT(DISTINCT species_id) AS unique_species_count FROM sightings;


--problem 3️⃣ Find all sightings where the location includes "Pass".
SELECT * FROM sightings 
WHERE location LIKE '%Pass%';

--problem 4️⃣ List each ranger's name and their total number of sightings.
SELECT rangers.name, COUNT(sightings.sighting_id) AS total_sightings FROM rangers
JOIN sightings ON rangers.ranger_id = sightings.ranger_id GROUP BY rangers.name;

--problem 5️⃣ List species that have never been sighted.
SELECT common_name FROM species
LEFT JOIN sightings ON species.species_id = sightings.species_id
WHERE sightings.species_id IS NULL;

--problem 6️⃣ Show the most recent 2 sightings.
SELECT common_name, sighting_time, name FROM sightings
JOIN rangers USING (ranger_id)  
JOIN species USING (species_id)
ORDER BY sighting_time DESC LIMIT 2;

--problem 7️⃣ Update all species discovered before year 1800 to have status 'Historic'.
UPDATE species
SET conservation_status = 'Historic'
WHERE EXTRACT(YEAR FROM discovery_date) < 1800


--problem 8️⃣ Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.
SELECT sighting_id ,
    CASE 
        WHEN EXTRACT(HOUR FROM sighting_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sighting_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sightings;

--problem 9️⃣ Delete rangers who have never sighted any species
DELETE FROM rangers 
WHERE rangers.ranger_id NOT IN (
    SELECT DISTINCT ranger_id FROM sightings
);