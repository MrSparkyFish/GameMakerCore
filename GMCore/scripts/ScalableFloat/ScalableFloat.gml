 //feather ignore all

/** A type of float that uses a backing curve.
 * @arg {Real} [initValue] `[=0]` Initial value of the float. This value changes as the level of the float changes.
 * @return {Struct.ScalableFloat} */
function ScalableFloat(initValue = 0) : ModifiableFloat(initValue) constructor {
	
	///@ignore The curve that we use to evaluate this float.
	curve = undefined;
	
	///@ignore The current float level.
	level = 0;	
	
	///@ignore The minimum and maximum levels of this float.
	range = new NumericalRange();
	
	/** Sets the base value of this float when no modifiers are applied, then update the current float value.
	 * @arg {Real} newValue The new base value to set
	 * @return {Undefined} */
	static SetBaseValue = function(newValue) {
		INLINE;
		ModifiableFloat.SetBaseValue(newValue);
		UpdateFloat()
	}
	
	/** Set the minimum and maximum level range for this float
	 * @arg {Real} minLevel The minimum level of this float
	 * @arg {Real} maxLevel The maximum level of this float
	 * @return {Undefined} */
	static SetRange = function(minLevel, maxLevel) {
		INLINE;
		range.Set(minLevel, maxLevel);
		UpdateFloat();
	}
	
	/** Sets the curve to use when calculating value. Remember to call `UpdateFloat()` for the change to be reflected in the actual value of this float.
	 * @arg {Asset.AnimCurve} animCurve The curve to set
	 * @arg {String|Real} channelId The name of the curve channel from the anim curve that should be used to evaluate this float.
	 * @return {Undefined} */
	static SetCurve = function(animCurve, channelId) {
		INLINE;
		curve = animcurve_get_channel(animCurve, channelId);
		UpdateFloat();
	}
	
	/** Set the float level which changes the value of the float.
	 * @arg {Real} level The new level to set.
	 * @return {Undefined} */
	static SetLevel = function(level) {
		INLINE;
		self.level = range.ClampValue(level);
		UpdateFloat();
	}
	
	/** Returns the current level of this float
	 * @return {Real} */
	static GetLevel = function() {
		INLINE;
		return level; 
	}
	
	/** Returns the value of this float multiplied with the curve at the specified curve level.
	 * @arg {Real} lvl The level to get the float at
	 * @return {Bool} */	
	static GetValueAtLevel = function(lvl) {
		var value = GetBaseValue();
		if (!is_undefined(curve)) {
			value *= animcurve_channel_evaluate(curve, range.GetValueNormalized(lvl));
		}
		//No curve exists, so return the base value
		return value;
	}
	
	/** Call to update this float when you modify its internals.
	 * @return {Undefined} */
	static UpdateFloat = function() {
		if (!is_undefined(curve)) {
			SetValue(GetValueAtLevel(GetLevel()));
		}
		//No curve, so use base value
		else {
			SetValue(GetBaseValue());
		}
	}	
}