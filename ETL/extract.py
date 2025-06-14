import requests
import os
import json
from dotenv import load_dotenv
import time
import random


load_dotenv()


API_KEY = os.getenv("TMDB_API_KEY")
BASE_URL = "https://api.themoviedb.org/3"

def film_par_id(movie_id):
    url = f"{BASE_URL}/movie/{movie_id}"
    params = {
        "api_key": API_KEY,
        "language": "fr-FR"
    }
    reponse = requests.get(url, params=params)
    
    if reponse.status_code == 200:
        return reponse.json()
    else:
        print(f"Erreur {reponse.status_code} : {reponse.text}")
        return None


def credits_par_id(movie_id):
    url = f"{BASE_URL}/movie/{movie_id}/credits"
    params = {
        "api_key": API_KEY,
        "language": "fr-FR"
    }
    reponse = requests.get(url, params=params)

    if reponse.status_code == 200:
        return reponse.json()
    else:
        print(f"Erreur pour {movie_id} : {reponse.status_code}")
        return None

















def collecter_films(nb_max=30000, sauvegarde_tous_les=500):
    films_collectes = []
    ids_deja_vus = set()
    total = 0

    for annee in range(1980, 2024):
        for page in range(1, 30):

            if total >= nb_max:
                return films_collectes

            url = f"{BASE_URL}/discover/movie"
            params = {
                "api_key": API_KEY,
                "language": "fr-FR",
                "region": "US",
                "with_origin_country": "US",
                "sort_by": "popularity.desc",
                "page": page,
                "primary_release_year": annee
            }

            try:
                reponse = requests.get(url, params=params, timeout=10)
                reponse.raise_for_status()
            except Exception as e:
                print(f"Erreur requête année {annee} page {page} : {e}")
                continue

            films_page = reponse.json().get("results", [])

            for film in films_page:
                film_id = film["id"]
                if film_id not in ids_deja_vus:
                    try:
                        details = film_par_id(film_id)
                        credits = credits_par_id(film_id)
                    except Exception as e:
                        print(f"Erreur film ID {film_id} : {e}")
                        continue

                    if details and credits:
                        films_collectes.append({
                            "film": details,
                            "credits": {
                                "cast": sorted(
                                    credits.get("cast", []),
                                    key=lambda x: x.get("popularity", 0),
                                    reverse=True
                                )[:5],
                                "realisateurs": [
                                    p for p in credits.get("crew", [])
                                    if p.get("job") == "Director"
                                ]
                            }
                        })
                        ids_deja_vus.add(film_id)
                        total += 1

                        #auvegarde intermédiaire
                        if total % sauvegarde_tous_les == 0:
                            with open("test/films_us_backup.json", "w", encoding="utf-8") as f:
                                json.dump(films_collectes, f, ensure_ascii=False, indent=4)
                            print(f"Sauvegarde à {total} films")

                    time.sleep(0.25)

    return films_collectes


if __name__ == "__main__":
    films = collecter_films(nb_max=26400)
    print(f"{len(films)} films collectés.")

    with open("test/films_us.json", "w", encoding="utf-8") as f:
        json.dump(films, f, ensure_ascii=False, indent=4)
