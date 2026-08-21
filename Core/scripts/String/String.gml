//feather ignore all
 
/** Represents a string. Useful to get output strings from function arguments.
 * ***
 * Implements: `IString`
 * @return {Struct.String} */
function String() constructor {
	///@ignore
	text = undefined;
	
	/** Set the text represented by this string
	 * @arg {String} value The string to set
	 * @return {Undefined} */
	static Set = function(value) {
		text = value;
	}
	
	///@ignore
	static toString = function() {
		return text;
	}
}