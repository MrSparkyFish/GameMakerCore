//feather ignore all
/** InputDeviceTouch: This device reads touchpoint input.
 * @return {Struct.InputDeviceTouch} */
function InputDeviceTouch() : InputDevice() constructor {
	
	#region Internal
		
		type = Input_DeviceType.touch;
		
		
	#endregion
	
	
	#region Touch Input
		/** Returns `true` if this `InputDevice` has detected any input activity
		 * @return {Bool} */
		static IsActive = function() {
			if (INPUT_BAN_TOUCH) {
				return false;
			}
			return (inputSystem.GameHasFocus() && mouse_check_button(mb_left));
		}
		
		
		/** Returns `true` if this `InputDevice` has not been assigned to a player and is available for use.
		 * @return {Bool} */
		static IsAvailable = function() {
			return (!INPUT_BAN_TOUCH && is_undefined(owner));
		}
	#endregion
}