//feather ignore all
 
/** Represents the most basic type of bool
 * ***
 * Implements: `IBool`
 * @return {Struct.Bool} */
function Bool() constructor {
	//Interface Implementation
	Implement(IBool);
	 
	///@ignore
	b = false;
	
	/** Returns `true` or `false`
	 * @return {Bool} */	
	static GetBool = function() {
		INLINE;
		return b;
	}
	
	/** Set this bool to `true` or `false`
	 * @arg {Bool} b
	 * @return {Undefined} */	
	static SetBool = function(b) {
		INLINE;
		self.b = b;
	}
	
}