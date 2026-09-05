//feather ignore all

/** InputBindingCapture: Small data container that encapsulates a specific input binding and some other relevant data.
 * @arg {Enum.Input_Verb} _verb The verb index with the detected collision
 * @arg {Constant} _button The button that triggered the collision
 * @arg {Real} _index The index of the binding array the button was found in
 * @arg {Bool} _forGamepad Set `true` if the `_button` constant is a gp_* constant. Set `false` or leave blank to indicate a vk_* or mb_* constant instead.
 * @return {Struct.InputBindingCapture} */
function InputBindingCapture(_verb, _button, _index, _forGamepad) constructor {

	#region Internal
		///@ignore
		verb = _verb;						//Verb index that has the button bound
		///@ignore
		button = _button;					//Button constant thats bound
		///@ignore
		index = _index;						//The index in the binding array where the button is bound to
		///@ignore
		forGamepad = _forGamepad;			//Tells us if the button is a gp_* button or a vk_*/mb_* button.
		
		
	#endregion
	
	
	/** Returns the verb index that reported the button collision.
	* @return {Enum.Input_Verb} */
	static GetVerbIndex = function() {
		return verb;
	}
	
	/** Returns the button constant that triggered the collision.
	* @return {Real} */
	static GetButtonConstant = function() {
		return button;
	}
	
	/** Returns `true` if the button involved in the collision was a gamepad button
	 * @return {Bool} */
	static IsForGamepad = function() {
		return forGamepad;
	}
	
	/** Returns the button binding index where the button constant was found
	 * @return {Real} */
	static GetBindingIndex = function() {
		return index;
	}
}