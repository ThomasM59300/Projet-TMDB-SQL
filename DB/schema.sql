-- Table principale : films
CREATE TABLE films (
    id BIGINT PRIMARY KEY,
    titre TEXT,
    date_sortie DATE,
    budget FLOAT,
    revenu FLOAT,
    duree INT,
    note_moyenne FLOAT,
    nb_votes INT
);

-- Table genres
CREATE TABLE genres (
    id INT PRIMARY KEY,
    genre TEXT
);

-- Liaison films & genres via films_genres
CREATE TABLE films_genres (
    film_id BIGINT,
    genre_id INT,
    PRIMARY KEY (film_id, genre_id),
    FOREIGN KEY (film_id) REFERENCES films(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);


-- Table acteurs
CREATE TABLE acteurs (
    id BIGINT PRIMARY KEY,
    nom TEXT,
    sexe INT --int car gender = 1 ou 2, voir les json
);

-- Liaison films & acteurs via films_acteurs
CREATE TABLE films_acteurs (
    film_id BIGINT,
    acteur_id BIGINT,
    popularite FLOAT,
    PRIMARY KEY (film_id, acteur_id),
    FOREIGN KEY (film_id) REFERENCES films(id),
    FOREIGN KEY (acteur_id) REFERENCES acteurs(id)
);


-- Table réalisateurs
CREATE TABLE realisateurs (
    id BIGINT PRIMARY KEY,
    nom TEXT,
    sexe INT
);

-- Liaison films & réalisateurs via films_realisateurs
CREATE TABLE films_realisateurs (
    film_id BIGINT,
    realisateur_id BIGINT,
    PRIMARY KEY (film_id, realisateur_id),
    FOREIGN KEY (film_id) REFERENCES films(id),
    FOREIGN KEY (realisateur_id) REFERENCES realisateurs(id)
);


-- Table producteurs
CREATE TABLE producteurs (
    id BIGINT PRIMARY KEY,
    nom_entreprise TEXT,
    pays_origine TEXT
);

-- Liaison films & producteurs via films_producteurs
CREATE TABLE films_producteurs (
    film_id BIGINT,
    producteur_id BIGINT,
    PRIMARY KEY (film_id, producteur_id),
    FOREIGN KEY (film_id) REFERENCES films(id),
    FOREIGN KEY (producteur_id) REFERENCES producteurs(id)
);