# Projet Analyse de données TMDb

Ce projet personnel vise à analyser les données du cinéma (pour l'instant uniquement US, pour faciliter), sur une période de presque 50 ans, en utilisant l'API TMDb (The movie database). Le projet combine pipeline de collecte et de traitement des données en python, puis l'insertion dans une base de données PostgreSQL, en respectant le plus possibles les codes des bases de données (relations entre les tables, avec des tables de dimension et de fait). Le projet est structuré en deux grandes partie : 
- Une partie base de données & SQL (présentation dans ce repo)
- Une seconde partie orientée analyse des données via POWER BI (disponible séparémment)

---

## Objectifs

- Collecter automatiquement les données des films via l'API TMDb. [Collecte des données](./ETL/extract.py)
- Construire une base de données relationnelle propre et normalisée. [Le schéma de la base](./DB/schema.sql)
- Charger les données récoltées dans la base de données PostgreSQL. [Chargement des données](./ETL/load.py)
- Réaliser des requêtes SQL de difficulté croissantes. [Les requêtes](./DB/requetes.sql)
- Réaliser une analyse des données (voir partie 2, autre repo).

---

## Structure du projet

```bash
PROJET_TMDB/
├── DB/                 # Schéma et requêtes SQL + résultats (en screenshot)
├── ETL/                # Scripts d'extraction et de chargement, pas besoin de transformation
├── test/               # Fichiers JSON de test pour visualiser la structure des données brutes (avant chargement)
├── README.md           # Présentation
├── requirements.txt    # Dépendances Python
└── .env                # Variables d'environnement 
```

--- 

## Outils utilisés 

- **Python**
  - `requests` : extraction API
  - `psycopg2` : insertion PostgreSQL
- **PostgreSQL**
  - Modélisation relationnelle & Requêtes SQL 
  - Utilisation de pgAdmin et `psql`
- **TMDb API**
  - Films, cast, crew, compagnies de production
- **SQL**
  - Requêtes logiques, jointures, agrégations (voir dossier DB)
- **Git & GitHub**
  - Commit & Push vers GitHub avec Git
- **VS Code**
  - IDE utilisé pour le projet

---

## Information sur la base de données

- Contient environ 25000 films
- Contient des informations sur chaque film, et le casting de chaque film
- Couvre une période de 1980 à 2024
- Contient uniquement des films US 