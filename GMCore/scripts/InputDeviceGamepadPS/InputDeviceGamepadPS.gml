//feather ignore all
/**
 * @arg {Real} _gamepadIndex The index number to set for this gamepad
 * @arg {Real} [_description] Optionally set a custom description for the gamepad. Not recommended to set manually as some gamepads use their description as an encryption.
 * @arg {Struct.InputGamepadGUID} [_guid] The GUID gamepad product information. Automatically retrieved if left blank or set to `undefined`
 * @return {} */
function InputDeviceGamepadPS(_port, _description, _guid) : InputDeviceGamepad(_port, _description, _guid) constructor {
	
	
	#region Internal 
		
		//Identifying specific controller type;
		var _desc = string_lower(description);
		if (StringContains(_desc, ["ps5", "dualsense", "backbone one playstation"])) {
			gpType = Input_GamepadType.ps5;
		}
		else if (StringContains(_desc, ["ps4", "ps3", "ps2", "ps1", "psx", "playstation", "dualshock", "sony", "8bitdo p30"])) {
			gpType = Input_GamepadType.ps4;
		}		
		
		//Convert the select button to touchpad
		ButtonNullifyMapping(gp_select);
		ButtonSetMap(gp_touchpadbutton, function(_deviceIndex) {
			return gamepad_button_value(_deviceIndex, gp_select);
		});	
		
		//Modify to fit steam expectations.
		SteamTransform();
		SteamTransformQuirks();					
		
	#endregion
}