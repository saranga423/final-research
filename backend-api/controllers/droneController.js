// backend-api/controllers/droneController.js
const Drone = require('../models/Drone');
// Get drone status
exports.getDroneStatus = async (req, res) => {
  try {
    const drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    res.json({ status: drone.status });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  } 
};



// Update drone status
exports.updateDroneStatus = async (req, res) => {
  try {
    const { status } = req.body;
    let drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    drone.status = status;
    await drone.save();
    res.json({ status: drone.status });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Register new drone
exports.registerDrone = async (req, res) => {
  try {
    const { name, status } = req.body;  
    let drone = new Drone({ name, status });
    await drone.save();
    res.status(201).json(drone);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get all drones
exports.getAllDrones = async (req, res) => {
  try {
    const drones = await Drone.find();
    res.json(drones);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Delete a drone
exports.deleteDrone = async (req, res) => {
  try { 
    const drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    await drone.remove();
    res.json({ message: 'Drone removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Update drone details
exports.updateDroneDetails = async (req, res) => {
  try {
    const { name, status } = req.body;
    let drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    drone.name = name || drone.name;
    drone.status = status || drone.status;
    await drone.save();
    res.json(drone);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get drone by ID
exports.getDroneById = async (req, res) => {
  try {
    const drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    res.json(drone);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Search drones by name
exports.searchDronesByName = async (req, res) => {
  try {
    const { name } = req.query;
    const drones = await Drone.find({ name: new RegExp(name, 'i') });
    res.json(drones);
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get drone statistics
exports.getDroneStatistics = async (req, res) => {
  try {
    const totalDrones = await Drone.countDocuments();
    const activeDrones = await Drone.countDocuments({ status: 'active' });
    const inactiveDrones = await Drone.countDocuments({ status: 'inactive' });
    res.json({ totalDrones, activeDrones, inactiveDrones });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Reset drone status
exports.resetDroneStatus = async (req, res) => {
  try {
    let drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    drone.status = 'inactive';
    await drone.save();
    res.json({ status: drone.status });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Bulk update drone statuses
exports.bulkUpdateDroneStatuses = async (req, res) => {
  try {
    const { droneIds, status } = req.body;
    const result = await Drone.updateMany(
      { _id: { $in: droneIds } },
      { $set: { status } }
    );
    res.json({ modifiedCount: result.nModified });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get drones by status
exports.getDronesByStatus = async (req, res) => {
  try { 
    const { status } = req.params;
    const drones = await Drone.find({ status });
    res.json(drones);
  } 
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Toggle drone status
exports.toggleDroneStatus = async (req, res) => {
  try {
    let drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    drone.status = (drone.status === 'active') ? 'inactive' : 'active';
    await drone.save();
    res.json(drone);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
// Get drones with pagination
exports.getDronesWithPagination = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;
    const drones = await Drone.find().skip(skip).limit(limit);
    const total = await Drone.countDocuments();
    res.json({ drones, total, page, pages: Math.ceil(total / limit) });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Get drone activity log
exports.getDroneActivityLog = async (req, res) => {
  try {
    const drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    res.json({ activityLog: drone.activityLog || [] });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  } 
};
// Add entry to drone activity log
exports.addDroneActivityLogEntry = async (req, res) => {
  try {
    const { entry } = req.body;
    let drone = await Drone.findById(req.params.id);
    if (!drone) return res.status(404).json({ message: 'Drone not found' });
    drone.activityLog = drone.activityLog || [];
    drone.activityLog.push({ entry, timestamp: new Date() });
    await drone.save();
    res.json({ activityLog: drone.activityLog });
  }
  catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};