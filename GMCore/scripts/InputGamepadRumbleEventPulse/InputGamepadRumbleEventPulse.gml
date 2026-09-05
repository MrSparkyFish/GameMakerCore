//feather ignore all

/** InputGamepadRumbleEventPulse: This rumble events allows a gamepad to rumble using a set number of pulses at a given strength.
 * @arg {Real} _strength Peak strength of the rumble event at the top of the attack portion of the curve from 0 to 1.
 * @arg {Real} _bias Left-to-right motor bias for the rumble event where -1 only vibrates the left motor and 1 only vibrates the right motor.  
 * @arg {Real} _duration Duration of the rumble event (milliseconds)
 * @arg {Bool} _pulseCount The number of rumble pulses to execute over the duration
 * @arg {Bool} [_force] `[=false]` Whether this rumble event should ignore "rumble paused" state of the gamepad.   
 * @return {Struct.InputGamepadRumbleEventPulse} */
function InputGamepadRumbleEventPulse(_strength, _bias, _duration, _pulseCount, _force) : InputGamepadRumbleEvent(_strength, _bias, _force) constructor {
	
	
	#region Private
		
		///@ignore
		pulseCount = _pulseCount;										//Number of pulses in this event
		
	#endregion
	
	/** Returns the coefficient used to evaluate the strength of each pulse
	 * @return {Real} */
	static GetPulseCoefficient = function() {
		coefficient ??= 360 * (GetPulseCount() - 180);
		return coefficient;
	}
	
	/** Returns the number of rumble pulses this event will emit
	 * @return {Real} */
	static GetPulseCount = function() {
		return pulseCount;
	}
	
	/** Evaluates the magnitude of this vibrator component.
	 * @return {Undefined} */	
	static EvaluateMagnitude = function() {
		var _t = time/duration;
		var _pulse = dsin(_t * GetPulseCoefficient());	
		var _output = 0.5 + (0.5*_pulse);
		magnitude = GetBiasedMotorStrength().Multiply(_output);
	}
}