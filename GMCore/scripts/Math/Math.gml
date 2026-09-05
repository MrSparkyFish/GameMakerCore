//feather ignore all

//Some quick macros for values that get used a lot in conversions
#macro ONE_MILLION 		1000000
#macro ONE_BILLION 		1000000000   
#macro ONE_MILLIONTH	0.000001
#macro ONE_BILLIONTH	0.000000001


/** Returns the input value clamped between `0` and `1`
 * @pure
 * @arg {Real} n
 * @return {Real} */
function MathClamp01(n) {
	return clamp(n, 0, 1);
}

/** Rounds the given value up to an even number
 * @pure
 * @arg {Real} _value The value to make even
 * @return {Real} */
function MathMakeEven(_value) {
	return (_value % 2 == 0) ? _value : _value + 1;
}

/** Returns true is the provided value is even or false if it's odd. A value of 0 returns true.
 * @pure
 * @arg {Real} _value The value to check
 * @return {Bool} */
function MathIsEven(_value) {
	return ((_value % 2) == 0);
}

/**Returns true if the argument number is negative or false if it isn't.
 * @pure
 * @arg {Real} _value The value to check.
 * @return {Bool} */
function MathIsNegative(_value) {
	return (sign(_value) == -1) ? true : false;
}

/**Returns true if the argument number is positive or false if it isn't
 * @pure
 * @arg {Real} _value The value to check.
 * @return {Bool} */
function MathIsPositive(_value) {
	return (sign(_value) == 1) ? true : false;
}

/**Returns true if the argument number is zero or false if it isn't
 * @pure
 * @arg {Real} _value The value to check.
 * @return {Bool} */
function MathIsZero(_value) {
	return (sign(_value) == 0) ? true : false;
}

/** Returns true if the argument value is less than the top value and greater than the bottom value (doesn't test for equal to).
 * @pure
 * @arg {Real} _value The value to test
 * @arg {Real} _bottom The bottom value to test against
 * @arg {Real} _top The top value to test against
 * @return {Bool} */
function MathIsBetween(_value, _bottom, _top) {
	return ((_value < _top) && (_value > _bottom));
}

/** Returns true if the argument value is less than or equal to the top value and greater than or equal to the bottom value.
 * @pure
 * @arg {Real} _value The value to test
 * @arg {Real} _bottom The bottom value to test against
 * @arg {Real} _top The top value to test against
 * @return {Bool} */
function MathIsBetweenEquals(_value, _bottom, _top) {
	return ((_value <= _top) && (_value >= _bottom));
}


/** Takes a value from a range of values and returns its unclamped normal. Returns an infinite value if (`_min` == `_max`);
 * @pure
 * @arg {Real} _value The value to normalize
 * @arg {Real} _min The minimum range value
 * @arg {Real} _max The maximum range value
 * @return {Undefined} */
function MathNormalize(_value, _min, _max) {
	if (_min == 0) {
		return _value/_max;
	}
	
	else {
		if (_min == _max) {
			return sign(_value) * infinity;
		}
		return (_value - _min) / (_max - _min);
	}	
}

/** Normalizes a value and clamps between 0 and 1.
 * @pure
 * @arg {Real} _value The value to normalize
 * @arg {Real} _min The minimum range value
 * @arg {Real} _max The maximum range value
 * @return {Real} */
function MathLinear(_value, _min, _max) {
	return MathClamp01(MathNormalize(_value, _min, _max));
}

/** Returns the cubic interpolation of a value.
 * @pure
 * @arg {Real} _a The minimum value in range
 * @arg {Real} _b The maximum value in range
 * @arg {Real} _x The value to interpolate
 * @return {Real} */
function MathSmoothstep(_a, _b, _x) {
	var t = MathLinear(_x, _a, _b);
	return (t*t * (3 - (2 * t)));
}

/** Returns the quintic interpolation of a value. Similar to `Smoothstep` but generally more accurate at slightly higher cost.
 * @pure
 * @arg {Real} _a First point
 * @arg {Real} _b Second point
 * @arg {Real} _x The value to interpolate
 * @return {Real} */
