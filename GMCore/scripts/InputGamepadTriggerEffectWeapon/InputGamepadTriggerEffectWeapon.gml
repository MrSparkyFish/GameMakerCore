//feather ignore all

/** InputGamepadTriggerEffectWeapon: This effect causes a player's gamepad to simulate the feeling of pulling the trigger on a firearm.
 * @arg {Real} _strength The strength of the resistance applied by the firearm trigger from `0` to `1`
 * @arg {Real} _start Where on the trigger axis the effect should start applying resistance from `0` to `1` (the break point)
 * @arg {Real} _end Where on the trigger axis the effect should stop applying resistance from `0` to `1` (the release point)
 * @return {Struct.InputGamepadTriggerEffectWeapon} */
function InputGamepadTriggerEffectWeapon(_strength, _start, _end) : InputGamepadTriggerEffect(_strength, 0, 0, 0, _start, _end) constructor {
	
	///@ignore
	static modeName = "weapon";
	///@ignore
	static type = Input_TriggerEffectType.weapon;
	
	
	/** Applies a gamepad trigger effect using the PS5 platform
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to apply the effect to
	 * @arg {Constant.GamepadButton} _trigger The gamepad trigger for the effect
	 * @arg {Real} _strength The intensity of the effect.
	 * @return {Bool} */
	static ApplyPS5 = function(_gamepad, _trigger, _strength) {
		return ps5_gamepad_set_trigger_effect_weapon(_gamepad.GetIndex(), _trigger, data.GetPosition(), data.GetAmplitude() * _strength, data.GetFrequency());
	}
	
	/** Returns an `Enum.Input_TriggerEffectState` value representing the steam state of the specified gamepad's trigger relative to this trigger effect.
	 * @arg {Struct.InputDeviceGamepad} _gamepad The gamepad to target
	 * @arg {Constant.GamepadButton} _trigger Either `gp_shoulderrb` or `gp_shoulderlb` trigger constants
	 * @return {Real} */
	static GetSteamState = function(_gamepad, _trigger) {
		var _data = GetData();
		var _endPos = (_data.GetEndPosition() + 2)/10;
		var _startPos = _data.GetStartPosition()/10;
		var _val = _gamepad.CheckButton(_trigger);
		var _state = Input_TriggerEffectState.weaponStandby;
		
		//Evaluate our assumption
		if (_val > min(9.9, _endPos)) {
			_state = Input_TriggerEffectState.weaponFired;
		}
		else if (_val >= _startPos) {
			_state = Input_TriggerEffectState.weaponPulling;
		}
		
		return _state;
	}	
}