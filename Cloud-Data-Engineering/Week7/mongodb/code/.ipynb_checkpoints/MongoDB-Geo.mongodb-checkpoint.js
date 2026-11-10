// MongoDB geospatial queries (run in mongosh)
// Reference: https://www.mongodb.com/docs/manual/tutorial/geospatial-tutorial/

// Setup (terminal, from the week7/mongodb folder): load both datasets into the "food" database
//   mongoimport --db food --collection neighborhoods --drop --file data/neighborhoods.json
//   mongoimport --db food --collection restaurants --drop --file data/restaurants.json

use("food")

// GeoJSON coordinates are ordered [longitude, latitude]
var pt = { type: "Point", coordinates: [ -73.93414657, 40.82302903 ] }

// Find the neighborhood that contains the point
var neighborhood = db.neighborhoods.findOne( { geometry: { $geoIntersects: { $geometry: pt } } } )
neighborhood.name

// Count the restaurants inside that neighborhood.
// Restaurant coordinates are stored in address.coord as [longitude, latitude] (127 with the course data).
db.restaurants.countDocuments( { "address.coord": { $geoWithin: { $geometry: neighborhood.geometry } } } )
