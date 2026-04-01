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
