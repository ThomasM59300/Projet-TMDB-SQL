--- Difficulté croissante

--- 1. La popularité de Adam Sandler 

SELECT DISTINCT ON(acteur_id) nom, popularite
FROM films_acteurs f
JOIN acteurs a
ON a.id = f.acteur_id
WHERE nom = 'Adam Sandler';

--- 2. Les 10 films les plus populaires

SELECT titre, note_moyenne
FROM films
WHERE nb_votes > 5000
ORDER BY note_moyenne DESC
LIMIT 10; 


--- 3. Un gros box office signifie il toujours le succès 

SELECT
    revenu - budget AS benefice,
    note_moyenne
FROM films
WHERE revenu IS NOT NULL AND budget IS NOT NULL AND note_moyenne IS NOT NULL
AND (revenu - budget) > 0;
--- NB : mesure pour exporter et faire un nuage de point dans POWER BI


--- 4. Les meilleurs producteurs en termes de BOX OFFICE

WITH cte AS (
SELECT 
	nom_entreprise, producteur_id, titre, budget, revenu,
	revenu - budget AS box_office
FROM producteurs AS p
JOIN films_producteurs AS fp
ON p.id = fp.producteur_id
JOIN films AS f
ON fp.film_id = f.id)

SELECT 
	nom_entreprise AS producteur,
	SUM(box_office) AS box_office_total
FROM cte
GROUP BY producteur_id, producteur
ORDER BY box_office_total DESC
LIMIT 20;


--- 5. Les meilleurs réalisateurs en termes de BOX OFFICE

WITH top_real AS (
	SELECT nom, realisateur_id, budget, revenu,
	revenu - budget AS box_office
	FROM realisateurs AS r
	JOIN films_realisateurs AS fr
	ON r.id = fr.realisateur_id 
	JOIN films AS f
	ON f.id = fr.film_id
)

SELECT 
	nom AS realisateur, 
	SUM(box_office) AS box_office_total
FROM top_real
GROUP BY realisateur_id, nom
ORDER BY box_office_total DESC
LIMIT 20;

--- 6. Les films les plus populaires de chaque année

WITH cte_annee AS (
    SELECT 
        titre,
        EXTRACT(YEAR FROM date_sortie) AS annee,
        note_moyenne,
        nb_votes
    FROM films
    WHERE nb_votes > 2000 
),
classement AS (
    SELECT 
        titre,
        annee,
        note_moyenne,
        DENSE_RANK() OVER (PARTITION BY annee ORDER BY note_moyenne DESC) AS rang
    FROM cte_annee
)

SELECT titre, annee, note_moyenne
FROM classement
WHERE rang = 1
ORDER BY annee;


--- 7. Les genres qui engrangent les plus gros revenus 

WITH jointures AS (
SELECT genre, genre_id, titre, revenu - budget AS benefice
FROM genres AS g
JOIN films_genres AS fg
ON g.id = fg.genre_id
JOIN films AS f
ON f.id = fg.film_id
WHERE revenu IS NOT NULL AND budget IS NOT NULL) 

SELECT 
	genre, 
	ROUND(
	(SUM(benefice) ::numeric * 100 /
	(SELECT SUM(benefice) FROM jointures) ::numeric)
	, 2)
	AS proportion 
FROM jointures
GROUP BY genre
ORDER BY proportion DESC;


--- 8. Top 3 films par décennies

WITH 
	groupage AS (
	SELECT 
		titre, date_sortie, note_moyenne, nb_votes,
		CASE 
			WHEN EXTRACT(YEAR FROM date_sortie) BETWEEN 1980 AND 1990 THEN 1 
			WHEN EXTRACT(YEAR FROM date_sortie) BETWEEN 1991 AND 2000 THEN 2
			WHEN EXTRACT(YEAR FROM date_sortie) BETWEEN 2001 AND 2010 THEN 3
			WHEN EXTRACT(YEAR FROM date_sortie) BETWEEN 2011 AND 2020 THEN 4
			ELSE 5 END 
			AS groupe
	FROM films),
	classement AS (
	SELECT 
		titre, date_sortie, note_moyenne,
		ROW_NUMBER() OVER (PARTITION BY groupe ORDER BY note_moyenne DESC)
		AS rang
		FROM groupage
		WHERE nb_votes > 1000
	)

SELECT titre, date_sortie, note_moyenne 
FROM classement 
WHERE rang <= 3 
ORDER BY date_sortie;


--- 9. Les acteurs les plus populaires engendrent ils un meilleurs box office ? 

