//feather ignore all

/** InputVirtualButtonVerbs: A struct containing the verbs that are assigned to a particular button.
 * @ignore
 * @arg {Struct.InputVirtualButton} _button The `InputVirtualButton` that owns the verbs in this struct.
 * @return {Struct.InputVirtualButtonVerbs} */
function InputVirtualButtonVerbs(_button) constructor {
	
	if (!AssertIsInstanceOf(_button, InputVirtualButton)) {
		ThrowInvalidType("InputVirtualButtonVerbs", "_button", _button, "InputVirtualButton");
	}
	
	///@ignore
	button = _button;						//Owner
	click = undefined;						//Click verb
	left = undefined;						//Left verb
	right = undefined;						//Right verb
	up = undefined;							//Up verb
	down = undefined;						//Down verb
	
	
	/** Returns a reference to the `InputVirtualButton` this struct is assigned to
	 * @return {struct.InputVirtualButton} */
	static GetOwner = function() {
		return button;
	}
	
}