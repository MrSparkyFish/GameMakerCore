//feather ignore all
 
/** Abstract base class for defining custom float values.
 * @arg {Real} [value] The optional initial currentValue of this float. Defaults to `0`.
 * @return {Struct.Float} */
function Float(value = 0) constructor {
	
	///@ignore The current value of this float.
	self.currentValue = value;
	
	/** Returns the current value of this `Float`.
	 * @return {Undefined} */
	static GetValue = function() {
		INLINE;
		return currentValue;
	}
	
	/** Sets the current value of this Float
	 * @arg {Real} newValue The new currentValue to set
	 * @return {Undefined} */
	static SetValue = function(newValue) {
		INLINE;
		if (!is_numeric(newValue)) {
			ThrowInvalidType("SetValue", "_newValue", newValue, "Numeric");
		}
		currentValue = newValue;
	}
}