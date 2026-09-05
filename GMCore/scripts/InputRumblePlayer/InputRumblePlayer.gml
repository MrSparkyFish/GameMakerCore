//feather ignore all

/** InputVibratePlayer: Represents player gamepad rumble/vibration settings. Each InputVibratePlayer is associated with a specific InputPlayer
 * @arg {Real} _playerIndex The index of the player this represents
 * @return {Struct.InputVibratePlayer} */
function InputRumblePlayer(_playerIndex) constructor {
	
	enum Input_VibratePlayerFlags {
		enabled,
		paused,
	}
	
	#region Private
		///@ignore
		index = _playerIndex;													//The index of the player this represents in the InputRumbleSystem and InputSystem
		///@ignore
		strength = INPUT_VIBRATION_DEFAULT_STRENGTH;							//Player specific modifier for gamepad motor strength
		///@ignore
		flags = new BitMask();													//Tracks our flag states
		///@ignore
		rumbleEvents = [];														//Array of rumble events assigned to this player
		
	#endregion
	
	/** Adds an instance of `InputGamepadRumbleEvent` to this vibrator
	 * @arg {Struct.InputGamepadRumbleEvent} _rumbleEvent The rumbleEvent to add
	 * @return {Undefined} */
	static AddRumbleEvent = function(_rumbleEvent) {
		if (!is_instanceof(_rumbleEvent, InputGamepadRumbleEvent)) {
			return;
		}
		array_push(rumbleEvents, _rumbleEvent);
	}
	
	/** Removes an instance of `InputGamepadRumbleEvent` from this vibrator. Returns `true` if the component was successfully found and removed. 
	 * @arg {Struct.InputVibratorComponent} _rumbleEvent The rumbleEvent to remove	
	 * @return {Bool} */
	static RemoveRumbleEvent = function(_rumbleEvent) {
		return ArrayRemove(_rumbleEvent);
	}
	
	/** Removes all rumble events from this player effectively stopping all rumbling for their assigned gamepad
	 * @return {Undefined} */
	static RemoveAllRumbleEvents = function() {
		rumbleEvents = [];
	}		
	
	/** Returns an array containing all rumbled events targeting this player
	 * @return {Array<StructInputGamepadRumbleEvent>} */
	static GetRumbleEvents = function() {
		return rumbleEvents;
	}
	
	/** Set the vibration strength for this player. Strength should be a value between 0 (never vibrate) and 1 (full strength).
	 * @arg {Real} _strength The value to set for vibration intensity
	 * @return {Undefined} */
	static SetStrength = function(_strength) {
		strength = clamp(_strength, 0, 1);
	}
	
	/** Returns the vibration intensity set for this player. The return value will be between 0 and 1.
	 * @return {Real} */
	static GetStrength = function() {
		return strength;
	}
	
	/** Returns `true` if vibration is paused for this player
	 * @return {Bool} */
	static IsPaused = function() {
		return flags.IsBitActive(Input_VibratePlayerFlags.paused);
	}
	
	/** Set if vibration should be paused for this player
	 * @arg {Bool} _bool Set `true` to pause vibration. Set `false` to resume vibration
	 * @return {Undefined} */
	static SetPaused = function(_bool) {
		flags.SetBitState(Input_VibratePlayerFlags.paused, _bool);
	}
	
	/** Returns `true` if this player has vibration enabled
	 * @return {Bool} */
	static IsEnabled = function() {
		return flags.IsBitActive(Input_VibratePlayerFlags.enabled);
	}
	
	/** Set if gamepad vibration should be enabled for this player
	 * @arg {Bool} _bool Set `true` to enable vibration, set `false` to disable it
	 * @return {Undefined} */
	static SetEnabled = function(_bool) {
		flags.SetBitState(Input_VibratePlayerFlags.enabled, _bool);
	}
	
}