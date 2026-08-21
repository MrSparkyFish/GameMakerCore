//feather ignore all

/** Helper struct that holds the minimum and maximum x position of a curve
 * @return {Struct.NumericalRange} */
function NumericalRange(minimum = 0, maximum = 1) constructor {
	///@ignore The minimum value of this range
	self.minimum = undefined;
	
	///@ignore The maximum value of this range
	self.maximum = undefined;
	
	Set(minimum, maximum);
	
	/** Set the upper and lower limits of this range
	 * @arg {Real} minimum The minimum time range
	 * @arg {Real} maximum The maximum time range
	 * @return {Undefined} */
	static Set = function(minimum, maximum) {
		if (!is_numeric(minimum)) {
			ThrowInvalidType("Set", "minimum", minimum, "Real");
		}
		if (!is_numeric(maximum)) {
			ThrowInvalidType("Set", "maximum", maximum, "Real");
		}
		self.minimum = min(minimum, maximum);
		self.maximum = max(minimum, maximum);
	}
	
	/** Returns the value `t` normalized to the bounds defined by this range
	 * @arg {Real} t The value to normalize
	 * @return {Real} */
	static GetValueNormalized = function(t) {
		return MathNormalize(t, minimum, maximum);
	}
	
	/** Returns the value `t` clamped to this `NumericalRange`
	 * @arg {Real} t The value to clamp
	 * @return {Real} */
	static ClampValue = function(t) {
		return clamp(t, minimum, maximum);
	}
	
	/** Returns the lower limit of this numerical range
	 * @return {Real} */
	static GetMinimum = function() {
		INLINE;
		return minimum;
	}
	
	/** Returns the upper limit of this numerical range
	 * @return {Real} */
	static GetMaximum = function() {
		INLINE;
		return maximum;
	}
}