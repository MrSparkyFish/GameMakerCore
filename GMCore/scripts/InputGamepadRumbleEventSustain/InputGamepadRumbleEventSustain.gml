//feather ignore all

/** InputGamepadRumbleEventSustain: This rumble event causes a gamepad to rumble at a constant strength for the duration
 * @arg {Real} _strength Strength of the rumble from 0 to 1
 * @arg {Real} _bias Left-Right motor bias where -1 is left motor only and 1 is right motor only
 * @arg {Real} _duration Duration of the rumble event (milliseconds)
 * @arg {Bool} [_force] `[=false]` Whether or not the "rumble paused" state should be ignored.
 * @return {Struct.InputGamepadRumbleEventSustain} */
function InputGamepadRumbleEventSustain(_strength, _bias, _duration, _force = false) : InputGamepadRumbleEvent(_strength, _bias, _duration, _force) constructor {
	
	/** Evaluates the magnitude of this vibrator component.
	 * @return {Undefined} */
	static EvaluateMagnitude = function() {
		if (is_undefined(magnitude)) {
			magnitude = GetBiasedMotorStrength();
		}
	}	
	
}