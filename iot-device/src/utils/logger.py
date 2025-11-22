# utils/logger.py
import logging
import os
from .constants import LOG_FILE

def setup_logger(name="IoTDroneLogger", log_file=None, level=logging.INFO):
    """
    Setup a logger that writes to both console and a log file.

    :param name: Logger name
    :param log_file: Path to log file. Defaults to LOG_FILE from constants.py
    :param level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
    :return: Configured logger instance
    """
    log_file = log_file or LOG_FILE

    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(level)

    # Avoid adding multiple handlers if logger is reused
    if logger.hasHandlers():
        logger.handlers.clear()

    # Console handler
    ch = logging.StreamHandler()
    ch.setLevel(level)
    ch_formatter = logging.Formatter("[%(asctime)s] [%(levelname)s] %(message)s")
    ch.setFormatter(ch_formatter)

    # File handler
    os.makedirs(os.path.dirname(log_file) or ".", exist_ok=True)
    fh = logging.FileHandler(log_file)
    fh.setLevel(level)
    fh.setFormatter(ch_formatter)

    # Add handlers to logger
    logger.addHandler(ch)
    logger.addHandler(fh)

    return logger
