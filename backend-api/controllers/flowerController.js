// backend-api/controllers/flowerController.js
const Flower = require('../models/Flower');

// Get all flowers
exports.getAllFlowers = async (req, res) => {
  try {
    const flowers = await Flower.find();
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flower by ID
exports.getFlowerById = async (req, res) => {
  try {
    const flower = await Flower.findById(req.params.id);
    if (!flower) return res.status(404).json({ message: 'Flower not found' });
    res.json(flower);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  } 
};
// Create a new flower
exports.createFlower = async (req, res) => {
  try { 
    const { name, color, species } = req.body;
    const newFlower = new Flower({ name, color, species });
    const flower = await newFlower.save();
    res.status(201).json(flower);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Update flower by ID
exports.updateFlower = async (req, res) => {
  try {
    const { name, color, species } = req.body;
    let flower = await Flower.findById(req.params.id);
    if (!flower) return res.status(404).json({ message: 'Flower not found' });
    flower.name = name || flower.name;
    flower.color = color || flower.color;
    flower.species = species || flower.species;
    await flower.save();
    res.json(flower);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Delete flower by ID
exports.deleteFlower = async (req, res) => {
  try {
    let flower = await Flower.findById(req.params.id);
    if (!flower) return res.status(404).json({ message: 'Flower not found' });
    await Flower.findByIdAndRemove(req.params.id);
    res.json({ message: 'Flower removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Search flowers by name
exports.searchFlowersByName = async (req, res) => {
  try { 
    const { name } = req.query;
    const flowers = await Flower.find({ name: new RegExp(name, 'i') });
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Filter flowers by color
exports.filterFlowersByColor = async (req, res) => {
  try {
    const { color } = req.query;
    const flowers = await Flower.find({ color: new RegExp(color, 'i') });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Sort flowers by species
exports.sortFlowersBySpecies = async (req, res) => {
  try { 
    const flowers = await Flower.find().sort({ species: 1 });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flower statistics
exports.getFlowerStatistics = async (req, res) => {
  try {
    const totalFlowers = await Flower.countDocuments();
    const speciesStats = await Flower.aggregate([
      { $group: { _id: '$species', count: { $sum: 1 } } }
    ]);
    res.json({ totalFlowers, speciesStats });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Upload flower image
exports.uploadFlowerImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
    const flower = await Flower.findById(req.params.id);
    if (!flower) return res.status(404).json({ message: 'Flower not found' });
    flower.imageUrl = `/uploads/${req.file.filename}`;
    await flower.save();
    res.json({ imageUrl: flower.imageUrl });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flower image
exports.getFlowerImage = async (req, res) => {
  try {
    const flower = await Flower.findById(req.params.id);
    if (!flower || !flower.imageUrl) return res.status(404).json({ message: 'Image not found' });
    res.sendFile(path.join(__dirname, '..', flower.imageUrl));
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Rate a flower
exports.rateFlower = async (req, res) => {
  try {
    const { rating } = req.body;
    let flower = await Flower.findById(req.params.id);
    if (!flower) return res.status(404).json({ message: 'Flower not found' });
    flower.ratings.push(rating);
    flower.averageRating = flower.ratings.reduce((a, b) => a + b, 0) / flower.ratings.length;
    await flower.save();
    res.json({ averageRating: flower.averageRating });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get top-rated flowers
exports.getTopRatedFlowers = async (req, res) => {
  try {
    const flowers = await Flower.find().sort({ averageRating: -1 }).limit(10);
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
const path = require('path');
const multer = require('multer');
// Set up multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => { 
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});
exports.upload = multer({ storage }); 

// Get flowers with pagination
exports.getFlowersWithPagination = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    const flowers = await Flower.find().skip(skip).limit(limit);
    const total = await Flower.countDocuments();
    res.json({ flowers, total, page, pages: Math.ceil(total / limit) });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers by species
exports.getFlowersBySpecies = async (req, res) => {
  try {
    const { species } = req.params;
    const flowers = await Flower.find({ species: new RegExp(species, 'i') });
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Update flower ratings
exports.updateFlowerRatings = async (req, res) => {
  try {
    const { ratings } = req.body;
    let flower = await Flower.findById(req.params.id);
    if (!flower) return res.status(404).json({ message: 'Flower not found' });
    flower.ratings = ratings;
    flower.averageRating = ratings.reduce((a, b) => a + b, 0) / ratings.length;
    await flower.save();
    res.json({ averageRating: flower.averageRating });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers with average rating above a threshold
exports.getFlowersByRatingThreshold = async (req, res) => {
  try {
    const threshold = parseFloat(req.query.threshold) || 0;
    const flowers = await Flower.find({ averageRating: { $gte: threshold } });
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flower species list
exports.getFlowerSpeciesList = async (req, res) => {
  try {
    const speciesList = await Flower.distinct('species');
    res.json(speciesList);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers added in the last N days
exports.getRecentFlowers = async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 7;
    const dateThreshold = new Date();
    dateThreshold.setDate(dateThreshold.getDate() - days);
    const flowers = await Flower.find({ createdAt: { $gte: dateThreshold } });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers with no ratings
exports.getUnratedFlowers = async (req, res) => {
  try {
    const flowers = await Flower.find({ ratings: { $size: 0 } });
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  } 
};

// Get flowers by color and species
exports.getFlowersByColorAndSpecies = async (req, res) => {
  try {
    const { color, species } = req.query;
    const flowers = await Flower.find({
      color: new RegExp(color, 'i'),
      species: new RegExp(species, 'i')
    });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flower count by color
exports.getFlowerCountByColor = async (req, res) => {
  try {
    const colorStats = await Flower.aggregate([
      { $group: { _id: '$color', count: { $sum: 1 } } }
    ]);
    res.json(colorStats);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  } 
};
// Get flowers with specific rating
exports.getFlowersBySpecificRating = async (req, res) => {
  try {
    const rating = parseFloat(req.query.rating);
    const flowers = await Flower.find({ ratings: rating });
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers sorted by name
exports.getFlowersSortedByName = async (req, res) => {
  try { 
    const flowers = await Flower.find().sort({ name: 1 });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  } 
};

// Get flowers with average rating within a range
exports.getFlowersByRatingRange = async (req, res) => {
  try {
    const min = parseFloat(req.query.min) || 0;
    const max = parseFloat(req.query.max) || 5;
    const flowers = await Flower.find({ averageRating: { $gte: min, $lte: max } });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers by name and color
exports.getFlowersByNameAndColor = async (req, res) => {
  try {
    const { name, color } = req.query;
    const flowers = await Flower.find({
      name: new RegExp(name, 'i'),
      color: new RegExp(color, 'i')
    });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Get flowers added between two dates
exports.getFlowersByDateRange = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const flowers = await Flower.find({
      createdAt: {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      }
    });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Get flowers with pagination and sorting
exports.getFlowersWithPaginationAndSorting = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const sortBy = req.query.sortBy || 'name';
    const sortOrder = req.query.sortOrder === 'desc' ? -1 : 1;
    const skip = (page - 1) * limit;
    const flowers = await Flower.find()
      .sort({ [sortBy]: sortOrder })
      .skip(skip)
      .limit(limit);
    const total = await Flower.countDocuments();
    res.json({ flowers, total, page, pages: Math.ceil(total / limit) });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers by multiple species
exports.getFlowersByMultipleSpecies = async (req, res) => {
  try {
    const speciesArray = req.query.species.split(',');
    const flowers = await Flower.find({ species: { $in: speciesArray } });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Get flowers with images
exports.getFlowersWithImages = async (req, res) => {
  try {
    const flowers = await Flower.find({ imageUrl: { $exists: true, $ne: '' } });
    res.json(flowers);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Get flowers without images
exports.getFlowersWithoutImages = async (req, res) => {
  try {
    const flowers = await Flower.find({ $or: [ { imageUrl: { $exists: false } }, { imageUrl: '' } ] });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get average rating of all flowers
exports.getAverageRatingOfAllFlowers = async (req, res) => {
  try { 
    const result = await Flower.aggregate([
      { $unwind: '$ratings' },
      { $group: { _id: null, avgRating: { $avg: '$ratings' } } }
    ]);
    const avgRating = result[0] ? result[0].avgRating : 0;
    res.json({ averageRating: avgRating });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Get flowers by name, color, and species
exports.getFlowersByNameColorAndSpecies = async (req, res) => {
  try {
    const { name, color, species } = req.query;
    const flowers = await Flower.find({
      name: new RegExp(name, 'i'),
      color: new RegExp(color, 'i'),
      species: new RegExp(species, 'i')
    });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers with ratings above average
exports.getFlowersAboveAverageRating = async (req, res) => {
  try {
    const result = await Flower.aggregate([
      { $unwind: '$ratings' },
      { $group: { _id: null, avgRating: { $avg: '$ratings' } } }
    ]);
    const avgRating = result[0] ? result[0].avgRating : 0;
    const flowers = await Flower.find({ averageRating: { $gt: avgRating } });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers with ratings below average
exports.getFlowersBelowAverageRating = async (req, res) => {
  try {
    const result = await Flower.aggregate([
      { $unwind: '$ratings' },
      { $group: { _id: null, avgRating: { $avg: '$ratings' } } }
    ]);
    const avgRating = result[0] ? result[0].avgRating : 0;
    const flowers = await Flower.find({ averageRating: { $lt: avgRating } });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get flowers with specific color and minimum rating
exports.getFlowersByColorAndMinRating = async (req, res) => {
  try {
    const { color, minRating } = req.query;
    const flowers = await Flower.find({
      color: new RegExp(color, 'i'),
      averageRating: { $gte: parseFloat(minRating) }
    });
    res.json(flowers);
  } 
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Get flowers with specific species and maximum rating
exports.getFlowersBySpeciesAndMaxRating = async (req, res) => {
  try {
    const { species, maxRating } = req.query;
    const flowers = await Flower.find({
      species: new RegExp(species, 'i'),
      averageRating: { $lte: parseFloat(maxRating) }
    });
    res.json(flowers);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
