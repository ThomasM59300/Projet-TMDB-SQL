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

















def collecter_films(nb_max=10000):
    films_collectes = []
    ids_deja_vus = set()

    page = 1
    total = 0

    while total < nb_max and page <= 500:

        url = f"{BASE_URL}/discover/movie"
        params = {
            "api_key": API_KEY,
            "language": "fr-FR",
            "region": "US",
            "with_origin_country": "US",
            "sort_by": "popularity.desc",
            "page": page,
            "primary_release_year": random.randint(1980, 2023)
        }

        reponse = requests.get(url, params=params)

        if reponse.status_code == 200:
            films_page = reponse.json().get("results", [])

            for film in films_page:
                film_id = film["id"]
                if film_id not in ids_deja_vus:
                    details = film_par_id(film_id)
                    credits = credits_par_id(film_id)

                    if details and credits:
                        films_collectes.append({
                            "film": details,
                            "credits": {
                                "cast": sorted(credits.get("cast", []), key=lambda x: x.get("popularity", 0), reverse=True)[:5],
                                "realisateurs": [p for p in credits.get("crew", []) if p.get("job") == "Director"]
                            }

                        })
                        ids_deja_vus.add(film_id)
                        total += 1

                    time.sleep(0.25) 

        else:
            print(f"Erreur page {page}")

        page += 1

    return films_collectes



if __name__ == "__main__":
    films = collecter_films(nb_max=2000)
    print(f"{len(films)} films collectés.")

    with open("test/films_us.json", "w", encoding="utf-8") as f:
        json.dump(films, f, ensure_ascii=False, indent=4)