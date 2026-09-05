//feather ignore all

/** InputGamepadTriggerEffect: Represents an effect that can be applied to a gamepad trigger.
 * @return {Struct.InputGamepadTriggerEffect} */
function InputGamepadTriggerEffect(_strength, _amplitude, _frequency, _position, _startPosition, _endPosition) constructor {
	
	
	
	enum Input_TriggerEffectState {
		off = ps5_gamepad_trigger_effect_state_off,
		feedbackStandby = ps5_gamepad_trigger_effect_state_feedback_standby,
		feebackActive = ps5_gamepad_trigger_effect_state_feedback_active,
		weaponStandby = ps5_gamepad_trigger_effect_state_weapon_standby,
		weaponPulling = ps5_gamepad_trigger_effect_state_weapon_pulling,
		weaponFired = ps5_gamepad_trigger_effect_state_weapon_fired,
		vibrationStandby = ps5_gamepad_trigger_effect_state_vibration_standby,
		vibrationActive = ps5_gamepad_trigger_effect_state_vibration_active,
		intercepted = ps5_gamepad_trigger_effect_state_intercepted
	}	
	
	
	static modeName = "";
	static type = -1;
	data = new InputGamepadTriggerEffectData(_strength, _amplitude, _frequency, _position, _startPosition, _endPosition);
	
	
	/** Applies a gamepad trigger effect using the PS5 platform
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to apply the effect to
	 * @arg {Constant.GamepadButton} _trigger The gamepad trigger for the effect
	 * @arg {Real} _strength The intensity of the effect.
	 * @return {Bool} */
	static ApplyPS5 = function(_gamepad, _trigger, _strength) {
		ThrowMethodNotImplemented("ApplyPS5");
	}
	
	/** Returns an `Enum.Input_TriggerEffectState` value representing the steam state of the specified gamepad's trigger relative to this trigger effect.
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to target
	 * @arg {Constant.GamepadButton} _trigger Either `gp_shoulderrb` or `gp_shoulderlb` trigger constants
	 * @return {Real} */
	static GetSteamState = function(_gamepad, _trigger) {
		ThrowMethodNotImplemented("GetSteamState", self);
	}
	
	/** Returns the name of the mode used by the trigger effect
	 * @return {String} */
	static GetModeName = function() {
		return modeName;
	}
	
	/** Returns the data struct used by the trigger effect
	 * @return {Struct.InputGamepadTriggerEffectData} */
	static GetData = function() {
		return data;
	}
	
	/** Returns the mode type of the trigger effect
	 * @return {Real} */
	static GetType = function() {
		return type;
	}
}