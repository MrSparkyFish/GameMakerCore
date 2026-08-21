/** Returns the specified Assert object
 * @arg {String} _name 
 * @return {Struct.Assert} */
function AssertGet(_name = "$$default$$") {
	static singleton = new Assert();
	return singleton;
}


#region Type Asserts


/** Assert a value to be of a type
 * @arg {Any} _value The value to assert
 * @arg {string} _expected The expected type as a string
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsTypeOf(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsTypeOf(_value, _expected, _description);
}


/** Assert a value to be not of a type
 * @arg {Any} _value The value to assert
 * @arg {string} _expected The expected type as a string
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNotTypeOf(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNotTypeOf(_value, _expected, _description);
}


/** Assert a struct to be an instance of a constructor.
 * @arg {Struct} _struct The value to test
 * @arg {Function} _expected The expected value type to test against.
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsInstanceOf(_struct, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsInstanceOf(_struct, _expected, _description);
}


/** Assert a struct to not be an instance of a constructor.
 * @arg {Struct} _struct The value to test
 * @arg {Function} _expected The expected value type to test against.
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNotInstanceOf(_struct, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNotInstanceOf(_struct, _expected, _description);
}


/** Assert a value to be false
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsFalse(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsFalse(_value, _description);
}


/** Assert a value to be true
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsTrue(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsTrue(_value, _description);
}


/** Assert a value to be undefined
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsUndefined(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsUndefined(_value, _description);
}


/** Assert a value to be not undefined
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNotUndefined(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNotUndefined(_value, _description);
}


/** Assert a value to be null
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNull(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNull(_value, _description);
}


/** Assert a value to be not null
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNotNull(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNotNull(_value, _description);
}

/** Assert a value to be callable
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsCallable(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsCallable(_value, _description);
}

/** Assert a value to be not callable
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNotCallable(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNotCallable(_value, _description);
}


/** Assert a value to be real
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsReal(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsReal(_value, _description);
}

/** Assert a value to be numeric
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNumeric(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNumeric(_value, _description);
}

/** Assert a value to be not numeric
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNotNumeric(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNotNumeric(_value, _description);
}

/** Assert a value to be a 32 bit integer
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsInt32(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsInt32(_value, _description);
}

/** Assert a value to be a boolean
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsBool(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsBool(_value, _description);
}


/** Assert a value to be an array
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsArray(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsArray(_value, _description);
}

/** Assert a value to be a struct
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsStruct(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsStruct(_value, _description);
}

#endregion



#region String Asserts


/** Assert a string to contain a substring (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringContains(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringContains(_string, _expected, _description);
}

/** Assert a string to contain all substrings in the array (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {Array<String>} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringContainsAll(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringContainsAll(_string, _expected, _description);
}

/** Assert a string to contain any substring in the array (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {Array<String>} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringContainsAny(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringContainsAny(_string, _expected, _description);
}

/** Assert a string to not equal another string (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringNotContains(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringNotContains(_string, _expected, _description);
}

/** Assert a string to end with a substring (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringEndsWith(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringEndsWith(_string, _expected, _description);
}

/** Assert a string to end with any substring in the array (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {Array<String>} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringEndsWithAny(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringEndsWithAny(_string, _expected, _description);
}

/** Assert a string to not end with a substring (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringNotEndsWith(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringNotEndsWith(_string, _expected, _description);
}

/** Assert a string to equal another string (not case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringEqualsIgnoreCase(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringEqualsIgnoreCase(_string, _expected, _description);
}

/** Assert a string to not equal another string (not case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringNotEqualsIgnoreCase(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringNotEqualsIgnoreCase(_string, _expected, _description);
}

/** Assert a string to start with a substring (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringStartsWith(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringStartsWith(_string, _expected, _description);
}

/** Assert a string to start with any substring in the array (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {Array<String>} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringStartsWithAny(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringStartsWithAny(_string, _expected, _description);
}

/** Assert a string to not start with a substring (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} _expected The string to assert against
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringNotStartsWith(_string, _expected, _description) {
	static singleton = AssertGet();
	return singleton.StringNotStartsWith(_string, _expected, _description);
}


/** Assert a string to not start with a substring (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringIsEmpty(_string, _description) {
	static singleton = AssertGet();
	return singleton.StringIsEmpty(_string, _description);
}


/** Assert a string to not start with a substring (case sensitive)
 * @arg {String} _string The string to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStringIsNotEmpty(_string, _description) {
	static singleton = AssertGet();
	return singleton.StringIsNotEmpty(_string, _description);
}



#endregion



#region Value Asserts

/** Assert a value to be equal to another value
 * @arg {Any} _value The value to assert
 * @arg {Any} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertEquals(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.Equals(_value, _expected, _description);
}

/** Assert a value to be not equal to another value
 * @arg {Any} _value The value to assert
 * @arg {Any} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert 
 * @return {Bool} */
