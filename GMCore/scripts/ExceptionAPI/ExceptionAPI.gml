//feather ignore all

/** Returns a string with the format "{_origin}::{_function} -> {_description}"
 * @arg {String} _function The name of the function that caused the string to be generated
 * @arg {String} _description Brief description of why the message  generated
 * @arg {Struct|Id.Instance} _origin Who or where is the message originating from
 * @return {String} */
function ExceptionMessage(_function, _description, _origin = undefined) {
	_origin ??= self;
	_origin = (is_struct(_origin)) ? instanceof(_origin) : _origin;
	return $"{_origin}::{_function} -> {_description}";
}

/** Throw a generic exception with a title and description.
 * @arg {String} _title Title to give the exception
 * @arg {String} _description Description of the exception
 * @arg {Struct|Id.Instance} [_scope] `[=self]` Alternative scope if not the calling scope.
 * @return {Undefined} */
function ThrowException(_title, _description, _scope = undefined) {
	_scope ??= self;
	var error = new Exception(_title, _description, _scope);
	throw (error);
}

/** Throw an exception for an invalid data type.
 * @arg {String} _function The name of the function that the error originated in
 * @arg {String|Any} _variableName The name of the variable holding the invalid data
 * @arg {Any} _variableValue The value of the variable
 * @arg {String} _expectedType The expected value type
 * @arg {Struct|Id.Instance} [_origin] Optionally specify the scope that the function was called in. Defaults to `self`.
 * @return {Undefined} */
function ThrowInvalidType(_function, _variableName, _variableValue, _expectedValue, _origin = undefined) {
	var _type = (is_struct(_variableValue)) ? StructGetConstructor(_variableValue) : typeof(_variableValue);
	var _message = "Invalid Argument!";
	var _longMessage = ExceptionMessage(_function, $"{_variableName} is type [{_type}] and not type [{_expectedValue}]", _origin);
	ThrowException(_message, _longMessage, _origin);
}

/** Throw an exception for invalid data.
 * @arg {String} _function The name of the function that the error originated in
 * @arg {String} _description Description that explains why this exception was thrown.
 * @arg {Struct|Id.Instance} [_origin] Optionally specify the scope that the function was called in. Defaults to `self`.
 * @return {Undefined} */
function ThrowInvalidData(_function, _description, _origin = undefined) {
	var _message = "Data Not Valid!";
	var _longMessage = ExceptionMessage(_function, _description, _origin);
	ThrowException(_message, _longMessage, _origin);
}

/** Throw an exception for an an object that fails to meet specified interface requirements.
 * @arg {String} _function Name of the function causing the exception
 * @arg {Struct|Id.Instance} _interfaceReceived The object that should have implemented the interface but didn't.
 * @arg {String} _expectedInterface The interface that should have been implemented.
 * @arg {Struct|Id.Instance} _origin Who called the function that threw the exception if different from the scope of `self`
 * @return {Undefined} */
function ThrowInterfaceNotImplemented(_function, _implementingObject, _interface, _origin = undefined) {
	var _message = "Interface Not Implemented!"
	var _longMessage = ExceptionMessage(_function, $"{_implementingObject} does not meet implementation requirements for interface {_interface}", _origin);
	ThrowException(_message, _longMessage, _origin);
}

/** Throw an out-of-bounds exception
 * @arg {String} _function The name of the function that the error originated in
 * @arg {String} _variableName The name of the variable holding the invalid index
 * @arg {Real} _index The index that was attempted to be accessed
 * @arg {Array} _array The array that was accessed
 * @arg {Struct|Id.Instance} _origin Who caused the error if different from the calling instance/struct
 * @return {Undefined} */
function ThrowArrayIndexOutOfBounds(_function, _variableName, _index, _array, _origin = undefined) {
	var _message = "Array Index Out of Bounds!";
	var _longMessage = ExceptionMessage(_function, $"Index {_index} from variable '{_variableName}' is outside array bounds of {array_length(_array) - 1}", _origin)	
	ThrowException(_message, _longMessage, _origin);
}

/** Throw a Method not implemented exception
 * @arg {String} _function The name of the method that was not implemented.
 * @arg {Struct|Id.Instance} [_origin] The scope containing the undefined function. Defaults to `self`.
 * @return {Undefined} */
function ThrowMethodNotImplemented(_function, _origin = undefined) {
	var _message = "Method Error!";
	var _longMessage = ExceptionMessage(_function, "Method Not Implemented!", _origin);
	ThrowException(_message, _longMessage, _origin);
}

/** Throw an exception for an unsupported value such as a number that is outside the range of the targeted enumeration.
 * @arg {String} _function Name of the function causing the exception
 * @arg {Any} _value The value that is unsupported.
 * @arg {String} _description why the value is unsupported (ie: Outside of enumeration range, value doesn't exist in struct, etc.)
 * @arg {Struct|Id.Instance} _origin Who called the function with the exception if different from the scope of `self`
 * @return {Undefined} */
function ThrowValueNotSupported(_function, _value, _description, _origin = undefined) {
	var _message = "Value Not Supported!";
	var _longMessage = ExceptionMessage(_function, $"Value [{_value}] is not supported. {_description}", _origin);
	ThrowException(_message, _longMessage, _origin);
}