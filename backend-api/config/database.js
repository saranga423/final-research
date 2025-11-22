const { MongoClient } = require("mongodb");
const config = require("./config.json");

let db;

async function connectDB() {
  if (db) return db;

  const client = new MongoClient(config.database.uri, { useUnifiedTopology: true });
  await client.connect();
  db = client.db();
  console.log("Connected to database:", config.database.uri);
  return db;
}

module.exports = { connectDB };