WITH 
	triple_jointure AS (
		SELECT nom, acteur_id, popularite, revenu - budget AS benefice
		FROM acteurs AS a
		JOIN films_acteurs AS fa 
		ON a.id = fa.acteur_id
		JOIN films AS f
		ON f.id = fa.film_id
		WHERE revenu IS NOT NULL AND budget IS NOT NULL),
	pour_popu_avg AS (
		SELECT DISTINCT ON(acteur_id) acteur_id, popularite
		FROM films_acteurs
		WHERE popularite IS NOT NULL AND popularite > 0)

SELECT 
	nom,
	SUM(benefice) AS benefice, 
	CONCAT(
	ROUND(
	( (AVG(popularite)::numeric *100) /
	(SELECT AVG(popularite)::numeric FROM pour_popu_avg) ), 2), '', '%')
	AS comparaison
FROM triple_jointure
GROUP BY acteur_id, nom
ORDER BY benefice DESC
LIMIT 20;
--- NB : la colonne comparaison est le rapport entre la popularité de l'acteur et la popularité moyenne de tout les acteurs

--- 10. Chaque meilleur film de chaque année, comparé au budget moyen des autres film de cette même année 

WITH 
	cte AS (
	SELECT 
	annee, titre, budget,
	RANK() OVER (PARTITION BY annee ORDER BY note_moyenne DESC, nb_votes DESC) AS rang
	FROM (SELECT *, EXTRACT(YEAR FROM date_sortie) AS annee FROM films)
	WHERE nb_votes > 2000),
	budget_moyen_an AS ( 
	SELECT 
	ROUND(AVG(budget)::numeric, 0) AS budget_moyen, 
	EXTRACT(YEAR FROM date_sortie) AS annee
	FROM films
	WHERE budget IS NOT NULL AND budget > 0
	GROUP BY EXTRACT(YEAR FROM date_sortie))

SELECT 
	c.annee, titre, budget AS budget_film, budget_moyen,
	budget - budget_moyen AS difference,
	CONCAT(
	ROUND((budget - budget_moyen)::numeric * 100 
	/ budget_moyen, 2), '','%') AS ecart_pourcent
	FROM cte AS c
	JOIN budget_moyen_an AS b
	ON c.annee = b.annee
	WHERE rang = 1
	ORDER BY annee;


--- 11. Les duo d'acteurs qui apparaissent le plus souvent ensemble

WITH 
	duo AS (
		SELECT a.acteur_id AS ID_a, b.acteur_id AS ID_b,
		COUNT(*) AS tournage_ensemble
		FROM films_acteurs AS a 
		JOIN films_acteurs AS b
		ON a.film_id = b.film_id 
		AND a.acteur_id < b.acteur_id
		AND a.popularite > 6
		GROUP BY a.acteur_id, b.acteur_id
		ORDER BY tournage_ensemble DESC
		LIMIT 5),
	cte2 AS (
		SELECT d.film_id, d.acteur_id AS ID_a2, e.acteur_id AS ID_b2, f.titre
		FROM films_acteurs AS d
		JOIN films_acteurs AS e
		ON d.film_id = e.film_id AND d.acteur_id < e.acteur_id
		JOIN films AS f
		ON f.id = d.film_id)


SELECT CONCAT(a.nom,' & ',b.nom) AS Duo, titre AS titre_film
FROM duo
JOIN acteurs AS a
ON a.id = duo.ID_a
JOIN acteurs AS b
ON b.id = duo.ID_b
JOIN cte2 
ON ID_a = cte2.ID_a2 AND ID_b = cte2.ID_b2
ORDER BY duo;


--- 12. Proportion des 10, 100 et 500 plus gros bénéfices, par rapport aux benefices totaux

WITH classement_benef AS (
	SELECT  
		titre,
		benefice,
		DENSE_RANK() OVER (ORDER BY benefice DESC) AS rang 
		FROM (
			SELECT titre, revenu - budget AS benefice
			FROM films
			WHERE revenu IS NOT NULL AND budget IS NOT NULL 
			AND revenu - budget > 0)
)

SELECT 
	10 AS proportion, 
	ROUND(
		( SUM(benefice)::numeric * 100 ) / 
		(SELECT SUM(benefice)::numeric FROM classement_benef), 	
		2) AS pourcentage
FROM classement_benef
WHERE rang <= 10

UNION ALL 

SELECT 
	100 AS proportion, 
	ROUND(
		(SUM(benefice)::numeric * 100) / 
		(SELECT SUM(benefice)::numeric FROM classement_benef) ,
		2) AS pourcentage
FROM classement_benef
WHERE rang <= 100 

UNION ALL 

SELECT 
	500 AS proportion,
	ROUND(
		(SUM(benefice)::numeric * 100) / 
		(SELECT SUM(benefice)::numeric FROM classement_benef), 
		2) AS pourcentage
FROM classement_benef
WHERE rang <= 500;