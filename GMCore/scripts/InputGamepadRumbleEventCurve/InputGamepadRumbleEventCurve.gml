//feather ignore all

/** InputGamepadRumbleEventCurve: This rumble event allows a gamepad to rumble using a predefined curve of magnitude values.
 * @arg {Struct.Curve} _curve The curve to use for rumble and intensity. The curve should contain two channel indexes: `channel 0` for the left motor, and `channel 1` for the right.
 * @arg {Real} _strength Peak strength of the rumble event at the top of the attack portion of the curve from 0 to 1.
 * @arg {Real} _bias Left-to-right motor bias for the rumble event where -1 only activates the left motor and 1 only activates the right motor.  
 * @arg {Real} _duration Duration of the rumble event (milliseconds)
 * @arg {Bool} [_force] `[=false]` Whether this rumble event should ignore the "rumble paused" state of the gamepad.  
 * @return {Struct.InputGamepadRumbleEventCurve} */
function InputGamepadRumbleEventCurve(_curve, _strength, _bias, _duration, _force = undefined) : InputGamepadRumbleEvent(_strength, _bias, _force) constructor {
	
	#region Private
		///@ignore
		curve = _curve;												//The curve used in magnitude evaluation
		
	#endregion
	
	/** Evaluates the magnitude of this vibrator component.
	 * @return {Undefined} */	
	static EvaluateMagnitude = function() {
		var _t = time/duration;
		
		var _left = 1;
		var _right = 1;
		
		var _channelCount = curve.ChannelCount();
		if (_channelCount == 1) {
			_left = clamp(curve.ChannelEvaluate(curve.ChannelGetAt(0), _t), 0, 1);
			_right = _left;
		}
		
		else {
			var _channelLeft = curve.ChannelGetAt(0);
			var _channelRight = curve.ChannelGetAt(1);
			
			if (!is_undefined(_channelLeft)) {
				_left = clamp(curve.ChannelEvaluate(_channelLeft, _t), 0, 1);
			}
			
			if (!is_undefined(_channelRight)) {
				_right = clamp(curve.ChannelEvaluate(_channelRight, _t), 0, 1);
			}
		}
		
		magnitude = GetBiasedMotorStrength().Multiply(new Vector2(_left, _right));
	}
}