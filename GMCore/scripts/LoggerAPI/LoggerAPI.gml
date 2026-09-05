//feather ignore all

/** Returns a logger with the specified name. If no logger exists, one is created.
 * @arg {String} _name The name of the logger to be fetched
 * @return {Struct.Logger} */
function LoggerGet(_name, _settings = undefined) {
	
	static loggers = {};
	
	//Get the named logger
	if (struct_exists(loggers, _name)) {
		return loggers[$ _name];
	}
	
	//If the named logger wasn't found, make a new one
	var _log = new Logger(_settings);
	loggers[$ _name] = _log;
	
	//Return the logger
	return _log;
}

/** Logs a debug level message on the default logger
 * @arg {String} _message The message to log
 * @arg {Struct.MessageSettings} [_settings] Optional message settings to use
 * @return {String} */
function LogDebug(_message, _settings = undefined) {
	//default logger accepts log messages of level debug or higher
	static default_logger = LoggerGet(LOGGER_DEFAULT_ID);
	
	//Log the message
	return default_logger.Debug(_message, _settings);
}


/** Logs an info level message on the default logger
 * @arg {String} _message The message to log
 * @arg {Struct.MessageSettings} [_settings] Optional message settings to use
 * @return {String} */
function LogInfo(_message, _settings = undefined) {
	//default logger accepts log messages of level debug or higher
	static default_logger = LoggerGet(LOGGER_DEFAULT_ID);
	
	//Log the message
	return default_logger.Info(_message, _settings);
}


/** Logs a warning level message on the default logger
 * @arg {String} _message The message to log
 * @arg {Struct.MessageSettings} [_settings] Optional message settings to use
 * @return {String} */
function LogWarning(_message, _settings = undefined) {
	//default logger accepts log messages of level debug or higher
	static default_logger = LoggerGet(LOGGER_DEFAULT_ID);
	
	//Log the message
	return default_logger.Warning(_message, _settings);	
}


/** Logs an error level message on the default logger
 * @arg {String} _message The message to log
 * @arg {Struct.MessageSettings} [_settings] Optional message settings to use
 * @return {String} */
function LogError(_message, _settings = undefined) {
	//default logger accepts log messages of level debug or higher
	static default_logger = LoggerGet(LOGGER_DEFAULT_ID);
	
	//Log the message
	return default_logger.Error(_message, _settings);	
}


/** Logs a critical level message on the default logger
 * @arg {String} _message The message to log
 * @arg {Struct.MessageSettings} [_settings] Optional message settings to use
 * @return {String} */
function LogCritical(_message, _settings = undefined) {
	//default logger accepts log messages of level debug or higher
	static default_logger = LoggerGet(LOGGER_DEFAULT_ID);
	
	
	//Log the message
	return default_logger.Critical(_message, _settings);	
}