function AssertNotEquals(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.NotEquals(_value, _expected, _description);
}


/** Assert a value to be greater than another value
 * @arg {Any} _value The value to assert
 * @arg {Any} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert 
 * @return {Bool} */
function AssertGreaterThan(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.GreaterThan(_value, _expected, _description);
}


/** Assert a value to be greater than or equal to another value
 * @arg {Any} _value The value to assert
 * @arg {Any} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertGreaterOrEqual(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.GreaterOrEqual(_value, _expected, _description);
}


/** Assert a value to be less than or equal to another value
 * @arg {Any} _value The value to assert
 * @arg {Any} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertLessOrEqual(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.LessOrEqual(_value, _expected, _description);
}


/** Assert a value to be less than another value
 * @arg {Any} _value The value to assert
 * @arg {Any} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertLessThan(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.LessThan(_value, _expected, _description);
}


/** Assert a value to be any value in the array
 * @arg {Any} _value The value to assert
 * @arg {Any} _expected The array of values
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertAnyOf(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.AnyOf(_value, _expected, _description);
}


/** Assert a value to be NaN
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNan(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNaN(_value, _description);
}


/** Assert a value to be not NaN
 * @arg {Any} _value The value to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertIsNotNan(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.IsNotNaN(_value, _description);
}

#endregion



#region Array Asserts

/** Assert an array to contain a value
 * @arg {Array} _array The array to assert
 * @arg {Any} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertArrayContains(_array, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.ArrayContains(_array, _expected, _description);
}


/** Assert an array to contain all values of another array
 * @arg {Array} _array The array to assert
 * @arg {Array} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertArrayContainsAll(_array, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.ArrayContainsAll(_array, _expected, _description);
}


/** Assert an array to contain any value from another array
 * @arg {Array} _array The array to assert
 * @arg {Array} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertArrayContainsAny(_array, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.ArrayContainsAny(_array, _expected, _description);
}


/** Assert an array to be empty
 * @arg {Array} _array The array to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertArrayEmpty(_array, _description = undefined) {
	static singleton = AssertGet();
	return singleton.ArrayIsEmpty(_array, _description);
}


/** Assert an array to be not empty
 * @arg {Array} _array The array to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertArrayNotEmpty(_array, _description = undefined) {
	static singleton = AssertGet();
	return singleton.ArrayNotEmpty(_array, _description);
}


/** Assert an array to be equal to another array
 * @arg {Array} _array The array to assert
 * @arg {Array} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertArrayEquals(_array, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.ArrayEquals(_array, _expected, _description);
}


/** Assert an array to be a certain length
 * @arg {Array} _array The array to assert
 * @arg {Array} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertArrayLength(_array, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.ArrayEquals(_array, _expected, _description);
}
#endregion



#region Struct Asserts

/** Assert a struct to be a certain size
 * @arg {Struct} _value The Struct to assert
 * @arg {Real} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStructSize(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.StructSize(_value, _expected, _description);
}


/** Assert a struct to equal another struct
 * @arg {Struct} _value The array to assert
 * @arg {Struct} _expected The expected assert value
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStructEquals(_value, _expected, _description = undefined) {
	static singleton = AssertGet();
	return singleton.StructEquals(_value, _expected, _description);
}


/** Assert a struct to be empty
 * @arg {Struct} _value The array to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStructEmpty(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.StructEmpty(_value, _description);
}


/** Assert a struct to be not empty
 * @arg {Struct} _value The array to assert
 * @arg {String} [_description] Optional description for a failed assert
 * @return {Bool} */
function AssertStructNotEmpty(_value, _description = undefined) {
	static singleton = AssertGet();
	return singleton.StructNotEmpty(_value, _description);
}

#endregion