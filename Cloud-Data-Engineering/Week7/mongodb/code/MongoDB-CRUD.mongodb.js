/***********************************************
** Description:   Mongo DB CRUD operations
**
** VS Code (MongoDB extension): open the file, then Run All, or select lines and Run Selected.
** Terminal: mongosh --quiet < MongoDB-CRUD.mongodb.js   (prints every result;
** "mongosh --file" also works but only shows output written with print())
************************************************/

/* Show Databases */
db.adminCommand( { listDatabases: 1 } )

/* Show Default Database*/
db.getName()

/* Select Database */
use("store")

/* Start clean so the script can be re-run (drop() is harmless if the collection does not exist) */
db.inventory.drop()

/* CREATING A COLLECTION
 * If the collection does not currently exist, insert operations will create the collection.
 */
/*********** INSERT DOCUMENTS ( CREATE ) ***********/
db.inventory.insertOne(
   { item: "canvas", qty: 100, tags: ["cotton"], size: { h: 28, w: 35.5, uom: "cm" } }
)

/* Query the Collection */
db.inventory.find( { item: "canvas" } )

/* Insert Many Documents */
db.inventory.insertMany([
   { item: "journal", qty: 25, tags: ["blank", "red"], size: { h: 14, w: 21, uom: "cm" } },
   { item: "mat", qty: 85, tags: ["gray"], size: { h: 27.9, w: 35.5, uom: "cm" } },
   { item: "mousepad", qty: 25, tags: ["gel", "blue"], size: { h: 19, w: 22.85, uom: "cm" } }
])

/* Query the inventory collection
 * similar to SELECT * FROM inventory
 */
db.inventory.find( {} )

/* Insert Additional Data */
db.inventory.insertMany([
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
]);

/* duplicates added to item journal */
db.inventory.find( { item: "journal" } )

/*********** QUERY DOCUMENTS ( READ ) ***********/
/* Query the inventory collection*/
db.inventory.find( {} )

/* Query Inventory Collection to filter on certain documents.
 * SELECT * FROM inventory WHERE status = "D"
 */
db.inventory.find( { status: "D" } )

/* Query Inventory Collection based on multiple filters
 * SELECT * FROM inventory WHERE status in ("A", "D")
 */
db.inventory.find( { status: { $in: [ "A", "D" ] } } )

/* Retrieve all documents in the inventory collection where the status equals "A" AND qty is less than ($lt) 30
 * SELECT * FROM inventory WHERE status = "A" AND qty < 30
 */
db.inventory.find( { status: "A", qty: { $lt: 30 } } )

/* retrieve all documents in the collection where the status equals "A" OR qty is less than ($lt) 30:
 * SELECT * FROM inventory WHERE status = "A" OR qty < 30
 */
db.inventory.find( { $or: [ { status: "A" }, { qty: { $lt: 30 } } ] } )

/* compound query that selects all documents in the collection where the status equals "A" and
 * either qty is less than ($lt) 30 or item starts with the character p
 * SELECT * FROM inventory WHERE status = "A" AND ( qty < 30 OR item LIKE "p%")
 */
db.inventory.find( {
     status: "A",
     $or: [ { qty: { $lt: 30 } }, { item: /^p/ } ]
} )

/* Match an Embedded/Nested Document  */
/* Select all documents where the field size equals the document { h: 14, w: 21, uom: "cm" } */
db.inventory.find( { size: { h: 14, w: 21, uom: "cm" } } )

/* Note: Equality matches on the whole embedded document require an exact match of the specified <value>
 * Below query does not return any records since keys h & w have been swapped
 */
db.inventory.find(  { size: { w: 21, h: 14, uom: "cm" } }  )

/* select all documents where the field uom nested in the size field equals "in" */
db.inventory.find( { "size.uom": "in" } )

/* selects all documents where the nested field h is less than 15, the nested field
 * uom equals "in", and the status field equals "D":
 */
db.inventory.find( { "size.h": { $lt: 15 }, "size.uom": "in", status: "D" } )

/* Query an array : Insert data */
db.inventory.insertMany([
   { item: "journal", qty: 25, tags: ["blank", "red"], dim_cm: [ 14, 21 ] },
   { item: "notebook", qty: 50, tags: ["red", "blank"], dim_cm: [ 14, 21 ] },
   { item: "paper", qty: 100, tags: ["red", "blank", "plain"], dim_cm: [ 14, 21 ] },
   { item: "planner", qty: 75, tags: ["blank", "red"], dim_cm: [ 22.85, 30 ] },
   { item: "postcard", qty: 45, tags: ["blue"], dim_cm: [ 10, 15.25 ] }
]);

/* Query the collection for all documents where the field tags value is an array with exactly two elements,
 * "red" and "blank", in the SPECIFIED ORDER
 */
db.inventory.find( { tags: ["red", "blank"] } )

/* Same query as above but without regards to ORDER ($all) */
db.inventory.find( { tags: { $all: ["red", "blank"] } } )

/* Query all documents where tags is an array that contains the string "red" as one of its elements */
db.inventory.find( { tags: "red" } )

/* Queries all documents where the array dim_cm contains at least one element whose value is greater than 25. */
db.inventory.find( { dim_cm: { $gt: 25 } } )

