//feather ignore all
 
/** Abstract superclass for objects that can hold instanced properties.
 * @return {Struct.PropertyHolder} */
function PropertyHolder() constructor {
	///@ignore Stores all the properties of this instance.
	properties = {};
	
	/** Declares a variable as a configurable Property.
	 * @arg {String} name The name of the Property
	 * @arg {Function} [getter] Optional getter method
	 * @arg {Function} [setter] Optional setter method
	 * @arg {Function} [validator] Optional validator method
	 * @arg {Enum.PropertyAccessType} [accessType] Manually set access type.
	 * @return {Struct.Property} */
	static AddProperty = function(name, getter = undefined, setter = undefined, validator = undefined, accessType = PropertyAccessType.readOrWrite) {
		INLINE;
		properties[$ name] ??= new Property(name, self, getter, setter, validator, accessType);
		return properties[$ name];
	}
	
	/** Returns the raw `Property` object. Returns `undefined` if the property doesn't exist.
	 * @arg {String} name The name of the property to get
	 * @return {Struct.Property} */
	static GetProperty = function(name) {
		INLINE;
		return properties[$ name];
	}
	
	/** Set the value of a property
	 * @arg {String} name The name of the property to set
	 * @arg {Any} value The value to set for the property
	 * @return {Undefined} */
	static SetPropertyValue = function(name, value) {
		INLINE;
		var property = GetProperty(name);
		if (!is_undefined(property)) {
			property.Set(value);
		}
	}
	
	/** Returns the value of the named property. Returns `NULL` if the property doesn't exist.
	 * @return {Any} */
	static GetPropertyValue = function(name) {
		INLINE;
		var property = GetProperty(name);
		return (!is_undefined(property)) ? property.Get() : NULL;
	}
}