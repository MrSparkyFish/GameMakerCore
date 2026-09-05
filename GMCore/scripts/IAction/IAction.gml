//feather ignore all
 
/** IAction: Represents an object with an `Execute([data])` method
 * ***
 * @return {Struct.IAction} */
function IAction() {
	
	/** Execute this action delegate
	 * @return {Any} */
	Execute = function() {
		ThrowMethodNotImplemented("Execute", self);
	}
}