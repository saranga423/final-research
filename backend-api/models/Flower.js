//backend-api/models/flower.js
const mongoose = require('mongoose');
const FlowerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  color: { type: String, required: true },
  species: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});
module.exports = mongoose.model('Flower', FlowerSchema);