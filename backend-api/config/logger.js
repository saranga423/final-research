const winston = require("winston");
require("winston-daily-rotate-file");
const config = require("./config.json");

// Daily rotating file transport
const dailyRotateFileTransport = new winston.transports.DailyRotateFile({
  filename: config.logger.file || "logs/backend-%DATE%.log",
  datePattern: "YYYY-MM-DD",
  zippedArchive: true,
  maxSize: "20m",
  maxFiles: "14d", // keep logs for 14 days
  level: "info"
});

// Error-specific file transport
const errorFileTransport = new winston.transports.DailyRotateFile({
  filename: "logs/error-%DATE%.log",
  datePattern: "YYYY-MM-DD",
  zippedArchive: true,
  maxSize: "20m",
  maxFiles: "30d",
  level: "error"
});

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
    dailyRotateFileTransport,
    errorFileTransport
  ],
  exceptionHandlers: [
    new winston.transports.File({ filename: "logs/exceptions.log" })
  ],
  rejectionHandlers: [
    new winston.transports.File({ filename: "logs/rejections.log" })
  ]
});

module.exports = logger;
