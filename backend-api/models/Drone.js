const mongoose = require('mongoose');

const DroneSchema = new mongoose.Schema({
  name: { type: String, required: true },
  status: { 
    type: String, 
    enum: ['idle', 'in-flight', 'charging', 'maintenance'], 
    default: 'idle' 
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Drone', DroneSchema);
    await drone.remove();
res.json({ message: 'Drone deleted' });