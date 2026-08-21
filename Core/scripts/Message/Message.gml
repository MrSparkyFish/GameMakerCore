/** Message: Represents a string formatted to include a subject and a timestamp.
 * ***
 * Implements: `IString`
 * @arg {String} _text The string to format
 * @arg {String} [_subject] Optional subject
 * @arg {Struct.MessageSettings} [_settings] Optional format settings. This should be a struct with two string members: `messageFormat` and `timeFormat` 
 * @return {Struct.Message} */
function Message(_text, _subject = undefined, _settings = undefined) constructor {
	 
	///@ignore visualization of how the format is structured
	static timeFormatPlaceholders = StructFromArray2D([
		["{Y}", "{0}"],
		["{M}", "{1}"],
		["{D}", "{2}"],
		["{h}", "{3}"],
		["{m}", "{4}"],
		["{s}", "{5}"]
	]);	
	///@ignore visualization of how the format is structured
	static messageFormatPlaceholders = StructFromArray2D([
		["{message}", "{0}"], 
		["{time}", "{1}"],
		["{subject}", "{2}"]
	]);	
	
	
	///@ignore String used to format time. {3} = hour, {4} = minute, etc
	timeFormat = "{3}:{4}:{5}";
	///@ignore String used to format the message. {0} = message text, {1} = timestamp, {2} = subject
	messageFormat = "[{1} | {2}]: {0}";
	///@ignore
	messageBody = _text;
	///@ignore
	subject = _subject ?? "No Subject";
	
	
	/** Returns the formatted Message text timestamped with the time it was received.
	 * @return {String} */
	static GetMessage = function() {
		var _rawMessage = messageBody;
		var _timeStamp = string(timeFormat, current_year, current_month, current_day, current_hour, current_minute, current_second);	
		var _message = string(messageFormat, _rawMessage, _timeStamp, subject);
		return _message;
	}
	
	/** Returns the unformatted message text.
	 * @return {String} */
	static MessageBodyGet = function() {
		return messageBody;
	}
	
	/** Returns the Subject assigned to this Message
	 * @return {String} */
	static GetSubject = function() {
		return subject;
	}
	
	/** Sets the Log message format
	 * @arg {String} _format The format to use. Accepts placeholders {message}, {time}, and {subject}
	 * @return {Undefined} */
	static SetMessageFormat = function(_format) {
		if (!is_string(_format)) {
			return;
		}
		
		//Only need these vars once since they aren't changing
		static message_placeholders = struct_get_names(messageFormatPlaceholders);
		static message_placeholders_count = array_length(message_placeholders);
		
		//Loop through the format message
		for (var i = 0; i < message_placeholders_count; i++) {
			var _name = message_placeholders[i];
			_format = string_replace_all(_format, _name, messageFormatPlaceholders[$ _name]);
		}
		
		//Set the message format
		messageFormat = _format;
	}
	
	/** Sets the Log time format
	 * @arg {String} _time_format The format to use. Accepts placeholders {Y}, {M}, {D}, {h}, {m}, and {s}
	 * @return {Undefined} */
	static SetTimeFormat = function(_time_format) {
		if (!is_string(_time_format)) {
			return;
		}
		
		static time_placeholders = struct_get_names(timeFormatPlaceholders);
		static time_placeholders_count = array_length(time_placeholders);
		
		//Loop through the time format
		for (var i = 0; i < time_placeholders_count; i++) {
			var _name = time_placeholders[i];
			_time_format = string_replace_all(_time_format, _name, timeFormatPlaceholders[$ _name]);
		}
		
		//Set the time format
		timeFormat = _time_format;
	}	
	
	/** Converts this struct into a string by returning its set message
	 * @ignore
	 * @return {String} */
	static toString = function() {
		return GetMessage();
	}
	
	
	if (!is_undefined(_settings)) {
		SetTimeFormat(_settings.timeFormat);
		SetMessageFormat(_settings.messageFormat);
	}
}