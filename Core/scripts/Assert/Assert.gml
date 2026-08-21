/** Assert: Singleton that provides the methods for enforcing that a value follows a rule
 * @ignore
 * @arg {Struct} [_options] Optional settings to apply to the Assert singleton
 * @return {Struct.Assert} */
function Assert(_options = undefined) : Configurable() constructor {
	
	#macro ASSERT_THROW_ON_FAIL true
	
	//Member variables
	///@ignore
	assertDepth = 0;						//Tracks depth for asserts on containers (like arrays, structs, etc.)
	///@ignore
	userData = undefined;					//Optional Array of arguments to Pass to the failHook and passHook if set.
	///@ignore
	assertCount = 0;						//Tracks number of asserts since last reset
	
	//Configurable variables
	///@ignore
	failHook = undefined;					//Optional method to call on every failed assertion. Allows arguments (in this order): title, description, assertedValue, expectedValue, callstack, optData.
	///@ignore
	passHook = undefined;					//Optional method to call on every passed assertion. Allows arguments (in this order): title, description, assertedValue, expectedValue, callstack, optData.
	///@ignore
	throwOnFail = ASSERT_THROW_ON_FAIL;		//If an Assert error should be thrown when an assert is failed
	
	AddProperty("failHook");
	AddProperty("passHook");
	AddProperty("throwOnFail", , function(newValue) {
		if (is_bool(newValue)) {
			throwOnFail = newValue;
		}
	});
	
	
	
	/** Custom exception for failed asserts.
	 * @arg {String} _title
	 * @arg {Any} _value
	 * @arg {Any} _expected
	 * @arg {String} _description
	 * @return {Undefined} */
	static AssertError = function(_title, _value, _expected, _description) {
		ThrowException("Failed Assert!", $"{_title} | Asserted Value: {_value} | Expected Value: {_expected} | Description: {_description}");
		return;
	}
	
	
	
	/** Sets some 'user data' that will be carried over to the Pass and Fail 'hook' functions
	 * @arg {Any} _data The data to set
	 * @return {Undefined} */
	static SetUserData = function(_data) {
		userData = _data;
	}
	
	
	/** Resets the assertion number counter
	 * @return {Undefined} */
	static ResetAssertionCount = function() {
		assertCount = 0;
	}
	
	
	/** Returns the number of assertions since the last reset
	 * @return {Real} */
	static GetAssertionCount = function() {
		return assertCount;
	}
	
	
	/** Resets the assert depth and any set user data
	 * @return {Undefined} */
	static Reset = function() {
		assertDepth = 0;
		userData = undefined;
	}
	
	
	#region Assert Pass/Fail Logic
	
	/** Handles the Assert failed logic
	 * @arg {String} _title The title of the assert being made
	 * @arg {String} _description The assert description 
	 * @arg {Any} _value The actual result of the assertion
	 * @arg {Any} _expected The expected value for the assertion
	 * @return {Bool} */
	static Fail = function(_title, _description, _value = undefined, _expected = undefined) {
		if (assertDepth != 0) {
			return false;
		}
		
		
		assertCount++;
		
		//Call the Fail hook and Pass in user data
		if (is_callable(failHook)) {
			method_call(failHook, userData);
		}
		
		//Throw an exception if the assert fails
		if (throwOnFail) {
			AssertError(_title, _value, _expected, _description);
		}		
		
		return false;
	}
	
	
	/** Handles the Assert passed logic
	 * @arg {String} _title The title of the assert being made
	 * @arg {String} _description The assert description 
	 * @arg {Any} _value The actual result of the assertion
	 * @arg {Any} _expected The expected value for the assertion
	 * @return {Bool} */
	static Pass = function(_title, _description, _value = undefined, _expected = undefined) {
		if (assertDepth != 0) {
			return true;
		}
		
		assertCount++;
		
		//Call the Pass hook and Pass in user data
		if (is_callable(passHook)) {
			method_call(passHook, userData);
		}
		
		
		return true;	
	}
	
	#endregion	
	
	
	#region Assert Data Types
	
	/** Assert value to be a certain type. GameMaker Data types only.
	 * @arg {Any} _value The value to test
	 * @arg {String} _expected The expected value type to test against.
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsTypeOf = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be a certain type";
		
		var _type = typeof(_value);
		var _resolver = (_type == string_lower(_expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _type, _expected);
	}	
	
	
	/** Assert value to not be a certain type
	 * @arg {Any} _value The value to test
	 * @arg {Any} _expected The expected value type to test against.
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsNotTypeOf = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to not be a certain type";
		
		var _type = typeof(_value);
		var _resolver = (_type != _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _type, _expected);
	}	
	
	
	/** Assert a struct to be an instance of a constructor.
	 * @arg {Struct} _struct The value to test
	 * @arg {Function} _expected The expected value type to test against.
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsInstanceOf = function(_struct, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be a certain type";
		
		//if not a struct or not a function then exit, but dont Fail
		if (!is_struct(_struct) || !is_callable(_expected)) {
			return false;
		}
		
		
		var _resolver = (is_instanceof(_struct, _expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _struct, _expected);
	}
	
	
	/** Assert a struct to not be an instance of a constructor.
	 * @arg {Struct} _struct The value to test
	 * @arg {Function} _expected The expected value type to test against.
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsNotInstanceOf = function(_struct, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be a certain type";
		
		//if not a struct or not a function then exit, but dont Fail
		if (!is_struct(_struct) || !is_callable(_expected)) {
			return false;
		}
		
		var _resolver = (!is_instanceof(_struct, _expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _struct, _expected);
	}	
	
	
	/** Assert value to be false
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsFalse = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be false";
		
		var _resolver = (_value == false) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, false);
	}	
	
	
	/** Assert value to be true
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsTrue = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be true";
		
		var _resolver = (_value == true) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, true);
	}	
	
	
	/** Assert value to be undefined
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for thIs assert.
	 * @return {Bool} */
	static IsUndefined = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be undefined";
		
		var _resolver = (_value == undefined) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, undefined);
	}	
	
	
	/** Assert value to be not undefined
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsNotUndefined = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be not undefined";
		
		var _resolver = (_value != undefined) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value);
	}	
	
	
	/** Assert value to be null
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsNull = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be null";
		
		var _resolver = (_value == pointer_null) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}		
	
	
	/** Assert value to be not null
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsNotNull = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be not null";
		
		var _resolver = (_value != pointer_null) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}	
	
	/** Assert value to be numeric
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsNumeric = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be numeric";
		
		var _resolver = (is_numeric(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}
	
	/** Assert value to be not numeric
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsNotNumeric = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be not numeric";
		
		var _resolver = (!is_numeric(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}
	
	/** Assert value to be a real number
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsReal = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be real";
		
		var _resolver = (is_real(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}
	
	/** Assert value to be a 32 bit integer
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsInt32 = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be a 32 bit integer";
		
		var _resolver = (is_int32(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}	
	
	/** Assert value to be a boolean value
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsBool = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be a boolean";
		
		var _resolver = (is_bool(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}		
	
	/** Assert value to be an Array
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsArray = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be an array";
		
		var _resolver = (is_array(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}
	
	/** Assert value to be a struct
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert.
	 * @return {Bool} */
	static IsStruct = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be a struct";
		
		var _resolver = (is_struct(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, pointer_null);
	}		
	
	#endregion
	
	
	#region Assert Values
	
	/** Assert values to be equal
	 * @arg {Any} _value The value to test
	 * @arg {Any} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static Equals = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert values to be equal";
		
		var _resolver = (_value == _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, _expected);
	}
	
	
	/** Assert values to not be equal
	 * @arg {Any} _value The value to test
	 * @arg {Any} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static NotEquals = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert values to not be equal";
		
		var _resolver = (_value != _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, _expected);
	}
	
	
	/** Assert value to be greater than
	 * @arg {Any} _value The value to test
	 * @arg {Any} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static GreaterThan = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be greater than";
		
		var _resolver = (_value > _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, _expected);
	}	
	
	
	/** Assert value to be greater than or equal to
	 * @arg {Any} _value The value to test
	 * @arg {Any} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static GreaterOrEqual = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be greater than or equal to";
		
		var _resolver = (_value >= _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, _expected);
	}
	
	
	/** Assert value to be less than
	 * @arg {Any} _value The value to test
	 * @arg {Any} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static LessThan = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be less than";
		
		var _resolver = (_value < _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, _expected);
	}	
	
	
	/** Assert value to be less than or equal to
	 * @arg {Any} _value The value to test
	 * @arg {Any} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static LessOrEqual = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be less than or equal to";
		
		var _resolver = (_value <= _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, _expected);
	}		
	
	
	/** Assert value to be of any value in the array
	 * @arg {Any} _value The value to test
	 * @arg {Array} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static AnyOf = function(_value, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be of any value in the array";
		
		if (!is_array(_expected)) {
			throw LogError($"anyOf :: invalid argument '_expected' must be of type <Array>. [Self = {self}] :: [Other = {other}]");
		}
		
		var _resolver = array_contains(_expected, _value) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value, _expected);
	}	
	
	
	/** Assert value to be NaN
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static IsNaN = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to be NaN";
		
		var _resolver = (is_nan(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value);
	}		
	
	
	/** Assert value to not be NaN
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static IsNotNaN = function(_value, _description = undefined) {
		//Assert Type
		static assert_title = "Assert value to not be NaN";
		
		var _resolver = (!is_nan(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value);
	}	
	
	/** Assert value to be callable
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] Optional description for this assert
	 * @return {Bool} */
	static IsCallable = function(_value, _description) {
		//Assert Type
		static assert_title = "Assert value to not be callable";
		
		var _resolver = (is_callable(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value);
		
	}
	
	/** Assert value to be not callable
	 * @arg {Any} _value The value to test
	 * @arg {String} [_description] Optional description for this assert
	 * @return {Bool} */	
	static IsNotCallable = function(_value, _description) {
		//Assert Type
		static assert_title = "Assert value to not be callable";
		
		var _resolver = (!is_callable(_value)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _value);
		
	}
	
	
	
	
	#endregion	
	
	
	#region Assert Strings
	
	/** Assert string to contain a substring
	 * @arg {String} _string The string to test
	 * @arg {Real} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringContains = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to contain a substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be a string
		if (!is_string(_expected)) {
			throw LogError($"stringContains :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}		
		
		//Try to find the position of the substring inside the string
		var _pos = string_pos(_expected, _string);
		var _resolver = (_pos > 0) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	
	/** Assert string to contain all substrings
	 * @arg {String} _string The string to test
	 * @arg {Array<String>} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringContainsAll = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to contain all substrings";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringContainsAll :: invalid argument, '_expected' must be of type <Array<String>>. [Self = {self}] :: [Other = {other}]");
		}		
		
		//Try to find the position of the substrings inside the string
		var _found = 0, _length = array_length(_expected);
		for (var _i = 0; _i < _length; _i++) {
			var _pos = string_pos(_expected[_i], _string);
			if (_pos > 0) _found++;
		}
		
		var _resolver = (_found == _length) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	
	/** Assert string to contain any substrings
	 * @arg {String} _string The string to test
	 * @arg {Array<String>} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringContainsAny = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to contain any substrings";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringContainsAny :: invalid argument, '_expected' must be of type <Array<String>>. [Self = {self}] :: [Other = {other}]");
		}		
		
		//Assume failed
		var _passed = false;
		
		//Try to find the position of any substrings inside the string
		var _found = 0, _length = array_length(_expected);
		for (var _i = 0; _i < _length; _i++) {
			var _pos = string_pos(_expected[_i], _string);
			if (_pos > 0) {
				_passed = true;
				break;
			}
		}
		
		var _resolver = (_passed) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	
	/** Assert string to end with a substring
	 * @arg {String} _string The string to test
	 * @arg {String} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringEndsWith = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to end with a substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringEndsWith :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}		
		
		var _resolver = (string_ends_with(_string, _expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	
	/** Assert string to not end with a substring
	 * @arg {String} _string The string to test
	 * @arg {String} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringNotEndsWith = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to not end with a substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringNotEndsWith :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}		
		
		var _resolver = (!string_ends_with(_string, _expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	
	/** Assert string to end with any substring
	 * @arg {String} _string The string to test
	 * @arg {Array<String>} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringEndsWithAny = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to end with any substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringEndsWithAny :: invalid argument, '_expected' must be of type <Array<String>>. [Self = {self}] :: [Other = {other}]");
		}
		
		//Assume failed
		var _passed = false;
		
		// Go for each entry in the input array
		var _length = array_length(_expected);
		for (var i = 0; i < _length; i++) {
			if (string_ends_with(_string, _expected[i])) {
				_passed = true;
				break;
			}
		}				
		
		var _resolver = (_passed) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}		
	
	
	/** Assert string to equal a string (ignoring case sensitive)
	 * @arg {String} _string The string to test
	 * @arg {String} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringEqualsIgnoreCase = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to equal a string (ignoring case sensitive)";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringEqualsIgnoreCase :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}
		
		var _resolver = (string_lower(_string) == string_lower(_expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}
	
	
	/** Assert string to not equal a string (ignoring case sensitive)
	 * @arg {String} _string The string to test
	 * @arg {String} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringNotEqualsIgnoreCase = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to not equal a string (ignoring case sensitive)";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringNotEqualsIgnoreCase :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}
		
		var _resolver = (string_lower(_string) != string_lower(_expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	
	/** Assert string to not contain a substring
	 * @arg {String} _string The string to test
	 * @arg {String} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringNotContains = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to not contain a substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringNotContains :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}
		
		//Try to find the position of the substring inside the string
		var _pos = string_pos(_expected, _string);		
		
		var _resolver = (_pos <= 0) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}
	
	
	/** Assert string to start with a substring
	 * @arg {String} _string The string to test
	 * @arg {String} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringStartsWith = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to start with a substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringStartsWith :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}		
		
		var _resolver = (string_starts_with(_string, _expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	
	/** Assert string to not start with a substring
	 * @arg {String} _string The string to test
	 * @arg {String} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringNotStartsWith = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to not start with a substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringNotStartsWith :: invalid argument, '_expected' must be of type <String>. [Self = {self}] :: [Other = {other}]");
		}		
		
		var _resolver = (!string_starts_with(_string, _expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}
	
	
	/** Assert string to start with any substring
	 * @arg {String} _string The string to test
	 * @arg {Array<String>} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringStartsWithAny = function(_string, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to start with any substring";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		//_expected must be an array
		if (!is_string(_expected)) {
			throw LogError($"stringStartsWithAny :: invalid argument, '_expected' must be of type <Array<String>>. [Self = {self}] :: [Other = {other}]");
		}	
		
		//Assume failed
		var _passed = false;
		
		//Loop each entry in the input array
		var _length = array_length(_expected);
		for (var _i = 0; _i < _length; _i++) {
			if (string_starts_with(_string, _expected[_i])) {
				_passed = true;
				break;
			};
		}
		
		var _resolver = (_passed) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}
	
	
	/** Assert string to be empty
	 * @arg {String} _string The string to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringIsEmpty = function(_string, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to be empty";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		var _expected = "";
		var _resolver = (_string == _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	
	/** Assert string to be not empty
	 * @arg {String} _string The string to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StringIsNotEmpty = function(_string, _description = undefined) {
		//Assert Type
		static assert_title = "Assert string to be not empty";
		
		//if not a string then exit, but dont Fail
		if (!is_string(_string)) {
			return false;
		}
		
		var _expected = "";
		var _resolver = (_string != _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _string, _expected);
	}	
	#endregion
	
	
	#region Assert Arrays
	
	/** Assert array to contain a value
	 * @arg {Array} _array The value to test
	 * @arg {Any} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static ArrayContains = function(_array, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert array to contain a value";
		
		//if not an array then exit, but dont Fail
		if (!is_array(_array)) {
			return false;
		}
		
		var _resolver = (array_contains(_array, _expected)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _array, _expected);
	}		
	
	
	/** Assert array to contain all values
	 * @arg {Array} _array The value to test
	 * @arg {Array} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static ArrayContainsAll = function(_array, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert array to contain all values";
		
		//if not an array then exit, but dont Fail
		if (!is_array(_array)) {
			return false;
		}
		
		//expected needs to be an array
		if (!is_array(_expected)) {
			throw LogError($"arrayContainsAll :: invalid argument '_expected' must be of type <Array>. [Self = {self}] :: [Other = {other}]");
		}
		
		var _resolver = (array_contains_ext(_array, _expected, true)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _array, _expected);
	}		
	
	
	/** Assert array to contain any value
	 * @arg {Array} _array The value to test
	 * @arg {Array} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static ArrayContainsAny = function(_array, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert array to contain any value";
		
		//if not an array then exit, but dont Fail
		if (!is_array(_array)) {
			return false;
		}
		
		//expected needs to be an array
		if (!is_array(_expected)) {
			throw LogError($"arrayContainsAny :: invalid argument '_expected' must be of type <Array>. [Self = {self}] :: [Other = {other}]");
		}
		
		var _resolver = (array_contains_ext(_array, _expected, false)) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _array, _expected);
	}		
	
	
	/** Assert array to be empty
	 * @arg {Array} _array The value to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static ArrayIsEmpty = function(_array, _description = undefined) {
		//Assert Type
		static assert_title = "Assert array to be empty";
		
		//if not an array then exit, but dont Fail
		if (!is_array(_array)) {
			return false;
		}
		
		var _resolver = (array_length(_array) == 0) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _array);
	}
	
	
	/** Assert two arrays are equal
	 * @arg {Array} _array The value to test
	 * @arg {Array} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static ArrayEquals = function(_array, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert two arrays are equal";
		
		//if not an array then exit, but dont Fail
		if (!is_array(_array)) {
			return false;
		}
		
		//expected needs to be an array
		if (!is_array(_expected)) {
			throw LogError($"arrayEquals :: invalid argument '_expected' must be of type <Array>. [Self = {self}] :: [Other = {other}]");
		}
		
		//Temp Pass var
		var _passed = true;
		
		//Test is array lengths match
		var _len = array_length(_array);
		if (_len != array_length(_expected)) {
			_passed = false;
		}
		
		//Loop through all elements until an index doesn't match
		for (var i = 0; ((i < _len) && (_passed)); i++) {
			
			//test current array index
			var _current = _array[i];
			
			//If struct, make sure they're the same
			if (is_struct(_current)) {
				assertDepth++;
				_passed = StructEquals(_current, _expected[i], _description);
				assertDepth--;
			}
			
			//Otherwise if array, make sure they're the same
			else if (is_array(_current)) {
				assertDepth++;
				_passed = ArrayEquals(_current, _expected[i], _description);
				assertDepth--;
			}
			
			else if (_current != _expected[i]) {
				_passed = false;
			}
		}
		
		
		var _resolver = (_passed) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _array, _expected);
	}	
	
	
	/** Assert array to be of exact length
	 * @arg {Array} _array The value to test
	 * @arg {Real} _expected The expected value to test against
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static ArrayLength = function(_array, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert array to be of exact length";
		
		//if not an array then exit, but dont Fail
		if (!is_array(_array)) {
			return false;
		}
		
		var _result = array_length(_array);
		var _resolver = (_result == _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _result, _expected);
	}
	
	
	/** Assert array to be not empty
	 * @arg {Array} _array The value to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static ArrayNotEmpty = function(_array, _description = undefined) {
		//Assert Type
		static assert_title = "Assert array to be not empty";
		
		//if not an array then exit, but dont Fail
		if (!is_array(_array)) {
			return false;
		}
		
		var _resolver = (array_length(_array) > 0) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _array);
	}		
	
	#endregion
	
	
	#region Assert Structs
	
	/** Assert struct size to be equal
	 * @arg {Struct} _struct The struct to test
	 * @arg {Real} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StructSize = function(_struct, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert struct size to be equal";
		
		//if not a struct then exit, but dont Fail
		if (!is_struct(_struct)) {
			return false;
		}
		
		var _result = struct_names_count(_struct);
		var _resolver = (_result == _expected) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _result, _expected);
	}	
	
	
	/** Assert struct to be empty
	 * @arg {Struct} _struct The struct to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StructEmpty = function(_struct, _description = undefined) {
		//Assert Type
		static assert_title = "AAssert struct to be empty";
		
		//if not a struct then exit, but dont Fail
		if (!is_struct(_struct)) {
			return false;
		}
		
		var _result = struct_names_count(_struct);
		var _resolver = (_result == 0) ? Pass : Fail;
		
		return _resolver(assert_title, _description, struct_get_names(_struct));
	}		
	
	
	/** Assert struct to be not empty
	 * @arg {Struct} _struct The struct to test
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StructNotEmpty = function(_struct, _description = undefined) {
		//Assert Type
		static assert_title = "AAssert struct to be not empty";
		
		//if not a struct then exit, but dont Fail
		if (!is_struct(_struct)) {
			return false;
		}
		
		var _result = struct_names_count(_struct);
		var _resolver = (_result > 0) ? Pass : Fail;
		
		return _resolver(assert_title, _description, struct_get_names(_struct));
	}	
	
	
	/** Assert struct to be equal to another struct
	 * @arg {Struct} _struct The struct to test
	 * @arg {Struct} _expected The expected value to test against.
	 * @arg {String} [_description] An optional description for this assert_true.
	 * @return {Bool} */
	static StructEquals = function(_struct, _expected, _description = undefined) {
		//Assert Type
		static assert_title = "Assert struct to be equal to another struct";
		
		//if not a struct then exit, but dont Fail
		if (!is_struct(_struct)) {
			return false;
		}
		
		//_expected must be a struct
		if (!is_struct(_expected)) {
			throw LogError($"mapSize :: invalid argument, '_expected' must be of type <Struct>. [Self = {self}] :: [Other = {other}]");
		}			
		
		// Assume the assertion passed
		var _passed = true;
		
		// Fail if sizes mismatch
		var _size = struct_names_count(_struct);
		if (_size != struct_names_count(_expected)) {
			_passed = false;
		}
		
		// Loop through all the struct elements
		var _names = struct_get_names(_expected);
		for (var i = 0; i < _size && _passed; i++) {
			
			var _name = _names[i];			
			var _current = _struct[$ _name];
			
			// Resolve nested structs
			if (is_struct(_current)) {
				assertDepth++;
				_passed = StructEquals(_current, _expected[$ _name], _description);
				assertDepth--;
			}
			// Resolve nested lists
			else if (is_array(_current)) {
				assertDepth++;
				_passed = ArrayEquals(_current, _expected[$ _name], _description);
				assertDepth--;
			}
			// Compare values
			else if (_current != _expected[$ _name]) {	
				_passed = false;
			}
		}
		
		var _resolver = (_passed) ? Pass : Fail;
		
		return _resolver(assert_title, _description, _struct, _expected);
	}	
	
	#endregion	
	
	//Main
	Configure(Config_GetConfig(self));		//Apply default settings
	Configure(_options);				//Apply custom settings
}