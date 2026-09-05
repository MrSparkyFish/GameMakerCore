//feather ignore all

/** InputGamepadRumbleEvent:
 * These events are like components for `InputGamepadVibrator`. They dictate how strong a gamepads rumble is, how long it lasts for, 
 * and more. These events are stored on a per-player basis and are automatically fed to the `InputGamepadVibrator` assigned to the
 * player's active gamepad. Additionally, each player can have multiple assigned rumble events and aren't limited to a single event at a time.
 * ***
 * This specific event class is not meant to be instantiated on its own. Its just the superclass, but it's subclassed into 4 different 
 * rumble events and is designed for you to subclassed it into your own custom events as well. To do so, create a subclass of this and 
 * redefine its `EvaluateMagnitude()` method so that it changes the `magnitude` property to fit your needs. `InputGamepadVibrators` are 
 * fed these events once per game frame until the duration of the event is over. During this process, all rumbled events held by a player
 * have their magnitudes re-evaluated for changes, are combined and finalized, and then set for their gamepad.
 * @arg {Real} _strength Strength of the rumble from 0 to 1
 * @arg {Real} _bias Left-Right motor bias where -1 is left motor only and 1 is right motor only
 * @arg {Real} _duration Duration of the rumble event (milliseconds)
 * @arg {Bool} [_force] `[=false]` Whether or not the "rumble paused" state should be ignored.
 * @return {Struct.InputGamepadRumbleEvent} */
function InputGamepadRumbleEvent(_strength, _bias, _duration, _force = false) constructor {
	
	
	#region Private
		///@ignore
		strength = 0;											//How strong the event should be at its peak
		///@ignore
		bias = 0;												//Left/Right motor bias
		///@ignore
		duration = 0;											//Duration of the event in milliseconds
		///@ignore
		force = _force;											//If "vibration paused" should be ignored
		///@ignore
		motorStrength = undefined;								//A 2D vector where x represents left motor strength and y represents right motor strength
		///@ignore
		magnitude = undefined;									//2D Vector containing finalized left/right motor values.
		///@ignore
		time = 0;												//The amount of time spent vibrating
		///@ignore
		finished = false;										//True if this component still has vibrations to apply
		
		
	#endregion
	
	/** Evaluates the magnitude of this vibrator component. At somepoint during the execution of this method, it must set the variable `magnitude` to a `Vector2`. If not set correctly, this event will fail and throw an error for a malformed variable when the system tries to evaluate it.
	 * @return {Undefined} */
	static EvaluateMagnitude = function() {
		ThrowMethodNotImplemented("EvaluateMagnitude");
	}	
	
	/** Sets the peak strength of the rumble event.
	 * @arg {Real} _strength A value from 0 to 1
	 * @return {Undefined} */ 
	static SetStrength = function(_strength) {
		AssertIsNumeric(_strength, $"Invalid strength");
		strength = clamp(_strength, 0, 1);
	}
	
	/** Returns the peak strength of this event with is a value ranging from `0` to `1`.
	 * @return {Real} */
	static GetStrength = function() {
		return strength;
	}
	
	/** Set the left right motor activation bias.
	 * @arg {Real} _bias A value ranging from `-1` to `1` where -1 indicates left motor activation only and 1 indicates right motor activation only.
	 * @return {Undefined} */
	static SetBias = function(_bias) {
		AssertIsNumeric(_bias, "Invalid left/right motor bias");
		bias = clamp(_bias, -1, 1);
	}
	
	/** Returns the left/right motor activation bias ranging from `-1` to `1` where -1 indicates left motor activation only and 1 indicates right motor activation only.
	 * @return {Real} */
	static GetBias = function() {
		return bias;
	}	
	
	/** Set the duration of the event
	 * @arg {Real} _duration In milliseconds
	 * @return {Undefined} */
	static SetDuration = function(_duration) {
		AssertIsNumeric(_duration, "Invalid duration");
		duration = max(0, _duration);
	}
	
	/** Returns the duration of this event in milliseconds.
	 * @return {Real} */
	static GetDuration = function() {
		return duration;
	}
	
	/** Returns the biased strength of the left and right motors. The return value is a `Vector2` where the `X` component represents the biased strength of the left motor, and the `Y` component represents the biased strength of the right motor.
	 * @return {Struct.Vector2} */
	static GetBiasedMotorStrength = function() {
		if (is_undefined(motorStrength)) {
			var _bias = GetBias();
			var _left = strength*clamp(1 - _bias, 0, 1);
			var _right = strength*clamp(1 + _bias, 0, 1);	
			motorStrength = new Vector2(_left, _right);
		}
		return motorStrength;
	}
	
	/** Returns the magnitude of this event as evaluated by your redefined `EvaluateMagnitude()` method. The evaluated magnitude is an instance of `Vector2` where the `X` component represents the magnitude of the left motor and the `Y` component represents the magnitude of the right motor.
	 * @return {Struct.Vector2} */
	static GetEvaluatedMagnitude = function() {
		return magnitude;
	}
	
	/** Returns `true` if this rumble event has no remaining duration.
	 * @return {Bool} */
	static IsFinished = function() {
		return finished;
	}
	
	/** Returns `true` if this is a forced event, meaning this event is always evaluated by the rumble system regardless of any intrinsic or extrinsic rumble state. 
	 * @return {Bool} */
	static GetForced = function() {
		return force;
	}
	
	/** This method updates the event duration then evaluates its magnitude according to its `EvaluateMagnitude()` method.
	 * @return {Undefined} */
	static Update = function() {
		var _timeDiff = delta_time/1000;
		time += _timeDiff;
		EvaluateMagnitude();
		finished = !(time < duration);
	}
	
	
	SetStrength(_strength);
	SetDuration(_duration);
	SetBias(_bias);
	
}