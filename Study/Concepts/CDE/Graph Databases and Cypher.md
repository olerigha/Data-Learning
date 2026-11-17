---
course: CDE
week: 7
source: "[[Week7-NoSQL.pdf]], [[Cloud-Data-Engineering/Week7/README|Week 7 README]]"
status: new
tags: [generated]
---
# Graph Databases and Cypher
**In one line:** Store data as nodes (things) and relationships (connections), each with properties, and query by describing the pattern of connections you want.

**In plain words:** When the connections *are* the data (who follows whom, which accounts share an address, which actors worked with which directors), relational joins get slow and awkward. A graph database (Neo4j) stores relationships as first-class objects, so following them is fast even many hops deep. Its query language, Cypher, looks like little ASCII drawings: `(a)-[:FOLLOWS]->(b)`.

**Terms**
| Term | Means |
|---|---|
| Node | an entity, with a label (`:Person`) and properties (`name`) |
| Relationship / edge | a typed, directed connection (`[:ACTED_IN]`), can have properties |
| Property graph | nodes + relationships + properties |
| Directed / undirected | edges with / without a direction |
| Cypher | Neo4j's declarative query language |
| `MATCH` / `WHERE` / `RETURN` | find a pattern / filter / output |
| `CREATE` / `MERGE` | add data / add only if it doesn't already exist |
| Variable-length path | `(a)-[*3..5]->(b)`: 3 to 5 hops |

**Key points**
```cypher
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.released > 1990
RETURN p.name, m.title
```
In words: find people who acted in movies released after 1990, and list name and title.
- Patterns: friend-of-a-friend, common friends, `shortestPath(...)`, collaborative filtering.
- Algorithms: BFS (nearest first), DFS (deep first), Dijkstra / A* (weighted shortest path), PageRank (importance), community detection, minimum spanning tree, random walk.
- Use cases: fraud rings, recommendations, knowledge graphs, IT dependencies, access hierarchies. Example: the Panama Papers (275K nodes, 400K relationships).
- Labs: Movies graph (DDL/DML Cypher), Friends `FOLLOWS` graph with py2neo and NetworkX.

**Memorize vs. look up:** Memorize node vs relationship, the `MATCH … RETURN` shape, and when a graph beats relational.

Related: [[NoSQL and the CAP Theorem]], [[Polyglot Persistence]], [[Entities, Relationships and Cardinality]]