function MathSmootherstep(_a, _b, _x) {
	
	var t = MathLinear(_a, _b, _x);
	return ((((6.0*t) - 15.0)*t) + 10.0)*t*t*t;
	
}

/** Returns 0. Useful as a generic placeholder function for niche situations
 * @pure
 * @return {Real} */
function MathReturnNull() {
	return 0;
}

/** Normalizes an angle so that it is between `0` and `360` degrees
 * @pure
 * @arg {Real} angle The angle to normalize (in degrees)
 * @return {Real} */
function MathNormalizeAngle(angle) {
	var _angle = angle % 360;
	if (_angle < 0) {
		return _angle + 360;
	}
	else {
		return _angle;
	}
}

/** Modifies a series of XYZ angles so that they are between `-180` and ``180` degrees
 * @pure
 * @arg {Real} _angle The angles to normalize
 * @return {Real} */
function MathNormalizeHalfAngle(_angle) {
	return (abs(_angle) == 180) ? _angle : (_angle % 360) - 180;
}

/** Modifies a series of XYZ angles so that they are between `-180` and `180` degrees
 * @arg {Struct.Vector3} _outAngles The angles to normalize
 * @return {Struct.Vector3} */
function MathNormalizeHalfAngles(_outAngles) {
	_outAngles.x = MathNormalizeHalfAngle(_outAngles.x);
	_outAngles.y = MathNormalizeHalfAngle(_outAngles.y);
	_outAngles.z = MathNormalizeHalfAngle(_outAngles.z);
	return _outAngles;
}

/** Returns `true` if two values are approximately equal to each other
 * ***
 * This function is inteded to save time by avoiding repetitive calls to GM's built-in `math_set_epsilon()` function. Use this function when you need 
 * to do a comparison check using many different epsilon values. Of course, if you have many comparison ops that all require the same epsilon, it would
 * still be better to call `math_set_epsilon()` to change the global epsilon, then reset the value when you're finished using it.
 * @pure
 * @arg {Real} a First value
 * @arg {Real} b Compare value
 * @arg {Real} epsilon `[=0.00001]` The maximum permissible difference between the two numbers to consider them "equal".
 * @return {Bool} */
function MathEqualToApproximate(a, b, epsilon = 0.00001) {
	return (abs(a) - abs(b)) <= epsilon;
}

/** Reset the global epsilon value to GameMaker's default value.
 * @return {Undefined} */
function MathResetEpsilon() {
	math_set_epsilon(0.00001)
}


#region Unit Conversion
	/** Convert a base unit value to milli unit value (bE-3)
	 * @pure
	 * @arg {Real} b The value to convert
	 * @return {Real} */
	function MathDivideOneThousand(b) {
		///@ignore faster to multiply
		return b*0.001;
	}	
	
	/** Convert a base unit value to micro unit value (bE-6)
	 * @pure
	 * @arg {Real} b The value to convert
	 * @return {Real} */
	function MathDivideOneMillion(b) {
		///@ignore faster to multiply
		return b*0.000001;
	}
	
	/** Convert a base unit value to micro unit value (bE-9)
	 * @pure
	 * @arg {Real} b The value to convert
	 * @return {Real} */	
	function MathDivideOneBillion(b) {
		///@ignore faster to multiply
		return b*0.000000001;
	}
	
	/** Convert a base unit value to a Kilo unit value (bE3)
	 * @pure
	 * @arg {Real} b The value to convert
	 * @return {Real} */
	function MathMultiplyOneThousand(b) {
		return b*1000;
	}	
	
	/** Convert a base unit value to a Mega unit value (bE6)
	 * @pure
	 * @arg {Real} b The value to convert
	 * @arg {Real} */
	function MathMultiplyOneMillion(b) {
		return b*1000000;
	}
	
	/** Convert a base unit value to a Giga unit value (bE9)
	 * @pure
	 * @arg {Real} b The value to convert
	 * @arg {Real} */
	function MathMultiplyOneBillion(b) {
		return b*1000000000;
	}
#endregion