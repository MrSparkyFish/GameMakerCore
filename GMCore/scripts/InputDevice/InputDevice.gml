//feather ignore all

/** InputDevice: A device represents the physical controller type being used by the player. Devices are responsible for checking verbs to see if they have input values or not. Only the `InputSystem` should use devices.
 * @return {Struct.InputDevice} */
function InputDevice() constructor {
	
	//TODO: Region -> Checking Input. From InputDeviceCheckViaPlayer api function
	
	//Device flags
	enum Input_DeviceFlags {
		xinput,																	//This is an xInput device
		active,																	//This device is actively in use by the player
		available,																//This device is available to be connected to the system
		blocked,																//This device is blocked by the system
		blockedByUser,															//This device is blocked by the user
		blockedThisFrame,														//This device is blocked for the current frame
		blockedByWindowDefocus,													//This device is blocked due to game defocus
		blockedBySystem,														//This device is blocked by the `InputSystem`
	}
	 
	//Represents the type of device
	enum Input_DeviceType {
		kbm,																	//This device is a keyboard and mouse
		gamepad,																//This device is a gamepad
		touch,																	//This device is a touch device
		generic,																//This is a generic device
		none																	//This is only used for caching types and shouldn't be used for actual devices.
	} 
	
	//Denotes the type of button constants for certain functions
	enum Input_ButtonType {
		vk,																		//Indicates a keyboard button
		mb,																		//Indicates a mouse button
		gp																		//Indicates a gamepad button
	}
	
	
	#region Internal data
		///@ignore
		static inputSystem = InputSystem.singleton;
		///@ignore
		type = Input_DeviceType.none;											//The device type.
		///@ignore
		description = "Unknown Device";											//The description of the device		
		///@ignore
		flags = new BitMask();													//Device flags
		///@ignore
		owner = undefined;														//The `InputPlayer` that owns this device
		///@ignore
		index = -1;																//Device index is required for native GameMaker and GameMaker to Steam functions 
		///@ignore
		lastConnectedTime = current_time;										//Timestamp of the last time this device was connected to the `InputSystem`
		///@ignore
		buttonMap = undefined;													//Map of buttons for this device. Used to check if particular buttons are pressed or not
		
		
		/** Helper function for converting keyboard button strings into keyboard button constants. Used in `SetRebindingIgnore()` and `SetRebindingAllow()`
		 * @ignore
		 * @arg {Array<Constant>} _array
		 * @return {Undefined} */
		static ConvertLettersToButtons = function(_array) {
			var _len = array_length(_array);
			var i = 0; repeat(_len) {
				var _binding = _array[i];
				if (is_string(_binding)) {
					_binding = ord(_binding);
					_array[i] = _binding;
				}
			}
			return _array;
		}
		
		
	#endregion
	
	
	#region Device Basics
		
		/** Returns the `InputPlayer` who owns this device. Returns `undefined` if this device has no owner.
		 * @return {Struct.InputPlayer} */
		static GetOwner = function() {
			return owner;
		}
		
		/** Returns `true` if the specified button constant is available in the device's button map. 
		 * @arg {Constant.InputButton} _button The button constant to check. Should be any of the `vk_*`, `mb_*`, or `gp_*` buttons.
		 * @return {Real} */
		static ValidateButton = function(_button) {
			return (!is_undefined(StructTryGetMember(buttonMap, _button)));
		}
		
		/** Set the owner of this device. If this device should have no owner, ignore the `_player` argument or set it to `undefined`.
		 * @arg {Struct.InputPlayer} _player The player who should own this device
		 * @return {Undefined} */ 
		static SetOwner = function(_player) {
			if (!is_instanceof(_player, InputPlayer) && !is_undefined(_player)) {
				ThrowInvalidType("SetOwner", "_player", _player, "'Undefined' or 'InputPlayer'");
			}
			
			owner = _player;
		}
		
		/** Returns the description of this `InputDevice`
		 * @return {String} */
		static GetDescription = function() {
			return description;
		}
		
		/** Returns if this `InputDevice` is blocked by the user.
		 * @return {Bool} */
		static IsBlockedByUser = function() {
			return flags.IsBitActive(Input_DeviceFlags.blockedByUser);
		}
		
		/** Set if this `InputDevice` is being blocked by the user
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetBlockByUser = function(_bool) {
			flags.SetBitState(Input_DeviceFlags.blockedByUser, _bool);
		}
		
		/** Returns true if this `InputDevice` is being blocked by the `InputSystem`
		 * @return {Bool} */
		static IsBlockedBySystem = function() {
			return flags.IsBitActive(Input_DeviceFlags.blockedBySystem);
		}
		
		/** Set if this `InputDevice` is being blocked by the `InputSystem`.
		 * @arg {Bool} _bool
		 * @return {Undefined} */	
		static SetBlockBySystem = function(_bool) {
			flags.SetBitState(Input_DeviceFlags.blockedBySystem);
		}
		
		/** Returns `true` if this `InputDevice` is being blocked by for the current frame only
		 * @return {Bool} */		
		static IsBlockedThisFrame = function() {
			return flags.IsBitActive(Input_DeviceFlags.blockedThisFrame);
		}
		
		/** Set if this `InputDevice` is being blocked by the user for the current frame
		 * @arg {Bool} _bool
		 * @return {Undefined} */		
		static SetBlockThisFrame = function(_bool) {
			flags.SetBitState(Input_DeviceFlags.blockedThisFrame, _bool);
		}
		
		/** Returns `true` if this `InputDevice` is blocked due to the game window losing focus
		 * @return {Bool} */		
		static IsBlockedByWindowDefocus = function() {
			return flags.IsBitActive(Input_DeviceFlags.blockedByWindowDefocus);
		}
		
		/** Set if this `InputDevice` is being blocked due to the game window losing focus
		 * @arg {Bool} _bool
		 * @return {Undefined} */		
		static SetBlockByWindowDefocus = function(_bool) {
			flags.SetBitState(Input_DeviceFlags.blockedByWindowDefocus, _bool);
		}
		
		/** Returns `true` if this `InputDevice` is being prevented from detecting input
		 * @return {Bool} */
		static IsBlocked = function() {
			return flags.IsBitActive(Input_DeviceFlags.blocked);
		}
		
		/** Set if this `InputDevice` should be prevented from detecting input.
		 * @arg {Bool} _bool Set `true` to block the device or `false` to unblock it
		 * @return {Undefined} */
		static SetBlocked = function(_bool) {
			flags.SetBitState(Input_DeviceFlags.blocked, _bool);
		}
		
		/** Returns `true` if this `InputDevice` has not been assigned to a player and is available for use.
		 * @return {Bool} */
		static IsAvailable = function() {
			//Generic devices should be available (in case we need a placeholder device for example)
			return true;
		}
		
		/** Returns `true` if this `InputDevice` has detected any input activity
		 * @return {Undefined} */
		static IsActive = function() {
			//Generic devices should never be active
			return false;
		}
		
		/** Returns the timestamp that this `InputDevice` was last connected at
		 * @return {Real} */
		static GetLastConnectedTime = function() {
			return lastConnectedTime;
		}
		
		/** Updates the timestamp of the last time input was detected from this `InputDevice`.
		 * @return {Undefined} */
		static UpdateConnectedTime = function() {
			lastConnectedTime = current_time;
		}
		
		/** Returns the index of this `InputDevice`.
		 * @return {Real} */
		static GetIndex = function() {
			return index;
		}
		
		/** Returns the type of device this is.
		 * @return {Undefined} */
		static GetType = function() {
			return type;
		}
		
		/** Returns `true` if this `InputDevice` type matches the specified type
		 * @arg {Enum.Input_DeviceType} _type
		 * @return {Bool} */
		static IsType = function(_type) {
			return (type == _type);
		}
		
		/** Returns the specific gamepad type of this device. The return value is a member of `Input_GamepadType`. Generic devices that are not gamepads will always return `undefined`
		 * @return {Real} */
		static GetGamepadType = function() {
			return undefined;
		}
		
		/** Returns the button map of this device which is a struct of functions used to check if a particular button (one of the vk_*, mb_*, or gp_* constants) has been pressed or not. Returns `undefined` for devices that are not of type gamepad or kbm.
		 * @return {Struct} */
		static GetButtonMap = function() {
			return buttonMap;
		}
		
	#endregion
	
	
	#region Device Input
		
		/** Returns current "press" value of the specified button. Buttons will return either 0 or 1, while analog buttons will return their analog value.
		 * @arg {Constant} _button The button constant to check
		 * @return {Real} */
		static CheckButton = function(_button) {
			return 0;
		}
		
		/** Checks the "press" value of each provided button then returns the highest value.
		 * @arg {Array<Constant>} _buttons An array of buttons to check
		 * @return {Real} */
		static CheckButtonGroup = function(_buttons) {
			//Make sure we have an array.
			_buttons = ArrayConvertValue(_buttons);
			
			//Used to help us track/filter the press value for the highest value only
			var _highestValue = 0;
			var _currentValue = 0;
			
			//Get the value of each button in the array
			var i = 0; repeat(array_length(_buttons)) {
				_currentValue = CheckButton(_buttons[i++]);
				
				//Check if the current buttons value is the largest
				if (_currentValue > _highestValue) {
					_highestValue = _currentValue;
				}
			}
			return _highestValue;
		}
		
		/** Returns `true` if any button from the provided array are actively being depressed by the player
		 * @arg {Array<Constant>} _buttons The array of buttons to check
		 * @return {Bool} */
		static CheckButtonAny = function(_buttons) {
			_buttons = ArrayConvertValue(_buttons);
			
			var i = 0; repeat(array_length(_buttons)) {
				if (CheckButton(_buttons[i]) > 0) {
					return true;
				}
			}
			return false;
		}
		
		/** Returns the first input constant (*vk_, mb_, gp_* according to device type) that has an active input value. Returns `undefined` if no active input is detected or if the device is incapable of rebinding.
		 * @return {Constant} */
		static ScanBindings = function() {
			return undefined;
		}
		
		/** Returns `true` if this device is connected to the current platform, otherwise, returns `false`.
		 * @return {Bool} */
		static CheckPlatformConnection = function() {
				//Assume false
				var _bool = false;
				//Assign `_bool` according to type specific conditions
				switch (type) {
					case Input_DeviceType.gamepad:
						//Gamepads are not banned and device is inserted into a valid gamepad port
						if (!INPUT_BAN_GAMEPADS && (index >= 0)) {
							_bool = (!IsBlocked());
						}
					break;
					
					case Input_DeviceType.kbm:
						_bool = INPUT_BAN_KBM;
					break;
					
					case Input_DeviceType.touch:
						_bool = (!INPUT_BAN_TOUCH || (INPUT_ALLOW_TOUCH_ON_DESKTOP && INPUT_DESKTOP));
					break;
					case Input_DeviceType.generic:
						_bool = true;
					break;
				}
				return _bool;			
		}			
		
	#endregion
	
}