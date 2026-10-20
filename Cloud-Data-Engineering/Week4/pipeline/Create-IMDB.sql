/***********************************************
** Name:        IMDB Sample Database
** Description: Schema and seed data for an IMDB-style database covering movies, actors, and ratings
** Author:      Ashish Pujari
************************************************/

-- Create the database
CREATE DATABASE IF NOT EXISTS imdb_data;

-- Use the created database
USE imdb_data;

-- Create the movies table
CREATE TABLE IF NOT EXISTS movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    year INT NOT NULL,
    imdb_rating FLOAT,
    votes INT,
    UNIQUE (name, year)  -- Ensure no duplicate entries for the same movie and year
);

-- Optionally, you can add some indexes to improve performance
CREATE INDEX idx_year ON movies(year);
CREATE INDEX idx_rating ON movies(imdb_rating);
