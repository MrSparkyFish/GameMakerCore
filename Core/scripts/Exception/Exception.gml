/** Exception: Base class for custom exception structs. Intended to be subclassed.
 * ***
 * Implements: `IString`
 * @arg {String} _title The title of the exception
 * @arg {String} _description Description of the exception
 * @arg {Struct|Id.Instance} _origin `[=self]` Where the exception originated from
 * @return {Struct.Exception} */
function Exception(_title = "", _description = "", _origin = self) constructor {
	message = _title;
	longMessage = _description;
	script = undefined;
	line = undefined;
	stacktrace = [];
	origin = _origin;
	
	var _len = array_length(stacktrace) - 1;
	var _stack = debug_get_callstack();
	for (var i = 2; i < _len; i++) {
		
		var _stackline = _stack[i];
		var _position = string_pos(":", _stackline);
		
		if (i == 2) {
			script = string_copy(_stackline, 1, _position - 1);
			line = real(string_copy(_stackline, _position + 1, string_length(_stackline) - _position));
		}
		_stackline = string_replace(_stackline, ":", " (line ");
		_stackline += ")";
		array_push(stacktrace, _stackline);
	}
	
	
	
	/** Internal logic for updating message and long message for subclasses.
	 * @ignore
	 * @return {Undefined} */
    static UpdateException = function() {
		//Update message and long message to include the exception name
        var _exceptionName = instanceof(origin);
        message = $"{_exceptionName}::{message}";
        longMessage = $"{_exceptionName}\r\n{longMessage}";
        
        // add more info for YYC as it is not adding standard error output like on VM
        if (code_is_compiled()) {
            longMessage = $"Unable to find a handler for exception {longMessage}\r\n";
            
            for (var i = 0, length = array_length(stacktrace); i < length; i++) {
                longMessage += $"\r\n {stacktrace[i]}";
            }
        }
    }	
	
	
	static toString = function() {
		UpdateException();
		return string(longMessage);
	}
	
}