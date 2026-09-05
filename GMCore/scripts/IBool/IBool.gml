//feather ignore all
 
/** IBool: Interface for creating unique types of bool
 * @return {Struct.IBool} */
function IBool() {
	
	/** Returns `true` or `false`
	 * @return {Bool} */
	GetBool = function() {
		ThrowMethodNotImplemented("GetBool");
	}
	
	/** Set this bool to `true` or `false`
	 * @arg {Bool} b
	 * @return {Undefined} */
	SetBool = function(b) {
		ThrowMethodNotImplemented("SetBool");
	}
	
}