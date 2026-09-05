//feather ignore all

/** InputSystemComponent: You use this component to interact with the `InputSystem` which gives access to player input data such as keybindings, 
 * controller type, device settings, input activity, and more. Input can be checked using any of the `Check*()` methods. A component can only 
 * access the data for the player it represents.
 * @arg {Real} [_playerIndex] `[=0]` The player input profile index that this component uses for input detection.
 * @return {Struct.InputSystemComponent} */
function InputSystemComponent(_playerIndex = 0) constructor {
	
	#region Private
		
		enum Input_SystemComponentFlags {
			blocked,															//The component is being blocked from detecting input
			ghost,																//The component is blocked from detecting input, but still reports a connection to the system					
			anyInput
		}
		
		///@ignore
		static inputSystem = undefined;											//Reference to the main input system. It executes primary logic related to input detection and assignment.
		///@ignore
		playerIndex = _playerIndex;												//The index of the player that this component represents.
		
		
		try {
			inputSystem = InputSystem.singleton;
		}
		catch(error) {
			inputSystem = new InputSystem();
		}
		
		/** Returns the specified `InputVerb` defined by the player I represent
		 * @ignore
		 * @arg {Enum.Input_Verb} _verb The verb index to get the definition from
		 * @return {Struct.InputVerb} */
		static GetPlayerVerb = function(_verb) {
			return inputSystem.GetPlayer(playerIndex).GetVerb(_verb);
		}
		
		/** Abstracted verb check to see if there's input detected for the verb
		 * @ignore
		 * @arg {Enum.Input_Verb} _input The verb to check
		 * @return {Bool} */
		static CheckVerbHeld = function(_input) {
			var _verb = GetPlayerVerb(_input);
			return _verb.IsHeld();
		}
		
		/** Abstracted verb check to see if there's input detected for the verb during the last frame
		 * @ignore
		 * @arg {Enum.Input_Verb} _input The verb to check
		 * @return {Bool} */		
		static CheckVerbPreviouslyHeld = function(_input) {
			var _verb = GetPlayerVerb(_input);
			return _verb.IsPreviouslyHeld();			
		}
		
		/** Abstracted method that returns the analog value of the specified input.
		 * @ignore
		 * @arg {Enum.Input_Verb} _input The verb to get value from
		 * @return {Real} */
		static FindVerbAnalogValue = function(_input) {
			var _verb = GetPlayerVerb(_input);
			var _value = _verb.GetValue();
			return _value;
		}
		
		/** Abstracted method that returns the frame the verb was last pressed in.
		 * @ignore
		 * @arg {Enum.Input_Verb} _input The verb to get value from
		 * @return {Real} */
		static GetVerbPressFrame = function(_input) {
			var _verb = GetPlayerVerb(_input);
			var _frame = _verb.GetPressFrame();
			return (_frame < 0) ? -1 : _frame;			
		}
		
		/** Abstracted method to return the number of input frames since the inputs last detected press
		 * @ignore
		 * @arg {Enum.Input_Verb} _input Verb to check
		 * @return {Real} */
		static GetTimeSincePressed = function(_input) {
			return inputSystem.GetFrame() - GetVerbPressFrame(_input);
		}
		
		/** Returns -1 the negative verb is more recently active, or 1 if the positive verb is more recently active
		 * @ignore
		 * @arg {Enum.Input_Verb} _neg
		 * @arg {Enum.Input_Verb} _pos
		 * @return {Real} */
		static MostRecentVerb = function(_neg, _pos) {
			var _nFrame = GetVerbPressFrame(_neg);
			var _pFrame = GetVerbPressFrame(_pos);
			return (_nFrame > _pFrame) ? -1 : 1;			
		}	
		
		/** Internal logic for sending a repeating boolean input pulse.
		 * @ignore
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @arg {Real} _delay Time between each trigger
		 * @arg {Real} _preDelay Time before the first trigger
		 * @return {Bool} */		
		static RepeatPulse = function(_input, _delay = undefined, _preDelay = undefined) {
			_delay ??= INPUT_REPEAT_DEFAULT_DELAY;
			_preDelay ??= INPUT_REPEAT_DEFAULT_PREDELAY;
			
			var _time = GetTimeSincePressed(_input);
			if (_time == 0) {
				return true;
			}
			
			_time -= _preDelay;
			if (_time < 0) {
				return false;
			}
			return (floor(_time/_delay) > floor(_time - 1) / _delay);			
		}
		
	#endregion
	
	
	#region Binding/Rebinding
		
		/** Returns an array of `InputBindingCapture` instances that contain data relevant to each location the specified `_button` is bound. If `_button` is not yet bound, the return array will be empty.
		 * @arg {Constant.KbmButton|Constant.GamepadButton} _button A `vk_*`, `mb_*`, or `gp_*` button constant. If specifying a gamepad button, be sure to also set the `_isGamepad` argument to true.
		 * @arg {Bool} [_isGamepad] Be sure to set `true` if you specified a gamepad button constant for the `_button` argument.
		 * @arg {Array} [_resultBag] Optionally provide an array to store the binding captures. Otherwise, the method will create a return array for you.
		 * @return {Array<StructInputBindingCapture>} */
		static BindingFindVerbs = function(_button, _isGamepad = false, _resultBag = undefined) {
			return inputSystem.PlayerFindBindingCollisions(playerIndex, _button, _isGamepad, _resultBag);
		}
		
		/** Returns the button binding constant that triggers the specified verb.
		 * @arg {Enum.Input_Verb} _verb The verb you want to check
		 * @arg {Real} _bindingPosition A single verb can have more than 1 associated binding. Use this value to specify a binding number where 0 is the primary binding and 1 is the 1st alternate binding, 2 is the 2nd alternate binding, and so on.
		 * @arg {Bool} _forGamepad Set `true` to indicate that you want to get the gamepad a gamepad binding. Defaults to false.
		 * @return {Real} */
		static BindingGet = function(_verb, _bindPosition = 0, _forGamepad = false) {
			if (!inputSystem.ValidateVerbIndex(_verb)) {
				inputSystem.ThrowInvalidVerb("BindingGet", _verb, self);
			}
			return GetPlayerVerb(_verb).GetButtonBinding(_bindPosition, _forGamepad);	
		}
		
		/** Binds a button to a verb at the specified binding position.
		 * @arg {Constant.KbmButton|Constant.GamepadButton} _button The button to bind
		 * @arg {Enum.Input_Verb} _verb The verb to bind the button to
		 * @arg {Real} [_bindingPosition] The binding position of the button within the verb where position 0 is the primary button binding.
		 * @arg {Bool} [_forGamepad] Set `true` if a gamepad button is being bound.
		 * @return {Undefined} */		
		static BindingSet = function(_button, _verb, _bindingPosition = 0, _forGamepad = false) {
			if (!inputSystem.ValidateVerbIndex(_verb)) {
				inputSystem.ThrowInvalidVerb("BindingSet", _verb, self);
			} 
			
			var _verbDef = GetPlayerVerb(_verb);
			var _prevBinding = _verbDef.GetButtonBinding(_bindingPosition, _forGamepad);
			_verbDef.SetButtonBinding(_button, _bindingPosition, _forGamepad);
			
			if (_forGamepad && inputSystem.GamepadIsBindingThumbstick([_prevBinding, _button])) {
				inputSystem.GetPlayer(playerIndex).ClusterUpdateThresholds();
			}
		}		
		
		/** Set a button binding for the specified verb. Attempts to resolve the simple conflict for if the button is being bound as a primary binding when its already the primary binding of another verb. Returns `true` if no conflicts were found or if conflicts were successfully resolved; otherwise, returns `false`.
		 * @arg {Constant.KbmButton|Constant.GamepadButton} _button The button to bind
		 * @arg {Enum.Input_Verb} _verb The verb to bind the button to
		 * @arg {Real} [_bindingPosition] The binding position of the button within the verb where position 0 is the primary button binding.
		 * @arg {Bool} [_forGamepad] Set `true` if a gamepad button is being bound.
		 * @return {Bool} */	
		static BindingSetSafe = function(_button, _verb, _bindingPosition = 0, _forGamepad = false) {
			if (!inputSystem.ValidateVerbIndex(_verb)) {
				inputSystem.ThrowInvalidVerb("BindingSetSafe", _verb, self);
			}			
			
			var _collisions = BindingFindVerbs(_button, _forGamepad);
			var _len = array_length(_collisions);
			var _bool = false;
			
			//This button isn't bound to any other verbs so we can do a quick set
			if (_len == 0) {
				GetPlayerVerb(_verb).SetButtonBinding(_button, _bindingPosition, _forGamepad);
				_bool = true;
			}
			
			//Resolving Conflicts//
			else {
				if (INPUT_LOG_WARNING) {
					LogWarning(ExceptionMessage("BindingSetSafe", "Binding conflict found. Attempting to resolve."));
					if (_len > 1) {
						LogWarning(ExceptionMessage("BindingSetSafe", $"More than one binding conflict detected. Resolution may not be ideal."))
					}
				}
				
				
				var _collision = _collisions[0];
				var _verbIndex = _collision.GetVerbIndex();
				var _bindPos = _collision.GetBindingIndex();
				
				if ((_verb != _verbIndex) || (_bindingPosition != _bindPos)) {
					if (INPUT_LOG_DEBUG) {
						LogDebug(ExceptionMessage("BindingSetSafe", "Collision found. Swapping bindings."));
					}
					BindingSwap(_verb, _bindingPosition, _verbIndex, _bindPos, _forGamepad);
				}
				else {
					if (INPUT_LOG_DEBUG) {
						var _name = (_forGamepad) ? inputSystem.GamepadGetBindingName(_button) : inputSystem.KbmGetBindingName(_button);
						var _verbName = inputSystem.VerbGetName(_verbIndex);
						var _deviceName = (_forGamepad) ? "Gamepad" : "Kbm";
						LogDebug(ExceptionMessage("BindingSetSafe", $"New {_deviceName} binding {_name} is the same as existing {_verbName} binding {_collision}"));
					}
				}	
			}
			return _bool;
		}	
		
		/** Swap the keyboard bindings or gamepad bindings of two verbs
		 * @arg {Enum.Input_Verb} _verbA The first verb
		 * @arg {Real} _bindPositionA The binding position for the button being swapped in the first verb
		 * @arg {Enum.Input_Verb} _verbB The second verb
		 * @arg {Real} _bindPositionB The binding position of the  button being swapped in the second verb
		 * @arg {Bool} [_gamepad] Set `true` to swap gamepad bindings instead of Kbm bindings.
		 * @return {Undefined} */
		static BindingSwap = function(_verbA, _bindPositionA, _verbB, _bindPositionB, _gamepad = false) {
			//Getting verb definitions
			var _verbDefA = GetPlayerVerb(_verbA);
			var _verbDefB = GetPlayerVerb(_verbB);
			
			var _buttonA = _verbDefA.GetButtonBinding(_bindPositionA, _gamepad);
			var _buttonB = _verbDefB.GetButtonBinding(_bindPositionB, _gamepad);
			_verbDefA.SetButtonBinding(_buttonB, _bindPositionA, _gamepad);
			_verbDefB.SetButtonBinding(_buttonA, _bindPositionB, _gamepad);
		}
		
		/** Resets the button bindings assigned to the specified verb back to their default bindings as defined in the `InputDictionary`
		 * @arg {Enum.Input_Verb} _verb The verb with the binding to reset
		 * @arg {Real} [_bindingPosition] The binding position to reset
		 * @arg {Bool} [_isGamepad] Set `true` to reset the verb's gamepad bindings. Otherwise, resets keyboard bindings
		 * @return {Undefined} */
		static BindingsReset = function(_verb, _bindingPosition, _isGamepad = false) {
			if (!inputSystem.ValidateVerbIndex(_verb)) {
				inputSystem.ThrowInvalidVerb("BindingReset", _verb, self);
			} 			
			var _verbDef = GetPlayerVerb(_verb);
			var _default = inputSystem.VerbGetDefaultBindings(_verb, _isGamepad);
			_verbDef.BindingsSet(_default, _isGamepad);
		}		
	#endregion
	
	
	#region Checking Verbs
		
		/** Returns the frame number that the specified input was last detected in. Returns -1 if the input has not been previously activated.
		 * @arg {Enum.Input_Verb} _input The input to check the frame of.
		 * @return {Real} */
		static CheckFrame = function(_input) {
			if (!inputSystem.ValidateVerbIndex(_input)) {
				inputSystem.ThrowInvalidVerb("CheckFrame", _input, self)
			}
			return GetVerbPressFrame();
		}
		
		/** Returns how many frames have elapsed since the specified input was last newly pressed. Returns `0` if the input was activated in the current update loop.
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @return {Real} */
		static TimeSinceLastDetection = function(_input) {
			if (!inputSystem.ValidateVerbIndex(_input)) {
				inputSystem.ThrowInvalidVerb("TimeSinceLastDetection", _input, self)
			}		
			return GetTimeSincePressed();
		}	
		
		/** Returns the current button value of the specified button constant using the device assigned to the player represented by this component. If the button isn't of the appropriate type for the player's device, a value of `-1` will be returned. It's important to note that this isn't the same value as the value reported by the verb it's bound to, although in many cases, especially ones where the verb only has one button bound, the values will still be the same.
		 * @arg {Constant.InputButton} _button The button to check value for.
		 * @return {Real} */
		static ButtonValue = function(_button) {
			var _device = inputSystem.GetPlayer(playerIndex).GetDevice();
			if (!_device.ValidateButton(_button)) {
				return -1;
			}
			else {
				return _device.CheckButton(_button);
			}
		}		
		
		/** The most generic check. Returns `true` if the specified input is being held down for the current frame.
		 * @arg {Enum.Input_Verb} _input The input verb to check
		 * @return {Undefined} */
		static Check = function(_input) {
			if (!inputSystem.ValidateVerbIndex(_input)) {
				inputSystem.ThrowInvalidVerb("Check", _input, self)
			}
			return CheckVerbHeld(_input);	
		}
		
		/** Returns `true` if the specified input was held down during the last frame.
		 * @arg {Enum.Input_Verb} _input The input verb to check
		 * @return {Undefined} */		
		static CheckPrevious = function(_input) {
			if (!inputSystem.ValidateVerbIndex(_input)) {
				inputSystem.ThrowInvalidVerb("CheckPrevious", _input, self)
			}
			return CheckVerbPreviouslyHeld(_input);				
		}
		
		/** Returns `true` if any input from the specified array is being held down in the current frame.
		 * @arg {Array} _input Array of `Enum.Input_Verb` values to check. 
		 * @return {Bool} */
		static CheckAny = function(_input) {
			_input = ArrayConvertValue(_input);
			var i = 0; repeat(array_length(_input)) {
				var _verb = _input[i++];
				if (Check(_verb)) {
					return true;
				}
			}
			return false;
		}
		
		/** Returns `true` if the specified input is newly pressed in the current frame. If the input was previously held, it must be released before this method can return `true`.
		 * @arg {Enum.Input_Verb} _input The input verb to check
		 * @return {Bool} */
		static CheckPressed = function(_input) {
			return (Check(_input) && !CheckPrevious(_input));
		}
		
		/** Returns `true` if any input from an array is newly pressed in the current frame.
		 * @arg {Array<Enum.Input_Verb>} _input Array of verbs to check.
		 * @return {Bool} */
		static CheckPressedAny = function(_input) {
			_input = ArrayConvertValue(_input);
			var i = 0; repeat(array_length(_input)) {
				if (CheckPressed(_input[i++])) {
					return true;
				}
			}
			return false;
		}
		
		/** Returns `true` if the specified input was pressed during the last `_duration` of input frames.
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @arg {Real} _duration The duration period to use (in game frames)
		 * @return {Bool} */
		static CheckBufferPress = function(_input, _duration) {
			return (TimeSinceLastDetection() <= _duration);
		}
		
		/** Returns `true` if any input from an array was held or pressed during the last `_duration` of input frames.
		 * @arg {Array<Enum.Input_Verb>} _input The input to check
		 * @arg {Real} _duration The duration period to use (in game frames)
		 * @return {Bool} */		
		static CheckBufferPressAny = function(_input, _duration) {
			_input = ArrayConvertValue(_input);
			var i = 0; repeat(array_length(_input)) {
				if (CheckBufferPress(_input[i++], _duration)) {
					return true;
				}
			}
			return false;			
		}				
		
		/** Returns `true` if the specified input has been held down for at least 2 consecutive frames.
		 * @arg {Enum.Input_Verb} _input The input verb to check
		 * @return {Bool} */
		static CheckHold = function(_input) {
			return (Check(_input) && CheckPrevious(_input));
		}
		
		/** Returns `true` if any input from an array has been held down for at least 2 consecutive frames.
		 * @arg {Array<Input_Verb>} _input The array of inputs to check
		 * @return {Bool} */
		static CheckHoldAny = function(_input) {
			_input = ArrayConvertValue(_input);
			var i = 0; repeat(array_length(_input)) {
				if (CheckHold(_input[i++])) {
					return true;
				}
			}
			return false;
		}			
		
		/** Returns `true` if the specified input was released in the current frame.
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @return {Bool} */
		static CheckReleased = function(_input) {
			return (CheckPrevious(_input) && !Check(_input));		
		}
		
		/** Returns `true` if any input from an array was released in the current frame.
		 * @arg {Array<Enum.Input_Verb>} _input The array of inputs to check
		 * @return {Bool} */
		static CheckReleasedAny = function(_input) {
			_input = ArrayConvertValue(_input);
			var i = 0; repeat(array_length(_input)) {
				if (CheckReleased(_input[i++])) {
					return true;
				}
			}
			return false;
		}		
		
		/** Returns the last `InputVerb` that had detected input from among an array of possible inputs. The return value will be a member of `Enum.Input_Verb` unless no verb was found in which case `undefined` is returned instead.
		 * @arg {Array<Enum.Input_Verbs>} [_inputs] Array of inputs to check through. Defaults to all inputs.
		 * @return {Real} */
		static CheckLast = function(_inputs = undefined) {
			_inputs ??= array_create_ext(inputSystem.VerbGetCount(), function(_index) {
				return _index;
			});
			
			var _maxTime = -1;
			var _verb, _time, _result;
			
			var i = 0; repeat(array_length(_inputs)) {
				_verb = _inputs[i++];
				_time = CheckFrame(_verb);
				if (_time > _maxTime) {
					_maxTime = _time;
					_result = _verb;
				}
			}
			return _result;
		}
		
		/** Returns the last `InputVerb` index that is still active from among an array of possible inputs. The return value will be a member of `Enum.Input_Verb` unless no verb was found in which case `undefined` is returned instead.
		 * @arg {Array<Enum.Input_Verbs>} [_inputs] Array of inputs to check through. Defaults to all inputs.
		 * @return {Real} */
		static CheckLastPressed = function(_inputs = undefined) {
			_inputs ??= array_create_ext(inputSystem.VerbGetCount(), function(_index) {
				return _index;
			});
			
			var _maxTime = -1;
			var _verb, _time, _result;
			
			var i = 0; repeat(array_length(_inputs)) {
				_verb = _inputs[i];
				_time = CheckFrame(_verb);
				if ((_time > _maxTime) && CheckVerbHeld(i++)) {
					_maxTime = _time;
					_result = _verb;
				}
			}
			return _result;
		}
		
		/** Returns the current analog value of the specified input which is a normalized value. A regular button will return either `1` or `0`.
		 * @arg {Enum.Input_Verb} _input The input to get the analog value of
		 * @return {Real} */
		static AnalogValue = function(_input) {
			if (!inputSystem.ValidateVerbIndex(_input)) {
				inputSystem.ThrowInvalidVerb("AnalogValue", _input, self)
			}
			return FindVerbAnalogValue(_input);
		}
		
		/** Returns `true` if an input has been held for longer than the specified duration
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @arg {Real} _duration The long hold duration (in game frames).
		 * @return {Bool} */
		static CheckLong = function(_input, _duration = INPUT_LONG_DEFAULT_DELAY) {
			var _held = Check(_input);
			return (_held && (GetTimeSincePressed() >= _duration));					
		}
		
		/** Returns `true` if an input is newly considered a "long hold" based on hold duration.
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @arg {Real} _duration The long hold duration (in game frames).
		 * @return {Bool} */
		static CheckLongPress = function(_input, _duration = INPUT_LONG_DEFAULT_DELAY) {
			var _held = Check(_input);
			return (_held && (GetTimeSincePressed() >= _duration));
		}
		
		/** Returns `true` if an input was a long press and has been released.
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @arg {Real} _duration The long hold duration (in game frames).
		 * @return {Bool} */		
		static CheckLongReleased = function(_input, _duration = INPUT_LONG_DEFAULT_DELAY) {
			if (!inputSystem.ValidateVerbIndex(_input)) {
				inputSystem.ThrowInvalidVerb("CheckLongPress", _input, self)
			}
			
			var _held = CheckVerbHeld();
			var _prev = CheckVerbPreviouslyHeld();
			return (_prev && (!_held) && (GetTimeSincePressed() >= _duration));			
		}
		
		/** Returns -1 if only the "negative" input is active, 1 if only the "positive" input is active, and 0 if both inputs are active or inactive. Similar to an XOR check.
		 * @arg {Enum.Input_Verb} _negative The input verb to use as the negative
		 * @arg {Enum.Input_Verb} _positive The input verb to use as the positive
		 * @arg {Bool} [_mostRecent] Set `true` to return the value of the most recently activated input in the event both inputs are active. Otherwise, the method returns 0 if both are active.
		 * @return {Real} */
		static CheckOpposing = function(_negative, _positive, _mostRecent = INPUT_OPPOSING_DEFAULT_MOST_RECENT) {
			var _checkPos = Check(_positive);
			var _checkNeg = Check(_negative);
			
			//Finds which one is the most recently active if both are active and we want most recent.
			return (_mostRecent && _checkPos && _checkNeg) ? MostRecentVerb(_negative, _positive) : (_checkPos - _checkNeg);
		}	
		
		/** Returns -1 if only the "negative" input is newly active, 1 if only the "positive" input is newly active, and 0 if both inputs are newly active or inactive. Similar to an XOR check.
		 * @arg {Enum.Input_Verb} _negative The input verb to use as the negative
		 * @arg {Enum.Input_Verb} _positive The input verb to use as the positive
		 * @arg {Bool} [_mostRecent] Set `true` to return the value of the most recently activated input in the event both inputs are active. Otherwise, the method returns 0 if both are active.
		 * @return {Real} */		
		static CheckOpposingPressed = function(_negative, _positive, _mostRecent = INPUT_OPPOSING_DEFAULT_MOST_RECENT) {
			var _checkPos = CheckPressed(_positive);
			var _checkNeg = CheckPressed(_negative);
			
			//Finds which one is the most recently active if both are active and we want most recent.
			return (_mostRecent && _checkPos && _checkNeg) ? MostRecentVerb(_negative, _positive) : (_checkPos - _checkNeg);
		}
		
		/** Returns a repeating boolean pules while an input is active. Useful for things like scrolling through long menus with digital input.
		 * @arg {Enum.Input_Verb} _input The input to check
		 * @arg {Real} _delay Time between each trigger
		 * @arg {Real} _preDelay Time before the first trigger
		 * @return {Bool} */
		static RepeatCheck = function(_input, _delay = INPUT_REPEAT_DEFAULT_DELAY, _preDelay = INPUT_REPEAT_DEFAULT_PREDELAY) {
			var _check = Check(_input);
			if (!_check) {
				return false;
			}
			return RepeatPulse(_input, _delay, _preDelay);
		}	
		
		/** Returns -1 if only the "negative" input is newly active, 1 if only the "positive" input is newly active, and 0 if both inputs are newly active or inactive. Similar to an XOR check.
		 * @arg {Enum.Input_Verb} _negative The input verb to use as the negative
		 * @arg {Enum.Input_Verb} _positive The input verb to use as the positive
		 * @arg {Real} _delay Time between each trigger
		 * @arg {Real} _preDelay Time before the first trigger
		 * @return {Real} */	
		static RepeatCheckOpposing = function(_negative, _positive, _delay = INPUT_REPEAT_DEFAULT_DELAY, _preDelay = INPUT_REPEAT_DEFAULT_PREDELAY) {
			var _check = CheckOpposing(_negative, _positive, false);
			if (_check == 0) {
				return _check;
			}
			
			return (_check < 0) ? -1*RepeatPulse(_negative, _delay, _preDelay) : RepeatPulse(_positive, _delay, _preDelay);
		}
		
		/** Returns the direction vector of the specified cluster
		 * @arg {Enum.Input_Cluster} _cluster The cluster to get the position for
		 * @arg {Bool} [_normalize] `[=true]` If the returning position normalized.
		 * @return {Struct.Vector2} */
		static ClusterPosition = function(_cluster, _normalize = true) {
			if (!inputSystem.ValidateClusterIndex(_cluster)) {
				inputSystem.ThrowInvalidCluster("ClusterPosition", _cluster, self);
			}
			
			var _position = inputSystem.GetPlayer(playerIndex).GetClusterPosition(_cluster);
			return (_normalize) ? _position.Normalize() : _position;
		}
	#endregion
}	