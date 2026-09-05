//feather ignore all

/** InputTriggerEffectData: This is a generalized data struct used to store trigger effect information when passing data to Steam.
 * @arg {Real} _strength The strength of the effect applied from `0` to `1`. 
 * @arg {Real} _amplitude The amplitude of the effect if the effect comes in waves
 * @arg {Real} _frequency The frequency of the effec tif the effect comes in waves
 * @arg {Real} _position The position within the trigger axis where the effect should begin. Should be a value from `0` to `1`.
 * @arg {Real} _startPosition Where on the trigger axis the effect should start begin`0` to `1` (the break point)
 * @arg {Real} _endPosition Where on the trigger axis the effect should stop applying from `0` to `1` (the release point)
 * @return {Struct.InputGamepadTriggerEffectData} */
function InputGamepadTriggerEffectData(_strength = 0, _amplitude = 0, _frequency = 0, _position = 0, _startPosition = 0, _endPosition = 0) constructor {
	
	var _start = _startPosition * 10;
	var _end = _endPosition * 10;
	_strength = clamp(_strength * 8, 0, 8);
	_amplitude = clamp(_amplitude * 8, 0, 8);
	_frequency = clamp(_frequency * 255, 0, 255);
	_position = clamp(_position * 10, 0, 9);
	_startPosition = clamp(_start, 2, 7);
	_endPosition = clamp(_end, max(_end, _start), 8);
	
	
	strength = _strength;
	amplitude = _amplitude;
	frequency = _frequency;
	position = _position;
	startPosition = _startPosition;
	endPosition = _endPosition;
	
	
	/** Modifies the effect's amplitude and strength by multiplying them with the provided coefficient
	 * @arg {Real} _coefficient The value to multiply amplitude and strength by
	 * @return {Undefined} */
	static Modify = function(_coefficient) {
		amplitude *= _coefficient;
		strength *= _coefficient;
	}
	
	/** Returns the strength of the trigger effect
	 * @return {Real} */
	static GetStrength = function() {
		return strength;
	}
	
	/** Returns the amplitude of the trigger effect
	 * @return {Real} */	
	static GetAmplitude = function() {
		return amplitude;
	}
	
	/** Returns the frequency of the trigger effect
	 * @return {Real} */	
	static GetFrequency = function() {
		return frequency;
	}
	
	/** Returns the position value of the trigger effect
	 * @return {Real} */	
	static GetPosition = function() {
		return position;
	}
	
	/** Returns the starting break point value of the trigger effect
	 * @return {Real} */	
	static GetStartPosition = function() {
		return startPosition;
	}
	
	/** Returns the release end point value of the trigger effect
	 * @return {Real} */	
	static GetEndPosition = function() {
		return endPosition;
	}
}