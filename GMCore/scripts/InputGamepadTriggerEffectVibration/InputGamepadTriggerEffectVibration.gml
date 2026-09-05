//feather ignore all

/** InputTriggerEffectGamepadVibration: This effect causes a rumble effect to occur on a player's gamepad when the trigger is pressed.
 * @arg {Real} _position The trigger axis value where the effect should begin from `0` to `1`.
 * @arg {Real} _amplitude The amplitude of the vibration wave from `0` to `1`.
 * @arg {Real} _frequency The frequency of the vibration wave from `0` to `1`.
 * @return {Struct.InputTriggerEffectGamepadVibration} */
function InputGamepadTriggerEffectVibration(_position, _amplitude, _frequency) : InputGamepadTriggerEffect(0, _amplitude, _frequency, _position, 0, 0) constructor {
	
	///@ignore
	static modeName = "vibration";
	///@ignore
	static type = Input_TriggerEffectType.vibration;
	
	
	/** Applies a gamepad trigger effect using the PS5 platform
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to apply the effect to
	 * @arg {Constant.GamepadButton} _trigger The gamepad trigger for the effect
	 * @arg {Real} _strength The intensity of the effect.
	 * @return {Bool} */
	static ApplyPS5 = function(_gamepad, _trigger, _strength) {
		return ps5_gamepad_set_trigger_effect_vibration(_gamepad.GetIndex(), _trigger, data.GetPosition(), data.GetAmplitude() * _strength, data.GetFrequency());
	}
	
	/** Returns an `Enum.Input_TriggerEffectState` value representing the steam state of the specified gamepad's trigger relative to this trigger effect.
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to target
	 * @arg {Constant.GamepadButton} _trigger Either `gp_shoulderrb` or `gp_shoulderlb` trigger constants
	 * @return {Real} */
	static GetSteamState = function(_gamepad, _trigger) {
		var _data = GetData();
		var _pos = _data.GetPosition()/10;
		var _state = Input_TriggerEffectState.vibrationStandby;
		
		//Evaluate our assumption
		if (_gamepad.CheckButton(_trigger) >= _pos) {
			return Input_TriggerEffectState.vibrationActive;
		}
		
		return _state;
	}	
}