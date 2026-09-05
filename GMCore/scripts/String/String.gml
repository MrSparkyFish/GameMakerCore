//feather ignore all
 
/** Represents a string. Useful to get output strings from function arguments.
 * @return {Struct.String} */
function String() constructor {
	///@ignore
	text = "";
	
	/** Set the text represented by this string
	 * @arg {String} value The string to set
	 * @return {Undefined} */
	static SetString = function(value) {
		INLINE;
		text = value;
	}
	
	/** Returns the currently set string
	 * @return {String} */
	static GetString = function() {
		INLINE;
		return text;
	}
}