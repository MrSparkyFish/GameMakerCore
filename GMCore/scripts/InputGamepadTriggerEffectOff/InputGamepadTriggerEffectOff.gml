//feather ignore all

/** InputGamepadTriggerEffectOff: When set for a player, this effect clears and removes the currently set gamepad trigger effect.
 * @return {Struct.InputGamepadTriggerEffectOff} */
function InputGamepadTriggerEffectOff() : InputGamepadTriggerEffect(0, 0, 0, 0, 0, 0) constructor {
	
	///@ignore
	static modeName = "off";
	///@ignore
	static type = Input_TriggerEffectType.off;
	
	/** Applies a gamepad trigger effect using the PS5 platform
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to apply the effect to
	 * @arg {Constant.GamepadButton} _trigger The gamepad trigger for the effect
	 * @arg {Real} _strength The intensity of the effect.
	 * @return {Bool} */	
	static ApplyPS5 = function(_gamepad, _trigger, _strength) {
		return ps5_gamepad_set_trigger_effect_off(_gamepad.GetIndex(), _trigger);
	}
	
	/** Returns an `Enum.Input_TriggerEffectState` value representing the steam state of the specified gamepad's trigger relative to this trigger effect.
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to target
	 * @arg {Constant.GamepadButton} _trigger Either `gp_shoulderrb` or `gp_shoulderlb` trigger constants
	 * @return {Real} */
	static GetSteamState = function(_gamepad, _trigger) {
		return Input_TriggerEffectState.off;
	}	
}