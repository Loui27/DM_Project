DROP DATABASE IF EXISTS foodcom_db;
CREATE DATABASE foodcom_db;
USE foodcom_db;

-- Tablas raw / staging
CREATE TABLE raw_recipes (
    id INT,
    name TEXT,
    minutes INT,
    contributor_id INT,
    submitted DATE,
    tags LONGTEXT,
    nutrition LONGTEXT,
    n_steps INT,
    steps LONGTEXT,
    description LONGTEXT,
    ingredients LONGTEXT,
    n_ingredients INT
);

CREATE TABLE raw_interactions (
    user_id INT,
    recipe_id INT,
    interaction_date DATE,
    rating INT,
    review LONGTEXT
);
SHOW TABLES;

-- Load data into raw / staging tables

USE foodcom_db;

TRUNCATE TABLE raw_recipes;
TRUNCATE TABLE raw_interactions;

LOAD DATA LOCAL INFILE 'C:/Users/Luis/OneDrive/Documentos/Cursos_Sapienza/DM/Project_food/raw_recipes_clean.csv'
INTO TABLE raw_recipes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, name, minutes, contributor_id, submitted, tags, nutrition, n_steps, steps, description, ingredients, n_ingredients);

LOAD DATA LOCAL INFILE 'C:/Users/Luis/OneDrive/Documentos/Cursos_Sapienza/DM/Project_food/raw_interactions_clean.csv'
INTO TABLE raw_interactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, recipe_id, interaction_date, rating, review);

SELECT COUNT(*) AS recipes_count
FROM raw_recipes;

SELECT COUNT(*) AS interactions_count
FROM raw_interactions;

-- final tables

USE foodcom_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY
);

CREATE TABLE recipes (
    recipe_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    minutes INT,
    contributor_id INT,
    submitted DATE,
    description TEXT,
    n_steps INT,
    n_ingredients INT
);

CREATE TABLE interactions (
    interaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    recipe_id INT NOT NULL,
    interaction_date DATE,
    rating INT,
    review TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id),
    CHECK (rating BETWEEN 0 AND 5)
);

CREATE TABLE recipe_steps (
    recipe_id INT NOT NULL,
    step_no INT NOT NULL,
    step_text TEXT NOT NULL,
    PRIMARY KEY (recipe_id, step_no),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
);

CREATE TABLE recipe_ingredients (
    recipe_id INT NOT NULL,
    ingredient_no INT NOT NULL,
    ingredient_text TEXT NOT NULL,
    PRIMARY KEY (recipe_id, ingredient_no),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
);

CREATE TABLE tags (
    tag_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE recipe_tags (
    recipe_id INT NOT NULL,
    tag_id BIGINT NOT NULL,
    PRIMARY KEY (recipe_id, tag_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);

-- Separate steps, ingredients, and tags into sus respectivas tablas

USE foodcom_db;

INSERT INTO users (user_id)
SELECT DISTINCT user_id
FROM raw_interactions
WHERE user_id IS NOT NULL;

SELECT COUNT(*) AS users_count
FROM users;


INSERT INTO recipes (
    recipe_id, name, minutes, contributor_id, submitted, description, n_steps, n_ingredients
)
SELECT
    id,
    name,
    minutes,
    contributor_id,
    submitted,
    description,
    n_steps,
    n_ingredients
FROM raw_recipes
WHERE id IS NOT NULL;

SELECT COUNT(*) AS recipes_count
FROM recipes;

INSERT INTO interactions (
    user_id, recipe_id, interaction_date, rating, review
)
SELECT
    ri.user_id,
    ri.recipe_id,
    ri.interaction_date,
    ri.rating,
    ri.review
FROM raw_interactions ri
JOIN users u
    ON ri.user_id = u.user_id
JOIN recipes r
    ON ri.recipe_id = r.recipe_id;

SELECT COUNT(*) AS interactions_count
FROM interactions;

--You must intorudce the interactions in batches, because of the size of the table and the foreign key constraints. 
--You can adjust the LIMIT and OFFSET values as needed to insert all records.

INSERT INTO interactions (
    user_id, recipe_id, interaction_date, rating, review
)
SELECT
    user_id,
    recipe_id,
    interaction_date,
    rating,
    review
FROM raw_interactions
LIMIT 10000;

INSERT INTO interactions (
    user_id, recipe_id, interaction_date, rating, review
)
SELECT
    user_id,
    recipe_id,
    interaction_date,
    rating,
    review
FROM raw_interactions
LIMIT 10000 OFFSET 0;
*/
INSERT INTO interactions (
    user_id, recipe_id, interaction_date, rating, review
)
SELECT
    user_id,
    recipe_id,
    interaction_date,
    rating,
    review
FROM raw_interactions
LIMIT 32266;

SELECT COUNT(*) AS interactions_count
FROM interactions;

-- Load steps, ingredients, and tags from the cleaned CSV files into their respective tables

LOAD DATA LOCAL INFILE 'C:/Users/Luis/OneDrive/Documentos/Cursos_Sapienza/DM/Project_food/clean_recipe_steps.csv'
INTO TABLE recipe_steps
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(recipe_id, step_no, step_text);

LOAD DATA LOCAL INFILE 'C:/Users/Luis/OneDrive/Documentos/Cursos_Sapienza/DM/Project_food/clean_recipe_ingredients.csv'
INTO TABLE recipe_ingredients
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(recipe_id, ingredient_no, ingredient_text);

LOAD DATA LOCAL INFILE 'C:/Users/Luis/OneDrive/Documentos/Cursos_Sapienza/DM/Project_food/clean_tags.csv'
INTO TABLE tags
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tag_id, tag_name);

--it makes error, verify the count of the data, it must be 4141579 records, if not, adjust the LIMIT and OFFSET values as needed to insert all records.

LOAD DATA LOCAL INFILE 'C:/Users/Luis/OneDrive/Documentos/Cursos_Sapienza/DM/Project_food/clean_recipe_tags.csv'
INTO TABLE recipe_tags
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(recipe_id, tag_id);
