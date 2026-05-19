-- 1. 连接到 universe 数据库
\c universe

-- ================== 第一步：创建所有表格 ==================

-- 创建 galaxy (星系) 表
CREATE TABLE galaxy (
    galaxy_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    galaxy_type TEXT NOT NULL,
    description TEXT,
    has_spiral_structure BOOLEAN NOT NULL,
    distance_from_earth NUMERIC
);

-- 创建 star (恒星) 表
CREATE TABLE star (
    star_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    constellation TEXT NOT NULL,
    spectral_class VARCHAR(20),
    is_visible_to_naked_eye BOOLEAN NOT NULL,
    galaxy_id INT NOT NULL,
    FOREIGN KEY (galaxy_id) REFERENCES galaxy(galaxy_id)
);

-- 创建 planet (行星) 表
CREATE TABLE planet (
    planet_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    has_atmosphere BOOLEAN NOT NULL,
    mass_in_earth_units NUMERIC,
    orbital_period_days INT NOT NULL,
    star_id INT NOT NULL,
    FOREIGN KEY (star_id) REFERENCES star(star_id)
);

-- 创建 moon (卫星) 表
CREATE TABLE moon (
    moon_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    discovered_by TEXT,
    discovery_year INT,
    is_spherical BOOLEAN NOT NULL,
    planet_id INT NOT NULL,
    FOREIGN KEY (planet_id) REFERENCES planet(planet_id)
);

-- 创建 asteroid (小行星) 表 - 补齐第5张表
CREATE TABLE asteroid (
    asteroid_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    asteroid_type TEXT NOT NULL,
    discovery_year INT NOT NULL,
    is_potentially_hazardous BOOLEAN NOT NULL,
    star_id INT NOT NULL,
    FOREIGN KEY (star_id) REFERENCES star(star_id)
);

-- ================== 第二步：插入所有数据 ==================

-- 插入 Galaxy 数据 (7行)
INSERT INTO galaxy (name, galaxy_type, description, has_spiral_structure, distance_from_earth) VALUES
('Milky Way', 'Spiral', 'Our home galaxy', TRUE, 0),
('Andromeda', 'Spiral', 'Nearest major galaxy', TRUE, 2.537),
('Triangulum', 'Spiral', 'Third largest in Local Group', TRUE, 2.73),
('Centaurus A', 'Lenticular', 'Prominent radio source', FALSE, 13.7),
('Sombrero', 'Spiral', 'High dust lane', TRUE, 29.3),
('Whirlpool', 'Spiral', 'Classic spiral structure', TRUE, 23.0),
('Cartwheel', 'Ring', 'Rare ring galaxy', FALSE, 40.0);

-- 插入 Star 数据 (7行)
INSERT INTO star (name, constellation, spectral_class, is_visible_to_naked_eye, galaxy_id) VALUES
('Sun', 'N/A', 'G2V', TRUE, 1),
('Sirius', 'Canis Major', 'A1V', TRUE, 1),
('Betelgeuse', 'Orion', 'M1-2', TRUE, 1),
('Vega', 'Lyra', 'A0V', TRUE, 1),
('Rigel', 'Orion', 'B8Ia', TRUE, 1),
('Proxima Centauri', 'Centaurus', 'M5.5Ve', FALSE, 1),
('Polaris', 'Ursa Minor', 'F7Ib', TRUE, 1);

-- 插入 Planet 数据 (13行)
INSERT INTO planet (name, has_atmosphere, mass_in_earth_units, orbital_period_days, star_id) VALUES
('Mercury', TRUE, 0.055, 88, 1),
('Venus', TRUE, 0.815, 225, 1),
('Earth', TRUE, 1.0, 365, 1),
('Mars', TRUE, 0.107, 687, 1),
('Jupiter', TRUE, 317.8, 4333, 1),
('Saturn', TRUE, 95.2, 10759, 1),
('Uranus', TRUE, 14.5, 30687, 1),
('Neptune', TRUE, 17.1, 60190, 1),
('Proxima b', TRUE, 1.17, 11, 6),
('Sirius b', FALSE, 0.98, 18260, 2),
('Kepler-186f', TRUE, 1.0, 130, 2),
('TRAPPIST-1e', TRUE, 0.69, 6, 3),
('HD 209458 b', TRUE, 0.69, 3.5, 4);

-- 插入 Moon 数据 (22行)
INSERT INTO moon (name, discovered_by, discovery_year, is_spherical, planet_id) VALUES
('Moon', 'Unknown', -1, TRUE, 3),
('Phobos', 'Asaph Hall', 1877, FALSE, 4),
('Deimos', 'Asaph Hall', 1877, FALSE, 4),
('Io', 'Galileo Galilei', 1610, TRUE, 5),
('Europa', 'Galileo Galilei', 1610, TRUE, 5),
('Ganymede', 'Galileo Galilei', 1610, TRUE, 5),
('Callisto', 'Galileo Galilei', 1610, TRUE, 5),
('Titan', 'Christiaan Huygens', 1655, TRUE, 6),
('Enceladus', 'William Herschel', 1789, TRUE, 6),
('Mimas', 'William Herschel', 1789, TRUE, 6),
('Tethys', 'Cassini', 1684, TRUE, 6),
('Dione', 'Cassini', 1684, TRUE, 6),
('Rhea', 'Cassini', 1672, TRUE, 6),
('Iapetus', 'Cassini', 1671, TRUE, 6),
('Miranda', 'Gerard Kuiper', 1948, TRUE, 7),
('Ariel', 'William Lassell', 1851, TRUE, 7),
('Umbriel', 'William Lassell', 1851, TRUE, 7),
('Titania', 'William Herschel', 1787, TRUE, 7),
('Oberon', 'William Herschel', 1787, TRUE, 7),
('Triton', 'William Lassell', 1846, TRUE, 8),
('Proteus', 'Voyager 2', 1989, FALSE, 8),
('Nereid', 'Kuiper', 1949, FALSE, 8);

-- 插入 Asteroid 数据 (6行)
INSERT INTO asteroid (name, asteroid_type, discovery_year, is_potentially_hazardous, star_id) VALUES
('Ceres', 'Dwarf Planet', 1801, FALSE, 1),
('Vesta', 'Main Belt', 1807, FALSE, 1),
('Pallas', 'Main Belt', 1802, FALSE, 1),
('Hygiea', 'Main Belt', 1849, FALSE, 1),
('Eros', 'Near-Earth', 1898, TRUE, 1),
('Bennu', 'Near-Earth', 1999, TRUE, 1);
