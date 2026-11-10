/***********************************************
** File:   Exercise - Neo4J Cypher Queries
** Desc:   Explore Movies dataset 
************************************************/

******************** FIND ********************

# Example queries for finding individual nodes.
# Click on any query example
# Run the query from the editor
# Notice the syntax pattern
# Try looking for other movies or actors

# Find the actor named "Tom Hanks"
MATCH (tom {name: "Tom Hanks"}) RETURN tom

# Find the movie with title "Cloud Atlas"...
MATCH (cloudAtlas {title: "Cloud Atlas"}) RETURN cloudAtlas

# Find 10 people
MATCH (people:Person) RETURN people.name LIMIT 10

# Find movies released in the 1990s...
MATCH (x:Movie) WHERE x.released > 1990 AND x.released < 2000 RETURN x.title


******************** QUERY ********************
# Finding patterns within the graph.
# Actors are people who acted in movies
# Directors are people who directed a movie
# What other relationships exist?

# List all Tom Hanks movies...
MATCH (tom:Person {name: "Tom Hanks"})-[:ACTED_IN]->(tomHanksMovies) RETURN tom,tomHanksMovies

# Who directed "Cloud Atlas"?
MATCH (cloudAtlas {title: "Cloud Atlas"})<-[:DIRECTED]-(directors) RETURN directors.name

# Tom Hanks' co-actors...
MATCH (tom:Person {name:"Tom Hanks"})-[:ACTED_IN]->(m)<-[:ACTED_IN]-(coActors) RETURN coActors.name

# How people are related to "Cloud Atlas"...
MATCH (people:Person)-[relatedTo]-(:Movie {title: "Cloud Atlas"}) RETURN people.name, Type(relatedTo), relatedTo

******************** SOLVE ********************
# You've heard of the classic "Six Degrees of Kevin Bacon"? That is simply a shortest path query called the "Bacon Path".
# Variable length patterns
# Built-in shortestPath() algorithm

# Movies and actors up to 4 "hops" away from Kevin Bacon
MATCH (bacon:Person {name:"Kevin Bacon"})-[*1..4]-(hollywood)
RETURN DISTINCT hollywood

# Bacon path, the shortest path of any relationships to Meg Ryan
MATCH p=shortestPath(
  (bacon:Person {name:"Kevin Bacon"})-[*]-(meg:Person {name:"Meg Ryan"})
)
RETURN p

***************** RECOMMENDATION ****************
# A basic recommendation approach is to find connections past an immediate neighborhood which are themselves well connected.
# For Tom Hanks, that means:
# Find actors that Tom Hanks hasn't yet worked with, but his co-actors have.
# Find someone who can introduce Tom to his potential co-actor.

# Extend Tom Hanks co-actors, to find co-co-actors who haven't work with Tom Hanks...
MATCH (tom:Person {name:"Tom Hanks"})-[:ACTED_IN]->(m)<-[:ACTED_IN]-(coActors),
      (coActors)-[:ACTED_IN]->(m2)<-[:ACTED_IN]-(cocoActors)
WHERE NOT (tom)-[:ACTED_IN]->(m2)
RETURN cocoActors.name AS Recommended, count(*) AS Strength ORDER BY Strength DESC

# Find someone to introduce Tom Hanks to Tom Cruise
MATCH (tom:Person {name:"Tom Hanks"})-[:ACTED_IN]->(m)<-[:ACTED_IN]-(coActors),
      (coActors)-[:ACTED_IN]->(m2)<-[:ACTED_IN]-(cruise:Person {name:"Tom Cruise"})
RETURN tom, m, coActors, m2, cruise

******************** CLEANUP ********************
# When done experimenting, you can remove the movie data set.
# Nodes can't be deleted if relationships exist
# Delete both nodes and relationships together

# Delete all Movie and Person nodes, and their relationships
MATCH (a:Person),(m:Movie) OPTIONAL MATCH (a)-[r1]-(), (m)-[r2]-() DELETE a,r1,m,r2
# Note you only need to compare property values like this when first creating relationships

# Prove that the Movie Graph is gone
MATCH (n) RETURN n

# END