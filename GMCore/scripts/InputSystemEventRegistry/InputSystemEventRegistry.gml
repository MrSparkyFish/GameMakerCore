//feather ignore all
 
/** InputSystemEventRegistry: Encapsulates all events available to the `InputSystem`
 * @return {Struct.InputSystemEventRegistry} */
function InputSystemEventRegistry() constructor {
	///@ignore Executed when a collection event occurs
	onCollect = new InputOnCollect();
	
	///@ignore Executed when a collect player event occurs
	onCollectPlayer = new InputOnCollectPlayer();
	
	///@ignore Executed when this system is updated
	onUpdate = new InputOnUpdate();
	
	///@ignore Executed when a hotswap is detected
	onHotswap = new InputOnHotswap();
	
	///@ignore Executed when a gamepad is disconnected
	onGamepadDisconnected = new InputOnGamepadDisconnected();
	
	///@ignore Executed when a gamepad is connected
	onGamepadConnected = new InputOnGamepadConnected();
	
	///@ignore Executed when a player device changed
	onPlayerDeviceChanged = new InputOnPlayerDeviceChanged();
	
	///@ignore Executed when a player's input is updated
	onPlayerUpdate = new InputOnPlayerUpdate();
	
	///@ignore Executed when the game loses focus
	onFocusLost = new InputOnFocusLost();
	
	///@ignore Executed when the game regains focus
	onFocusGained = new InputOnFocusGained();
	
	///@ignore Executed when the game is restarted
	onSystemRestart = new InputOnSystemRestart();
	
	///@ignore Executed when attempting to rebind inputs
	onFindBindingCollisions = new InputOnFindBindingCollisions();
	
	
	/** Returns the `MulticastAction` representing the Collect event.
	 * @return {Struct.InputOnCollect} */
	static GetOnCollect = function() {
		return onCollect;
	}
	
	/** Returns the `MulticastAction` representing the CollectPlayer event.
	 * @return {Struct.InputOnCollectPlayer} */	
	static GetOnCollectPlayer = function() {
		return onCollectPlayer;
	}
	
	/** Returns the `MulticastAction` representing the Update event.
	 * @return {Struct.InputOnUpdate} */	
	static GetOnUpdate = function() {
		return onUpdate;
	}
	
	/** Returns the `MulticastAction` representing the Hotswap event.
	 * @return {Struct.InputOnHotswap} */	
	static GetOnHotswap = function() {
		return onHotswap;
	}
	
	/** Returns the `MulticastAction` representing the GamepadDisconnected event.
	 * @return {Struct.InputOnGamepadDisconnected} */	
	static GetOnGamepadDisconnected = function() {
		return onGamepadDisconnected;
	}
	
	/** Returns the `MulticastAction` representing the GamepadConnected event.
	 * @return {Struct.InputOnGamepadConnected} */	
	static GetOnGamepadConnected = function() {
		return onGamepadConnected;
	}
	
	/** Returns the `MulticastAction` representing the PlayerDeviceChanged event.
	 * @return {Struct.InputOnPlayerDeviceChanged} */	
	static GetOnPlayerDeviceChanged = function() {
		return onPlayerDeviceChanged;
	}
	
	/** Returns the `MulticastAction` representing the PlayerUpdate event.
	 * @return {Struct.InputOnPlayerUpdate} */	
	static GetOnPlayerUpdate = function() {
		return onPlayerUpdate;
	}
	
	/** Returns the `MulticastAction` representing the FocusLost event.
	 * @return {Struct.InputOnFocusLost} */	
	static GetOnFocusLost = function() {
		return onFocusLost;
	}
	
	/** Returns the `MulticastAction` representing the FocusGained event.
	 * @return {Struct.InputOnFocusGained} */	
	static GetOnFocusGained = function() {
		return onFocusGained;
	}
	
	/** Returns the `MulticastAction` representing the SystemRestart event.
	 * @return {Struct.InputOnSystemRestart} */	
	static GetOnSystemRestart = function() {
		return onSystemRestart;
	}
	
	/** Returns the `MulticastAction` representing the FindBindingCollisions event.
	 * @return {Struct.InputOnFindBindingCollisions} */	
	static GetOnFindBindingCollisions = function() {
		return onFindBindingCollisions;
	}
}