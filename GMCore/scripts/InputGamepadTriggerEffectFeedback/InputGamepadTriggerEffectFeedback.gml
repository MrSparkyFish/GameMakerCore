//feather ignore all

/** InputGamepadTriggerEffectFeedback: Allows a player's gamepad to provide resistance when a trigger is pulled.
 * @arg {Real} _position The position within the trigger axis where resistance should begin. Should be a value from `0` to `1`.
 * @arg {Real} _strength The strength of the resistance applied from `0` to `1`
 * @return {Struct.InputGamepadTriggerEffectFeedback} */
function InputGamepadTriggerEffectFeedback(_position, _strength) : InputGamepadTriggerEffect(_strength, 0, 0, _position, 0, 0) constructor {
	
	///@ignore
	static modeName = "feedback";
	///@ignore
	static type = Input_TriggerEffectType.feedback;
	
	
	/** Applies a gamepad trigger effect using the PS5 platform
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to apply the effect to
	 * @arg {Constant.GamepadButton} _trigger The gamepad trigger for the effect
	 * @arg {Real} _strength The intensity of the effect.
	 * @return {Bool} */
	static ApplyPS5 = function(_gamepad, _trigger, _strength) {
		return ps5_gamepad_set_trigger_effect_feedback(_gamepad.GetIndex(), _trigger, data.GetPosition(), data.GetStrength() * _strength);
	}
	
	
	/** Returns an `Enum.Input_TriggerEffectState` value representing the steam state of the specified gamepad's trigger relative to this trigger effect.
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to target
	 * @arg {Constant.GamepadButton} _trigger Either `gp_shoulderrb` or `gp_shoulderlb` trigger constants
	 * @return {Real} */
	static GetSteamState = function(_gamepad, _trigger) {
		var _data = GetData();
		var _pos = _data.GetPosition()/10;
		var _state = Input_TriggerEffectState.feedbackStandby;
		
		//Evaluate our assumption
		if (_gamepad.CheckButton(_trigger) >= _pos) {
			return Input_TriggerEffectState.feebackActive;
		}
		
		return _state;
	}
}