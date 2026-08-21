//feather ignore all

/** A data struct used to get, set, and validate exposable variables. 
 * ***
 * Implements: `IString`
 * @arg {String} _name The name of the Property.
 * @arg {Struct} _owner The owner of this Property.
 * @arg {Function} _getter The getter method for this Property. Called in the scope it was originally defined. 
 * @arg {Function} _setter The setter method for this Property. Called in the scope it was originally defined. 
 * @arg {Function} _validator The validator method for this Property. Verifies if this property is valid or not.
 * @arg {Enum.PropertyAccessType} [_accessType] Optional struct of meta data to alter how this property behaves.
 * @return {Struct.Property} */
function Property(_name, _owner, _getter = undefined, _setter = undefined, _validator = undefined, _accessType = PropertyAccessType.readOrWrite) constructor {  
	enum PropertyAccessType {
		read = 1,
		write = 2,
		readOrWrite = 3
	}
	
	///@ignore The name of the variable that holds the value of this property on the owner
	name = _name;
	
	///@ignore AccessType of this property. 
	accessType = _accessType;
	
	///@ignore The owner of this property
	owner = _owner;
	
	///@ignore Optional custom validator method.
	validator = _validator;
	
	///@ignore Optional custom setter method to set the property value
	setter = _setter;
	
	///@ignore Optional custom getter method to get the property value
	getter = _getter;
	
	/** Sets the value of this Property. Calls the custom setter if available, otherwise sets the field directly.
	 * @arg {Any} value The value to try and set
	 * @return {Undefined} */
	static Set = function(value) {
		INLINE;
		//Cannot write to non-writable properties
		if ((accessType & PropertyAccessType.write) == 0) {
			Config_PropertyError("Set", $"Property '{name}' is Write only.");
		}
		if (!IsValid(value)) {
			Config_PropertyError("Set", $"Invalid property value. Cannot set property {name}.");
		}
		return (is_callable(setter)) ? setter(value) : SetField(value);
	}
	
	/** Returns the value of this Property. Calls the custom getter if available, otherwise gets the field directly.
	 * @return {Any} */
	static Get = function() {
		INLINE;
		//Cannot get read-only properties
		if ((accessType & PropertyAccessType.read) == 0) {
			Config_PropertyError("Get", $"Access to Property '{name}' is not allowed.");
		}
		return (is_callable(getter)) ? getter() : GetField();
	}
	
	/** Checks if the value assigned to this property is currently valid or not. Alternatively, provide a new value to see if its valid in the context of this 
	 * property.
	 * @arg {Any} [value] Optional value to check. Intended for internal use but can be used elsewhere if needed.
	 * @return {Bool} */
	static IsValid = function(value = Get()) {
		if (is_callable(validator)) {
			return validator(value);
		}
		return true;
	}
	
	/** Returns the name of the Property
	 * @return {String} */
	static GetName = function() {
		INLINE;
		return name;
	}
	
	/** Directly returns the raw value of the field backing this property.
	 * @return {Any} */
	static GetField = function() {
		INLINE;
		return owner[$ name];
	}
	
	/** Directly sets the raw value of the field backing this property
	 * @arg {Any} value The value to set
	 * @return {Undefined} */
	static SetField = function(value) {
		INLINE;
		owner[$ name] = value;
	}
	
	/** Convert this property to a string
	 * @ignore
	 * @return {String} */
	static toString = function() {
		var _access = (accessType) ? "PRIVATE" : "PUBLIC";
		return $"{_access} property: {name}";
	}
	
}