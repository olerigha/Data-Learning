// MongoDB Countries Quiz (run in mongosh)

// Setup (terminal, from the week7/mongodb folder). countries.json is a JSON array, so --jsonArray is required.
//   mongoimport --db world --collection countries --drop --file data/countries.json --jsonArray

use("world")
db.countries.find()

// Find all countries in the Northern Africa subregion (expected: 7)
db.countries.countDocuments( { subregion: "Northern Africa" } )

// Find all countries where the population is greater than 50 million and the Gini index is less than 30
// (expected: Ethiopia and Germany). A comma between conditions is an implicit AND.
db.countries.find( { population: { $gt: 50000000 }, gini: { $lt: 30 } } )

// Count all countries whose names start with the letter S (expected: 33)
db.countries.countDocuments( { name: /^S/ } )