/* Query an Array with Compound Filter Conditions on the Array Elements
 * The following example queries for documents where the dim_cm array contains elements that in some
 * combination satisfy the query conditions; e.g., one element can satisfy the greater than 15 condition and
 * another element can satisfy the less than 20 condition, or a single element can satisfy both
 */
db.inventory.find( { dim_cm: { $gt: 15, $lt: 20 } } )

/* Query for an Array Element that Meets Multiple Criteria $elemMatch operator */
/* queries for documents where the dim_cm array contains at least one element that is both greater than
 * ($gt) 22 and less than ($lt) 30
 */
db.inventory.find( { dim_cm: { $elemMatch: { $gt: 22, $lt: 30 } } } )

/* Query for an Element by the Array Index Position */
/* Queries all documents where the second element ( dot notation ) in the array dim_cm is greater than 25 */
db.inventory.find( { "dim_cm.1": { $gt: 25 } } )

/* Query an Array by Array Length  */
db.inventory.find( { "tags": { $size: 3 } } )

/* Query for Null or Missing Fields */
/* Insert documents */
db.inventory.insertMany([
   { _id: 1, item: null },
   { _id: 2 }
])

/* Query the inventory collection*/
db.inventory.find( {} )

/* Equality Filter : matches documents where item is null OR the field is missing (_id 1 and 2) */
db.inventory.find( { item: null } )

/* Type Check : matches only documents where item is explicitly null (_id 1) */
db.inventory.find( { item: { $type: "null" } } )

/* Existence Check : matches only documents where the field is missing (_id 2) */
db.inventory.find( { item : { $exists: false } } )

/*********** UPDATE DOCUMENTS ( UPDATE ) ***********/
/* update single document (paper)
 * update the value of the size.uom field to "cm" and the value of the status field to "P",
 * update the value of the lastModified field to the current date.
 * If lastModified field does not exist, $currentDate will create the field.
 */
/* Check parameters before update */
db.inventory.find( { item: "paper" } )

/* update */
db.inventory.updateOne(
   { item: "paper" },
   {
     $set: { "size.uom": "cm", status: "P" },
     $currentDate: { lastModified: true }
   }
)

/* Validate */
db.inventory.find( { item: "paper" } )

/* update ALL documents where qty is less than 50 */
/* Check parameters before update */
db.inventory.find({})

/* update all */
db.inventory.updateMany(
   { "qty": { $lt: 50 } },
   {
     $set: { "size.uom": "in", status: "P" },
     $currentDate: { lastModified: true }
   }
)

/* Validate */
db.inventory.find({})

/* Replaces the first document from the inventory collection that matches the filter item equals "paper": */
db.inventory.replaceOne(
   { item: "paper" },
   { item: "paper", instock: [ { warehouse: "A", qty: 60 }, { warehouse: "B", qty: 40 } ] }
)

/* Validate */
db.inventory.find( { item: "paper" } )

/*********** INDEXES ***********/
/* Compound index : supports filters on status alone, or on status and qty together */
db.inventory.createIndex( { status: 1, qty: 1 } )

/* Multikey index : indexing an array field (tags) automatically indexes every element */
db.inventory.createIndex( { tags: 1 } )

/* List the indexes on the collection */
db.inventory.getIndexes()

/* Confirm the compound index is used : the winning plan should contain an IXSCAN stage, not COLLSCAN */
db.inventory.find( { status: "A", qty: { $lt: 30 } } ).explain( "executionStats" )

/*********** DELETE DOCUMENTS ( DELETE ) ***********/
/* remove all documents from the inventory collection where the status field equals "A" */
db.inventory.deleteMany({ status : "A" })

/* Deletes the first document where status is "D" */
db.inventory.deleteOne( { status: "D" } )

/* Delete all documents (the empty collection and its indexes remain) */
db.inventory.deleteMany({})

/* Drop the collection and its indexes */
db.inventory.drop()

/*********** SCHEMA VALIDATION ( JSON SCHEMA ) ***********/
/* A validator rejects documents that do not match the schema */
db.createCollection( "customers", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: [ "name", "email" ],
         properties: {
            name: { bsonType: "string" },
            email: { bsonType: "string", pattern: "^.+@.+$" }
         }
      }
   }
} )

/* Valid document : accepted */
db.customers.insertOne( { _id: 1, name: "Ana", email: "ana@example.com" } )
db.customers.insertOne( { _id: 2, name: "Raj", email: "raj@example.com" } )

/* Invalid document (email missing) : rejected with "Document failed validation".
 * try/catch lets Run All continue past the expected error. */
try {
   db.customers.insertOne( { _id: 3, name: "Lee" } )
} catch ( e ) {
   print( "Rejected: " + e.message )
}

/*********** REFERENCING DOCUMENTS ( $lookup ) ***********/
/* Embedding keeps related data in one document; referencing stores an id and joins at query time */
db.orders.insertMany([
   { _id: 101, customerId: 1, total: 40 },
   { _id: 102, customerId: 2, total: 15 },
   { _id: 103, customerId: 1, total: 25 }
])

/* Join each order to its customer, similar to a SQL LEFT JOIN */
db.orders.aggregate([
   { $lookup: { from: "customers", localField: "customerId", foreignField: "_id", as: "customer" } }
])

/* Clean up */
db.customers.drop()
db.orders.drop()