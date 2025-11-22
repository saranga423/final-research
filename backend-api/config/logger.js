const winston = require("winston");
const config = require("./config.json");

const logger = winston.createLogger({
  level: config.logger.level || "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.printf(
      ({ timestamp, level, message }) => `${timestamp} [${level.toUpperCase()}] ${message}`
    )
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: config.logger.file || "logs/backend.log" })
  ]
});

module.exports = logger;
