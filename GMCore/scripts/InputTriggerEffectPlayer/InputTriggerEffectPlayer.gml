//feather ignore all

/** InputTriggerEffectPlayer: This is a data object used to store and manipulate player specific settings regarding PS5 gamepad trigger effects.
 * @arg {Real} _playerIndex The player index this profile represents
 * @return {STruct.InputTriggerEffectPlayer} */
function InputTriggerEffectPlayer(_playerIndex) constructor {
	
	
	#region Private
		
		enum Input_TriggerPlayerFlags {
			leftIntercept,
			rightIntercept,
			paused
		}
		
		
		index = _playerIndex;
		strength = INPUT_TRIGGER_EFFECT_DEFAULT_STRENGTH;
		effectLeft = undefined;
		effectRight = undefined;
		flags = new BitMask();
		
		
	#endregion
	
	/** Returns `true` if this player's effect for the left trigger has been intercepted
	 * @return {Bool} */
	static IsInterceptedLeft = function() {
		return flags.IsBitActive(Input_TriggerPlayerFlags.leftIntercept);
	}
	
	/** Returns `true` if this player's effect for the right trigger has been intercepted
	 * @return {Bool} */
	static IsInterceptedRight = function() {
		return flags.IsBitActive(Input_TriggerPlayerFlags.rightIntercept);
	}
	
	/** Sets the trigger effect for a shoulder button
	 * @arg {Constant.GamepadButton} _button A gamepad shoulder lb/rb button
	 * @arg {Struct.InputGamepadTriggerEffect} _effect The effect to set
	 * @arg {Bool} _applied If the effect was applied to the player's gamepad.
	 * @return {Undefined} */
	static SetEffect = function(_button, _effect, _applied) {
		var _intercepted = !_applied;
		switch(_button) {
			case gp_shoulderlb:
				effectLeft = _effect;
				flags.SetBitState(Input_TriggerPlayerFlags.leftIntercept, _intercepted);
			break;
			
			
			case gp_shoulderrb:
				effectRight = _effect;
				flags.SetBitState(Input_TriggerPlayerFlags.rightIntercept, _intercepted);
			break;
		}		
	}	
	
	/** Returns the current state of the player. This value will be one of the `STATE_*` macros
	 * @return {Constant.STATE} */
	static IsPaused = function() {
		return flags.IsBitActive(Input_TriggerPlayerFlags.paused);
	}
	
	/** Set the player's state to paused or unpaused (active)
	 * @arg {Bool} _pause Set `true` to pause or `false` to unpause
	 * @return {Undefined} */
	static SetPaused = function(_pause) {
		flags.SetBitState(Input_TriggerPlayerFlags.paused, _pause);
	}	
	
	/** Returns the currently set strength value to use for trigger effects that are applied to the gamepad used by this player.
	 * @return {Undefined} */
	static GetStrength = function() {
		return strength;
	}
	
	/** Sets the value of strength for this player which ultimately decides the final strength of the trigger effects applied to them.
	 * @arg {Real} _strength A value from `0` to `1`.
	 * @return {Undefined} */
	static SetStrength = function(_strength) {
		strength = clamp(_strength, 0, 1);
	}
	
	/** Returns the left or right effect used by this player
	 * @arg {Bool} _left Set `true` to get the left effect, or set `false` to get the right effect
	 * @return {Struct.InputGamepadTriggerEffect} */
	static GetEffect = function(_left) {
		return (_left) ? effectLeft : effectRight;
	}
	
}