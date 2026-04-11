/*6*/
WITH quick_recipes AS (
    SELECT recipe_id, name, minutes
    FROM recipes
    WHERE minutes > 0
      AND minutes <= 30
),
recipe_stats AS (
    SELECT 
        i.recipe_id,
        COUNT(i.interaction_id) AS num_reviews,
        AVG(i.rating) AS avg_rating
    FROM interactions i
    JOIN quick_recipes qr
        ON i.recipe_id = qr.recipe_id
    WHERE i.rating > 0
    GROUP BY i.recipe_id
    HAVING COUNT(i.interaction_id) >= 20
       AND AVG(i.rating) >= 4.5
)
SELECT 
    qr.recipe_id,
    qr.name,
    qr.minutes,
    rs.num_reviews,
    ROUND(rs.avg_rating, 2) AS avg_rating
FROM quick_recipes qr
JOIN recipe_stats rs
    ON qr.recipe_id = rs.recipe_id
ORDER BY rs.avg_rating DESC, rs.num_reviews DESC
LIMIT 15;
/*9*/
this is the 9 



WITH ingredient_counts AS (
    SELECT 
        recipe_id,
        COUNT(*) AS num_ingredients
    FROM recipe_ingredients
    GROUP BY recipe_id
),
avg_ingredients AS (
    SELECT AVG(num_ingredients) AS avg_num_ingredients
    FROM ingredient_counts
)
SELECT 
    r.recipe_id,
    r.name,
    ic.num_ingredients
FROM recipes r
JOIN ingredient_counts ic
    ON r.recipe_id = ic.recipe_id
CROSS JOIN avg_ingredients ai
WHERE ic.num_ingredients > ai.avg_num_ingredients
ORDER BY ic.num_ingredients DESC
LIMIT 15;


----------------------Luis-----------------------
/*7*/

CREATE INDEX idx_interactions_rating_recipe
ON interactions(rating, recipe_id);

CREATE VIEW recipe_review_stats AS
SELECT recipe_id, COUNT(interaction_id) AS num_reviews, AVG(rating) AS avg_rating
FROM interactions
WHERE rating > 0
GROUP BY recipe_id;

/*DROP INDEX idx_interactions_rating_recipe ON interactions;*/
SELECT r.recipe_id, r.name, r.minutes, v.num_reviews, ROUND(v.avg_rating, 2) AS avg_rating
FROM recipes r
JOIN recipe_review_stats v ON r.recipe_id = v.recipe_id
WHERE v.num_reviews >= 50
ORDER BY v.avg_rating DESC, v.num_reviews DESC
LIMIT 15;




/*10*/
SELECT
    r.recipe_id,
    r.name,
    s.num_steps,
    x.num_reviews,
    ROUND(x.avg_rating, 2) AS avg_rating
FROM recipes r
JOIN (
    SELECT
        recipe_id,
        COUNT(*) AS num_steps
    FROM recipe_steps
    GROUP BY recipe_id
) AS s
    ON r.recipe_id = s.recipe_id
JOIN (
    SELECT
        recipe_id,
        COUNT(interaction_id) AS num_reviews,
        AVG(rating) AS avg_rating
    FROM interactions
    WHERE rating > 0
    GROUP BY recipe_id
    HAVING COUNT(interaction_id) >= 20
       AND AVG(rating) >= 4.0
) AS x
    ON r.recipe_id = x.recipe_id
WHERE s.num_steps > (
    SELECT AVG(step_count)
    FROM (
        SELECT COUNT(*) AS step_count
        FROM recipe_steps
        GROUP BY recipe_id
    ) AS step_stats
)
ORDER BY s.num_steps DESC, x.avg_rating DESC
LIMIT 15;