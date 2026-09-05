//feather ignore all

/** InputGamepadRumbleEventADSR: This rumble event vibrates a gamepad on an *Attack-Decay-Sustain-Release* curve.
 * @arg {Real} _strength Peak strength of the vibration event at the top of the attack portion of the curve from 0 to 1
 * @arg {Real} _sustainLevel Strength of the sustain portion of the curve relative to the attack portion from 0 to 1
 * @arg {Real} _bias Left-to-right motor bias for the vibration event where -1 only vibrates the left motor and 1 only vibrates the right motor
 * @arg {Real} _attack Duration of the attack portion of the curve (milliseconds)
 * @arg {Real} _decay Duration of the decay portion of the curve (milliseconds)
 * @arg {Real} _sustain Duration of the sustain portion of the curve (milliseconds)
 * @arg {Real} _release Duration of the release portion of the curve (milliseconds)
 * @arg {Bool} [_force] `[=false]` Whether this vibration event should ignore "vibration paused" state of the gamepad.  
 * @return {Struct.InputGamepadRumbleEventADSR} */
function InputGamepadRumbleEventADSR(_strength, _sustainLevel, _bias, _attack, _decay, _sustain, _release, _force = false) : InputGamepadRumbleEvent(_strength, _bias, 0, _force) constructor {
	
	enum Input_VibratePhaseADSR {
		attack,
		decay,
		sustain,
		release
	}
	
	
	_sustainLevel = clamp(_sustainLevel, 0, 1);
	_attack = max(_attack, 0);
	_decay = max(_attack, 0);
	_sustain = max(_sustain, 0);
	_release = max(_release, 0);
	
	
	#region Private
		///@ignore
		sustainLevel = _sustainLevel;									//Strength of the sustain relative to the peak
		///@ignore
		attack = _attack;												//Duration of the attack 
		///@ignore
		decay = _decay;													//Duration of the decay
		///@ignore
		sustain = _sustain;												//Duration of the sustain
		///@ignore
		release = _release												//Duration of the release
		///@ignore
		duration = attack + decay + sustain + release;					//Total duration of the event
		///@ignore
		phase = Input_VibratePhaseADSR.attack;							//Indicates which phase of the curve we're in
		
		
		SetDuration(attack + decay + sustain + release);
	#endregion
	
	
	/** Evaluates the magnitude of this vibrator component.
	 * @return {Undefined} */	
	static EvaluateMagnitude = function(_left, _right) {
		var _min = 0;
		var _max = 0;
		var _phaseTime = infinity
		switch(phase) {
			case Input_VibratePhaseADSR.attack:
				_min = 0;
				_max = 1;
				_phaseTime = attack;
			break;
			
			case Input_VibratePhaseADSR.decay:
				_min = 1;
				_max = sustainLevel;
				_phaseTime = decay;
			break;
			
			case Input_VibratePhaseADSR.sustain:
				_min = sustainLevel;
				_max = sustainLevel;
				_phaseTime = sustain;
			break;
			
			case Input_VibratePhaseADSR.release:
				_min = sustainLevel;
				_max = 0;
				_phaseTime = release;
			break;
		}
		
		magnitude = GetBiasedMotorStrength().Multiply(lerp(_min, _max, clamp(time/duration, 0, 1)));
		time += delta_time/1000;
		if (time > _phaseTime) {
			time -= _phaseTime;
			phase++;
		}
	}
	
}