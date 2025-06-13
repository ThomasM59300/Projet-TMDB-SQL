import psycopg2
import json
import os
from dotenv import load_dotenv

load_dotenv()

# connexion à PostgreSQL
def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT")
    )

with open("test/films_us.json", encoding="utf-8") as f:
    films = json.load(f)

conn = get_connection()
cur = conn.cursor()

try:
    for i, film in enumerate(films, 1):
        details = film["film"]
        credits = film["credits"]

        # Insertion du film
        cur.execute("""
            INSERT INTO films (id, titre, date_sortie, budget, revenu, duree, note_moyenne, nb_votes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING;
        """, (
            details["id"],
            details["title"],
            details["release_date"],
            details["budget"],
            details["revenue"],
            details["runtime"],
            details["vote_average"],
            details["vote_count"]
        ))

        # Genres
        for genre in details.get("genres", []):
            cur.execute("""
                INSERT INTO genres (id, genre)
                VALUES (%s, %s)
                ON CONFLICT (id) DO NOTHING;
            """, (genre["id"], genre["name"]))

            cur.execute("""
                INSERT INTO films_genres (film_id, genre_id)
                VALUES (%s, %s)
                ON CONFLICT DO NOTHING;
            """, (details["id"], genre["id"]))

        # Acteurs (top 5)
        for acteur in credits.get("cast", [])[:5]:
            cur.execute("""
                INSERT INTO acteurs (id, nom, sexe)
                VALUES (%s, %s, %s)
                ON CONFLICT (id) DO NOTHING;
            """, (
                acteur["id"],
                acteur["name"],
                acteur.get("gender")
            ))

            cur.execute("""
                INSERT INTO films_acteurs (film_id, acteur_id, popularite)
                VALUES (%s, %s, %s)
                ON CONFLICT DO NOTHING;
            """, (
                details["id"],
                acteur["id"],
                acteur.get("popularity", 0)
            ))

        # Réalisateurs
        for personne in credits.get("crew", []):
            if personne.get("job") == "Director":
                cur.execute("""
                    INSERT INTO realisateurs (id, nom, sexe)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (id) DO NOTHING;
                """, (
                    personne["id"],
                    personne["name"],
                    personne.get("gender")
                ))

                cur.execute("""
                    INSERT INTO films_realisateurs (film_id, realisateur_id)
                    VALUES (%s, %s)
                    ON CONFLICT DO NOTHING;
                """, (details["id"], personne["id"]))

        # Producteurs (compagnies)
        for prod in details.get("production_companies", []):
            cur.execute("""
                INSERT INTO producteurs (id, nom_entreprise, pays_origine)
                VALUES (%s, %s, %s)
                ON CONFLICT (id) DO NOTHING;
            """, (
                prod["id"],
                prod["name"],
                prod.get("origin_country")
            ))

            cur.execute("""
                INSERT INTO films_producteurs (film_id, producteur_id)
                VALUES (%s, %s)
                ON CONFLICT DO NOTHING;
            """, (
                details["id"],
                prod["id"]
            ))

        conn.commit()

    print("Tous les films ont été insérés avec succès.")

except Exception as e:
    conn.rollback()
    print("Erreur :", e)

finally:
    cur.close()
    conn.close()