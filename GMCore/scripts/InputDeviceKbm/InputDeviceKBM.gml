//feather ignore all

/** InputDeviceKbm: Represents a keyboard and mouse input device.
 * @arg {Real} [_pointerIndex] `[=0]` The index of the pointer to use for mouse button checks
 * @return {Struct.InputDeviceKbm} */
function InputDeviceKbm(_pointerIndex = 0) : InputDevice() constructor {
	
	#region Internal
		///@ignore
		static mbList = [														//Array of buttons considered mouse buttons (excludes mouse wheel)
			mb_left, mb_middle, mb_right, mb_side1, mb_side2, mb_any
		];
		///@ignore	
		static mouseButtonCount = array_length(mbList);							//Cached number of mouse buttons for specific checks.
		///@ignore
		static prohibitedButtons = new InputProhibitedButtonBindingTable();		//Data table of button keycodes that devices are prohibited from detecting
		///@ignore
		type = Input_DeviceType.kbm;											//Device type for quick checks
		///@ignore
		index = _pointerIndex;													//The platform index for the mouse used by this KBM device. (For if the mouse should register touch)
		///@ignore
		buttonMap = new InputKbmBindingTable();									//The button map for kbm devices
		
		
		
		/** Returns true if the supplied key constant (or keycode) is a prohibited button binding.
		 * @ignore
		 * @return {Bool} */
		static IsButtonProhibited = function(_key) {
			if (is_undefined(_key)) {
				if (INPUT_LOG_WARNING) {
					LogWarning("InputDevice::IsButtonProhibited -> Invalid binding value. Cannot check prohibition.");
				}
				return true;
			}
			return struct_exists(prohibitedButtons, _key);
		}		
		
		/** Helper func to make `GetKeyboardOutput()` a little bit neater
		 * @ignore
		 * @return {Bool} */
		static CanGetKeyboardOutput = function() {
			var _bool = true;
			if (INPUT_BAN_KBM) {
				_bool = false;
			}
			else if (!keyboard_check(vk_anykey)) {
				_bool = false;
			}
			else if (!inputSystem.GameHasFocus()) {
				_bool = false;
			}
			return _bool;
		}			
		
		/** Helper func to make `GetMouseOutput()` a little bit neater
		 * @ignore
		 * @return {Bool} */
		static CanGetMouseOutput = function() {
			var _bool = true;
			if (INPUT_BAN_KBM) {
				_bool = false;
			}
			else if (INPUT_BLOCK_MOUSE_CHECKS) {
				_bool = false;
			}
			else if (!inputSystem.GameHasFocus()) {
				_bool = false;
			}
			else if (inputSystem.PointerIsBlockedByWindowDefocus()) {
				_bool = false;
			}
			return _bool;
		}
		
		/** Returns `true` if activity is detected for the mouse, otherwise returns `false`. Used for scanning for new bindings and is intended for specific mouse input and excludes touch.
		 * @ignore
		 * @return {Bool} */
		static IsMouseActive = function() {
			if (INPUT_BAN_KBM || INPUT_BLOCK_MOUSE_CHECKS || !inputSystem.GameHasFocus()) {
				return false;
			}
			
			if (INPUT_MOUSE_MOVEMENT_REPORTS_ACTIVE) {
				var _prevPos = inputSystem.PointerGetPreviousPosition();
				var _pos = inputSystem.PointerGetDevicePosition();
				if (_prevPos.Distance(_pos) > 3) {
					return true;
				}
			}
			
			if (INPUT_MOUSE_BUTTON_REPORTS_ACTIVE) {
				//Use general purpose function over device_* function to exclude touch devices, but still include touchpoints
				return CheckButton(mb_left);
			}
			return false;
		}
		
		/** Returns `true` if activity is detected for this particular device, otherwise returns `false`.  Used for scanning for new bindings.
		 * @ignore
		 * @return {Bool} */
		static IsKeyboardActive = function() {
			return (!is_undefined(GetKeyboardOutput()));
		}										
		
	#endregion
	
	
	#region Buttons
		/** Returns the value of a specific keyboard/mouse button for the current frame.
		 * @arg {Constant} _button The `mb_*` or `vk_*` button constant to check.
		 * @return {Real} */
		static CheckButton = function(_button) {
			var _value = 0;
			if (struct_exists(buttonMap, _button)) {
				_value = buttonMap[$ _button](_button);
			}
			return _value;
		}
		
		/** Checks and returns an extended button of this mouse to see if it is pressed or not. Use this method if you need to get the input value for a non-desktop mouse button (ie: TapClicks)
		 * @arg {Constant.MouseButton|Real} _binding
		 * @return {Bool} */
		static CheckExtendedMouseButton = function(_binding) {
			return device_mouse_check_button(index, _binding);
		}
		
		/** Checks and returns an extended button of this mouse to see if it is released or not. Use this method if you need to get the release value for a non-desktop mouse button (ie: TapClicks)
		 * @arg {Constant.MouseButton|Real} _binding
		 * @return {Bool} */
		static CheckExtendedMouseButtonReleased = function(_binding) {
			return device_mouse_check_button_released(index, _binding);
		}				
		
		/** Nullifies the binding map of a specific button for this device
		 * @arg {Constant.GamepadButton} _button
		 * @return {Undefined} */
		static ButtonNullifyMapping = function(_button) {
			buttonMap[$ _button] = MathReturnNull;
		}		
		
		/** Nullifies the button map of the device
		 * @return {Undefined} */
		static ButtonNullifyAllMappings = function() {
			var _buttons = struct_get_names(buttonMap);
			var _len = array_length(_buttons);
			var i = 0; repeat(_len) {
				ButtonNullifyMapping(_buttons[i++]);
			}
		}	
		
		/** Nullifies the button map of a group of buttons
		 * @arg {Array<Constant.KbmButton>} _constants
		 * @return {Undefined} */
		static ButtonNullifyMappingGroup = function(_constants) {
			var i = 0; repeat(array_length(_constants)) {
				var _button = _constants[i++];
				ButtonNullifyMapping(_button);
			}			
		}
		
		/** Resets a specific button map to the default map value
		 * @arg {Constant.KbmButton} _constant
		 * @return {Undefined} */ 
		static ButtonResetMap = function(_constant) {
			buttonMap[$ _constant] = inputSystem.GamepadGetDefaultButtonMap(_constant);
		}
		
		/** Resets a group of mapped gamepad buttons back to their default map values
		 * @arg {Array<Constant.KbmButton} _buttons
		 * @return {Undefined} */
		static ButtonResetMapGroup = function(_buttons) {
			var i = 0; repeat(array_length(_buttons)) {
				var _const = _buttons[i++];
				ButtonResetMap(_const);
			}
		}	
		
		/** Sets the button method for a button
		* @arg {Constant.KbmButton} _button The button being set
		* @arg {Function} _method The function to set
		* @return {Undefined} */
		static ButtonSetMap = function(_button, _method) {
			buttonMap[$ _button] = _method;
		}	
		
		/** Sets the button methods for a group of buttons
		 * @arg {Struct} _map A struct of button methods mapped to button constants
		 * @return {Undefined} */
		static ButtonSetMapGroup = function(_struct) {
			StructMerge(_struct, buttonMap);
		}	
		
		/** Returns the button binding constant for the first detected input from this device's assigned button map. Returns `undefined` if no button is found.  Used for scanning for new bindings.
		 * @return {Real} */		
		static GetKeyboardOutput = function() {
			if (CanGetKeyboardOutput()) {
				if (keyboard_key > 1) {
					return (IsButtonProhibited(keyboard_key)) ? undefined : keyboard_key;
				}
			}
		}
		
		/** Returns the button binding constant for the first detected input from this device's assigned button map. Returns `undefined` if no button is found. Used for scanning for new bindings.
		 * @return {Real} */	
		static GetMouseOutput = function() {
			if (CanGetMouseOutput()) {
				var _binding;
				if (INPUT_DESKTOP && (!INPUT_WEB)) {
					
					//Native desktop
					if (mouse_button != mb_none) {
						_binding = mouse_button;
					}
					
					else if (mouse_wheel_up()) {
						_binding = mb_wheel_up;
					}
					
					else if (mouse_wheel_down()) {
						_binding = mb_wheel_down;
					}
					
					//Laptop/trackpads
					else if (inputSystem.IsTapClick()) {
						_binding = mb_left;
					}
				}
				
				//web and non desktop mouse devices
				else {
					var i = 0; repeat (mouseButtonCount) {
						_binding = mbList[i++];
						if (CheckExtendedMouseButton(_binding)) {
							break;
						}
					}
				}
				return IsButtonProhibited(_binding) ? undefined : _binding;
			}
		}	
		
		/** Returns `true` if this `InputDevice` has detected any input activity
		 * @return {Undefined} */
		static IsActive = function() {
			if (!INPUT_BAN_KBM) {
				if (IsKeyboardActive()) {
					return true;
				}
			}
			if (!INPUT_BLOCK_MOUSE_CHECKS) {
				if (IsMouseActive()) {
					return true;
				}
			}
			return false;
		}
		
		/** Returns `true` if this `InputDevice` has not been assigned to a player and is available for use.
		 * @return {Bool} */
		static IsAvailable = function() {
			return (!INPUT_BAN_KBM && is_undefined(owner));
		}		
		
		/** The device reads all verbs defined by its assigned owner and writes the values to the two provided arrays.
		 * @arg {Array<Real>} _rawValueArray This array contains the raw input values read by the device.
		 * @arg {Array<Real>} _clampedValueArray This array contains the clamped values read by the device. These values will be normalized between 0 and 1.
		 * @return {Undefined} */ 
		static ReadInput = function(_rawValueArray, _clampedValueArray) {
			var _player = GetOwner();
			if (!is_undefined(_player)) {
				
				var i = 0; repeat(inputSystem.VerbGetCount()) {
					
					var _verb = _player.GetVerb(i++);
					var _bindings = _verb.BindingsGetKbm();
					
					//Iterate over all bindings to see if any keys are held down
					var _newHeld = false;
					var _button = _bindings
					
				}
			}
		}
	#endregion	
	
}