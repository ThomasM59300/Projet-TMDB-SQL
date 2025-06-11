import requests
import os
import json
from dotenv import load_dotenv


load_dotenv()

#test sur un fight club

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


#pour tester si ça marche
if __name__ == "__main__":
    movie = film_par_id(575264) 
    #id de l'avant dernier mission impossible
    if movie:
        print(f"Titre : {movie['title']}")
        print(f"Date de sortie : {movie['release_date']}")
        print(f"Genres : {[g['name'] for g in movie['genres']]}")
        print(f"Budget : {movie['budget']}")
        print(f"Recette : {movie['revenue']}")


#on le met dans testdonnee.json pour avoir une idée de la structure
with open("test/testdonnee.json", "w", encoding="utf-8") as f:
    json.dump(movie, f, ensure_ascii=False, indent=4)