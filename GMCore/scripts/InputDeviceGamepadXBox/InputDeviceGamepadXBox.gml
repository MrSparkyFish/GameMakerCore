//feather ignore all
/**
 * @arg {Real} _gamepadIndex The index number to set for this gamepad
 * @arg {Real} [_description] Optionally set a custom description for the gamepad. Not recommended to set manually as some gamepads use their description as an encryption.
 * @arg {Struct.InputGamepadGUID} [_guid] The GUID gamepad product information. Automatically retrieved if left blank or set to `undefined`
 * @return {} */
function InputDeviceGamepadXBox(_port, _description, _guid) : InputDeviceGamepad(_port, _description, _guid) constructor {
	
	
	#region Internal 
		//Check for an XInput device. Force its description if it was
		var _xinput = (INPUT_WINDOWS && (_port < 4) && (!StringContains(_guid.GetGUID(), "000000007801")))//(HID)
		if (_xinput) {
			gpType = Input_GamepadType.xBox;	
			description = "XInput";
			flags.SetBitState(Input_DeviceFlags.xinput, true);
		}
		
		//Modify to fit steam expectations.
		SteamTransform();
		SteamTransformQuirks();				
	#endregion
}