//feather ignore all

//TODO: Enable Logger to write messages to files -> Requires file read write system to be implemented

/** Logger: Abstract class that writes Messages to a log file.
 * @arg {Struct.MessageSettings} [_settings] Optional config settings to apply to the logger
 * @return {Struct.Logger} */
function Logger(_settings = new MessageSettings("{time} | [{subject}]: {message}")) constructor {
	
	enum logger_level {
		debug,
		info,
		warning,
		error,
		critical,
	}
	
	///@ignore Used as Message subject
	levelNames = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"];
	///@ignore Contains generated messages until they can be written to a file
	log = [];
	///@ignore Message settings the logger will apply when it creates messages
	messageSettings = _settings
	///@ignore If Messages should be printed to the console (true) or just put into the logfile (logfiles not implemented yet).
	printConsole = true;
	///@ignore Wether or not this logger is enabled.
	enabled = true;
	
	/** Returns the array of messages logged to this logger
	 * @return {Array<Struct.Message>} */
	static GetLog = function() {
		return log;
	}
	
	/** Writes a new Message to a log file and returns the formatted message string.
	 * @arg {Real} _level The message level to Log
	 * @arg {String} _messageBody The string to set as the message body
	 * @arg {Struct.MessageSettings} [_settings] An StructMessageSettings of arguments to be replaced in the logged message. Defaults to undefined.
	 * @return {String} */
	static Log = function(_level, _messageBody, _settings = messageSettings) {
		if (!GetEnabled()) {
			return false;
		}
		
		//Create and add Message object to this logger
		var _message = new Message(_messageBody, levelNames[_level], _settings);
		var _logMessage = _message.GetMessage();
		ArrayAdd(log, _message);
		
		//Print the formatted message
		if (printConsole) {
			show_debug_message(_logMessage);
		}
		
		//Return the formatted message
		return _logMessage;
	}
	
	
	/** Logs a debug level message on this logger
	 * @arg {String} _messageBody The string to set as the message body
	 * @arg {Struct.MessageSettings} [_settings] Optional Message settings to change message format
	 * @return {String} */
	static Debug = function(_messageBody, _settings = undefined) {
		if (!LOG_DEBUG_ENABLED) {
			return "Debug Logging is Disabled";
		}
		return Log(logger_level.debug, _messageBody, _settings);
	}
	
	
	/** Logs an info level message on this logger
	 * @arg {String} _messageBody The string to set as the message body
	 * @arg {Struct.MessageSettings} [_settings] Optional Message settings to change message format
	 * @return {String} */
	static Info = function(_messageBody, _settings = undefined) {
		if (!LOG_INFO_ENABLED) {
			return "Info Logging is Disabled";
		}
		return Log(logger_level.info, _messageBody, _settings);
	}	
	
	/** Logs a warning level message on this logger
	 * @arg {String} _messageBody The string to set as the message body
	 * @arg {Struct.MessageSettings} [_settings] Optional Message settings to change message format
	 * @return {String} */
	static Warning = function(_messageBody, _settings = undefined) {
		if (!LOG_WARNING_ENABLED) {
			return "Warning Logging is Disabled";
		}
		return Log(logger_level.warning, _messageBody, _settings);
	}		
	
	/** Logs an error level message on this logger
	 * @arg {String} _messageBody The string to set as the message body
	 * @arg {Struct.MessageSettings} [_settings] Optional Message settings to change message format
	 * @return {String} */
	static Error = function(_messageBody, _settings = undefined) {
		if (!LOG_ERROR_ENABLED) {
			return "Error Logging is Disabled";
		}
		return Log(logger_level.error, _messageBody, _settings);
	}	
	
	/** Logs a critical level message on this logger
	 * @arg {String} _messageBody The string to set as the message body
	 * @arg {Struct.MessageSettings} [_settings] Optional Message settings to change message format
	 * @return {String} */
	static Critical = function(_messageBody, _settings = undefined) {
		if (!LOG_CRITICAL_ENABLED) {
			return "Critical Loggig is Disabled";
		}
		return Log(logger_level.debug, _messageBody, _settings);
	}
	
	/** Enables or disables this logger
	 * @arg {Bool} _bool Whether or not to enable or disable the logger
	 * @return {Undefined} */
	static SetEnabled = function(_bool) {
		enabled = _bool;		
	}
	
	/** Returns `true` if this logger is able to log messages
	 * @return {Bool} */
	static GetEnabled = function() {
		return (enabled && LOGGING_ENABLED);
	}
	
	/** Set if logged messages should also be output to the console
	 * @arg {Bool} _print Wether or not messages are printed to the console when logged
	 * @return {Undefined} */
	static SetPrintToConsole = function(_print) {
		printConsole = _print;
	}
	
	/** Returns `true` if logged messages will also be output to the console
	 * @return {Bool} */
	static GetPrintToConsole = function(_print) {
		return printConsole;
	}
}