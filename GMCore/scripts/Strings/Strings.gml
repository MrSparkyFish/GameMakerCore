//feather ignore all

#macro STRING_LINEBREAK "\n#################################################################################\n"

/** Capitalizes the first letter and lower cases all other letters for each string in the array.
 * @arg {Array<String>} _array An array of strings to convert into upper camel case.
 * @return {Array<String>} */ 
function StringUpperCamelCase(_array) {
	var _len = array_length(_array);
	var _output = array_create(_len);
	
	//Loop through all array strings
	for (var i = 0; i < _len; i++) {
		var _string = _array[i];
		_string = string_lower(_string);
		_output[i] = StringCapitalize(_string);
	}
	
	return _output;
}

/** Removes all characters from the front or back part of the specified string starting at the specified character index.
 * @arg {String} stringToSplice The string to copy and delete from.
 * @arg {Real} index The position of the first character to remove (starting at 1). Negative values are supported and count from the end of the string (ie; 1 indicates the first character while -1 indicates the last character).
 * @arg {Bool} removeLeft Set `true` to remove the index and everything to its left. Set `false` to remove the index and everything to its right.
 * @return {String} */
function StringSplice(stringToSplice, index, removeLeft) {
	if (index == 0) {
		return stringToSplice;
	}
	if (removeLeft ^^ MathIsNegative(index)) {
		return string_delete(stringToSplice, index, -index);
	}
	var len = (removeLeft) ? ~string_length(stringToSplice) : string_length(stringToSplice) + 1;
	return string_delete(stringToSplice, index, len - index);
}


/** Capitalizes the first Letter character found in the given string. Does nothing if the string contains no letters
 * @arg {String} _string The string to capitalize the first letter for
 * @return {String} */
function StringCapitalize(_string) {
	var _char = StringFindFirstLetter(_string);
	
	//Check there is a letter to capitalize
	if (!is_undefined(_char)) {
		return string_replace(_string, _char, string_upper(_char));	
	}
	
	//Return the original string or string with capped first letter
	else {
		return _string;
	}
}


/** Returns the position of the first letter character found in the provided string
 * @arg {String} _string The string to find the first letter position for
 * @return {Real} */
function StringFirstLetterPosition(_string) {
	//Convert string to letters
	var _letters = string_letters(_string);
	var _len = string_length(_letters);
	
	//If there's letters get the first letters position in the original string
	if (_len > 0) {
		var _char = string_char_at(_letters, 1);
		_len = string_pos(_char, _string); 
	}
	
	//Returns 0 if no letters found
	return _len;
}


/** Returns the first letter character found in the given string. Returns undefined if the argument string has no letters.
 * @arg {String} _string The string to get the first letter for
 * @return {String|Undefined} */
function StringFindFirstLetter(_string) {
	var _pos = StringFirstLetterPosition(_string);
	
	//If a first letter is found, get the char
	if (_pos > 0) {
		return string_char_at(_string, _pos);
	}
}

/** Checks if a string contains any of the specified substrings and returns true if it does or false if it doesn't
 * @arg {String} _string The string to check
 * @arg {String|Array<String>} _substring The substring or array of substrings to check for
 * @return {Bool} */
function StringContains(_string, _substring) {
	_substring = ArrayConvertValue(_substring);
	
	var i = 0; repeat(array_length(_substring)) {
		if (string_pos(_substring[i++], _string) > 0) {
			return true;
		}
	}
	return false;
}

/** Returns `true` if a string exactly matches any string from an array of strings
 * @arg {String} _string The string to check
 * @arg {String|Array<String>} _array Array of strings to compare against
 * @return {Bool} */
function StringMatchesAny(_string, _array) {
	_array = ArrayConvertValue(_array);
	var _len = array_length(_array);
	for (var i = 0; i < _len; i++) {
		if (_string == _array[i]) {
			return true;
		}
	}
	return false;
}