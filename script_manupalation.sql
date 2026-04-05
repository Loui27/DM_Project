/*Queries*/
SELECT recipe_id, name, minutes
FROM recipes
WHERE minutes > 0
  AND minutes < 30
ORDER BY minutes, name;

/*2*/
SELECT r.name, i.user_id, i.rating, i.interaction_date
FROM recipes r
JOIN interactions i ON r.recipe_id = i.recipe_id
WHERE i.rating > 0
ORDER BY i.rating DESC, i.interaction_date DESC;

/*3*/

SELECT DISTINCT i.user_id
FROM interactions i
JOIN recipes r ON i.recipe_id = r.recipe_id
WHERE r.minutes > 60;

/*4*/

SELECT r.recipe_id, r.name, AVG(i.rating) AS avg_rating
FROM recipes r
JOIN interactions i ON r.recipe_id = i.recipe_id
WHERE i.rating > 0
GROUP BY r.recipe_id, r.name
ORDER BY avg_rating DESC;

/*5*/

SELECT r.recipe_id, r.name, COUNT(*) AS num_reviews, AVG(i.rating) AS avg_rating
FROM recipes r
JOIN interactions i ON r.recipe_id = i.recipe_id
WHERE i.rating > 0
GROUP BY r.recipe_id, r.name
HAVING COUNT(*) >= 20 AND AVG(i.rating) > 4
ORDER BY avg_rating DESC, num_reviews DESC;

/*6*/
SELECT 
    r.recipe_id,
    r.name,
    r.minutes,
    COUNT(i.interaction_id) AS num_reviews,
    ROUND(AVG(i.rating), 2) AS avg_rating
FROM recipes r
JOIN interactions i
    ON r.recipe_id = i.recipe_id
WHERE r.minutes <= 30
  AND i.rating > 0
GROUP BY r.recipe_id, r.name, r.minutes
HAVING COUNT(i.interaction_id) >= 20
   AND AVG(i.rating) >= 4.5
ORDER BY avg_rating DESC, num_reviews DESC
LIMIT 15;

/*7*/
SELECT 
    r.recipe_id,
    r.name,
    r.minutes,
    COUNT(i.interaction_id) AS num_reviews,
    ROUND(AVG(i.rating), 2) AS avg_rating
FROM recipes r
JOIN interactions i
    ON r.recipe_id = i.recipe_id
WHERE i.rating > 0
GROUP BY r.recipe_id, r.name, r.minutes
HAVING COUNT(i.interaction_id) >= 50
ORDER BY avg_rating DESC, num_reviews DESC
LIMIT 15;

/*8*/
SELECT 
    i.user_id,
    COUNT(i.interaction_id) AS num_reviews,
    ROUND(AVG(i.rating), 2) AS avg_given_rating
FROM interactions i
WHERE i.rating > 0
GROUP BY i.user_id
HAVING COUNT(i.interaction_id) >= 30
ORDER BY num_reviews DESC, avg_given_rating DESC
LIMIT 15;

/*9*/
SELECT 
    r.recipe_id,
    r.name,
    COUNT(ri.ingredient_no) AS num_ingredients
FROM recipes r
JOIN recipe_ingredients ri
    ON r.recipe_id = ri.recipe_id
GROUP BY r.recipe_id, r.name
HAVING COUNT(ri.ingredient_no) > (
    SELECT AVG(ingredient_count)
    FROM (
        SELECT COUNT(*) AS ingredient_count
        FROM recipe_ingredients
        GROUP BY recipe_id
    ) AS ingredient_stats
)
ORDER BY num_ingredients DESC
LIMIT 15;

/*10*/
SELECT 
    r.recipe_id,
    r.name,
    COUNT(DISTINCT rs.step_no) AS num_steps,
    COUNT(DISTINCT i.interaction_id) AS num_reviews,
    ROUND(AVG(i.rating), 2) AS avg_rating
FROM recipes r
JOIN recipe_steps rs
    ON r.recipe_id = rs.recipe_id
JOIN interactions i
    ON r.recipe_id = i.recipe_id
WHERE i.rating > 0
GROUP BY r.recipe_id, r.name
HAVING COUNT(DISTINCT rs.step_no) > (
    SELECT AVG(step_count)
    FROM (
        SELECT COUNT(*) AS step_count
        FROM recipe_steps
        GROUP BY recipe_id
    ) AS step_stats
)
AND COUNT(DISTINCT i.interaction_id) >= 20
AND AVG(i.rating) >= 4.0
ORDER BY num_steps DESC, avg_rating DESC
LIMIT 15;
