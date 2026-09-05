//feather ignore all

/** This interface adds a `GetSystemComponent()` method to the calling Struct or GMO. The added method should be redefined to return an `InputSystemComponent` object.
 * @return {Undefined} */
function IInputSystem() {
	
	/** Returns the `InputSystemComponent` this object uses to access and respond to player input.
	 * @return {Struct.InputSystemComponent} */
	GetInputSystemComponent = function() {
		ThrowMethodNotImplemented("GetInputSystemComponent", self);
	}
}