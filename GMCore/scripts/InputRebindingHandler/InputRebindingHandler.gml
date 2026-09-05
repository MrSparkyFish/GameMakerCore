//feather ignore all

/** InputRebindingHandler: Used to handle device rebinding. Should only be instantiated at the rebindingTime of rebinding
 * @arg {Struct.InputDevice} _device The device this handler processes rebinding for
 * @arg {Array} _ignoreArray Array of button constants to explicitly ignore
 * @arg {Array} _allowArray Array of button constants to explicitly include
 * @return {Struct.InputRebindingHandler} */
function InputRebindingHandler(_device, _ignoreArray, _allowArray) constructor {
	
	///@ignore
	static inputSystem = InputSystem.singleton;				//System reference
	///@ignore
	device = _device;										//Device that is being handled
	///@ignore
	deviceType = _device.GetType();							//Our device type
	///@ignore
	rebindingTime = current_time;							//Time that this handler was created
	///@ignore
	rebindingWait = true;									//Allows us to stop rebinding if we found a button
	///@ignore
	rebindingResult = undefined;							//Stores the button found
	///@ignore
	rebindingIgnore = _ignoreArray;							//Array of button constants to ignore
	///@ignore
	rebindingAllow = _allowArray;							//Array of button constants to allow
	
	
	/** Processes rebinding attempts for the assigned device. The button found by this process can be retrieved by calling `RebindingResult()`. 
	 * @return {Undefined} */
	static Handle = function() {
		
		//Timeout for rebinding
		if ((rebindingTime - current_time) > INPUT_REBIND_TIMEOUT) {
			return inputSystem.DeviceDisableRebinding(device);
		}
		
		//Scan for our button binding.
		var _binding = undefined;
		if (deviceType == Input_DeviceType.gamepad) {
			_binding = inputSystem.GamepadBindingScan(device, rebindingIgnore, rebindingAllow);
		}
		else if (deviceType == Input_DeviceType.kbm) {
			_binding = inputSystem.KbmBindingScan(device, rebindingIgnore, rebindingAllow);
		}
		
		
		if (rebindingWait) {
			if (is_undefined(_binding)) {
				rebindingWait = false;
			}
		}
		else {
			if (!is_undefined(_binding)) {
				rebindingResult = _binding;
				rebindingWait = true;
			}
		}
	}
	
	/** Returns the button found from processing device rebinding. Returns `undefined` if no result is available.
	 * @return {Constant.InputButton} */
	static RebindingResult = function() {
		return rebindingResult;
	}
}