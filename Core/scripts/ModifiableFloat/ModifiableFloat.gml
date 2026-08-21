//feather ignore all

 
/** Abstract base class for creating floats that can be modified while still retaining their original value. 
 * @arg {Real} initialValue `[=0]` The value of this float
 * @return {Struct.ModifiableFloat} */
function ModifiableFloat(initialValue = 0) : Float(initialValue) constructor {
	
	///@ignore The base value of this float.
	baseValue = initialValue;
	
	/** Sets the base value of this float when no modifiers are applied, then update the current float value.
	 * @arg {Real} newValue The new base value to set
	 * @return {Undefined} */
	static SetBaseValue = function(newValue) {
		INLINE;
		baseValue = newValue;
	}
	
	/** Returns the value of this float when no modifiers are applied.
	 * @return {Real} */
	static GetBaseValue = function() {
		INLINE;
		return baseValue;
	}
}