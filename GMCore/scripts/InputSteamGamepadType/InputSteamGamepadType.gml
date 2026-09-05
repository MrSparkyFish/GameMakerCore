//feather ignore all

/** SteamGamepadType: This is a data structure used by the `InputSystem` to convert steam gamepad types to gamepad types that it can understand.
 * @ignore
 * @arg {Real} _steamType The gamepad type as determined by steam.
 * @arg {Enum.Input_GamepadType} _gamePadType The gamepad type that `_steamType` convert's to
 * @arg {String} _description Gamepad description to set
 * @return {Struct.SteamGamepadType} */
function SteamGamepadType(_steamType, _gamePadType, _description) constructor {
	///@ignore
	type = _gamePadType;								//The `InputSystem` gamepad type.
	///@ignore
	description = _description;							//The steam description we set for this type
	
	/** Returns the steam description we set for this gamepad type during steam initialization.
	 * @return {String} */
	static GetDescription = function() {
		return description;
	}
	
	/** Returns the `Enum.Input_GamepadType` value assigned for this steam type.
	 * @return {Real} */
	static GetType = function() {
		return type;
	}
}