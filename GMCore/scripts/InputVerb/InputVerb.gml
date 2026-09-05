//feather ignore all

/** InputVerb: Verbs are the bride that connect an in-game action to the buttons of the device used to play the game. A single verb can be bound to any number of buttons at once. You bind input to each verb 
 * by specifying the appropriate button constant which can be any of:
 * `gp_*` constants
 * `vk_*` constants
 * `mb_*` constants
 * You can also use `string` for letter or number row keys instead of a `vk_*` constant (ie: "A" or "a"). Note that the number pad keys must use `vk_numpad*`
 * To bind more than one button, use an array of bindings (ie: `[vk_up, "W"]`) instead. In this case, the first element in the array is the primary key binding.
 * @arg {Enum.Input_Verb} _index
 * @arg {String} _name 
 * @arg {Any} _kbmBinding
 * @arg {Any} _gamepadBindings
 * @return {Struct.InputVerb} */
function InputVerb(_index, _name, _kbmBinding, _gamepadBindings) constructor {
	
	
	#region Private 
		
		enum Input_VerbStates {
			held,													//Verb is held in the current frame
			prevHeld,												//Verb was held in the previous frame
		} 
		
		///@ignore
		static names = [];											//Name list for all verb instances. This way there's one list and we don't have to separate verb state from definition 
		///@ignore
		verbIndex = _index;											//Dictionary index of this verb
		///@ignore
		keyBindings = [];											//KBM buttons that can trigger this verb.
		///@ignore
		gamepadBindings = [];										//Gamepad buttons that can trigger this verb.
		///@ignore
		flags = new BitMask();										//Tracks our verb states
		///@ignore
		value = 0;													//Analog value of a button
		///@ignore
		valueRaw = 0;												//Raw value of a button
		///@ignore
		pressFrame = -infinity;										//The game frame this verb was last triggered in.
		
		/** Internal helper function used to correct keyboard key strings in the keyBindings array to be their UTF-8 character codes compatible with input checks.
		 * @ignore
		 * @return {Undefined} */
		static FixKeyboardStrings = function() {
			var _binding;
			var i = 0; repeat(array_length(keyBindings)) {
				
				_binding = keyBindings[i];
				if (is_string(_binding)) {
					//Correct any lowercase characters
					var _upper = string_upper(_binding);
					if (_upper != "") {
						keyBindings[i++] = ord(_upper);
					}
					
					//Numbers do not need a correction
					else {
						keyBindings[i++] = ord(_binding);
					}
				}
			}
		}
		
	#endregion
	
	
	
	#region Basics
		
		/** Returns the `InputDictionary` index of this verb.
		 * @return {Real} */
		static GetIndex = function() {
			return verbIndex;
		}
		
		/** Returns the name of this verb
		 * @return {String} */
		static GetName = function() {
			return names[verbIndex];
		}
		
		/** Clears input value from this verb. A deactivated verb will always return `false` when calling `IsHeld()` or `IsPreviouslyHeld()` and 0 when calling `GetValue()` or `GetValueRaw()` until it is re-triggered.
		 * @return {Undefined} */
		static Deactivate = function() {
			Clear();
			flags.SetBitState(Input_VerbStates.prevHeld, false);
		}	
		
		/** Clears input value from this verb. A cleared verb will always return `false` when calling `IsHeld()` and 0 when calling `GetValue()` or `GetValueRaw()` until it is re-triggered.
		 * @return {Undefined} */
		static Clear = function() {
			pressFrame = -infinity;
			ValueReset();	
		}
		
		/** Returns true if this verb is being held
		 * @return {Bool} */
		static IsHeld = function() {
			return flags.IsBitActive(Input_VerbStates.held);
		}
		
		/** Set if this verb is held for the current frame
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetHeld = function(_bool) {
			flags.SetBitState(Input_VerbStates.held);
		}
		
		/** Returns `true` if this verb was held in the previous frame
		 * @return {Bool} */
		static IsPreviouslyHeld = function() {
			return flags.IsBitActive(Input_VerbStates.prevHeld);
		}
		
		/** Set if this verb was held in the last frame
		 * @arg {Bool} _bool
		 * @return {Undefined} */		
		static SetPreviouslyHeld = function(_bool) {
			flags.SetBitState(Input_VerbStates.prevHeld, _bool);
		}		
		
		/** Returns the raw value of input detected by this verb.
		 * @return {Real} */
		static GetValueRaw = function() {
			return valueRaw;
		}
		
		/** Set the raw value of this verb
		 * @arg {Real} _value
		 * @return {Undefined} */
		static SetValueRaw = function(_value) {
			valueRaw = _value;
		}
		
		/** Returns the value of input as a normalized value between 0 and 1.
		 * @return {Real} */
		static GetValue = function() {
			return value;
		}
		
		/** Set the value of this verb
		 * @arg {Real} _value
		 * @return {Undefined} */
		static SetValue = function(_value) {
			value = _value;
			if (value > 0) {
				SetHeld(true);	
			}
			else {
				SetHeld(false);	
			}
		}				
		
		/** Returns the frame number that input was last detected in
		 * @return {Real} */
		static GetPressFrame = function() {
			return pressFrame;
		}
		
		/** Set the frame that this verb was pressed.
		 * @arg {Real} _frame The frame number to set
		 * @return {Undefined} */
		static SetPressFrame = function(_frame) {
			pressFrame = _frame;
		}
		
		/** Sets the value and valueRaw to 0
		 * @return {Undefined} */
		static ValueReset = function() {
			SetValue(0);
			SetValueRaw(0);
		}
		
	#endregion
	
	#region Bindings
		
		/** Bind a button to this verb at the specified binding position. To unbind a button at the specified position, set the `_button` argument to `undefined`
		 * @arg {Array<Real>|Real} _button A vk_*, mb_*, or gp_* button constant or array of constants to assign as the binding for this `InputVerb`
		 * @arg {Real} _bindingPosition The binding number to set where 0 is the primary binding and all values greater than 0 are alternate bindings
		 * @arg {Bool} [_isGamepad] Set to `true` if you specified a gamepad button for `_button`
		 * @return {Undefined} */
		static SetButtonBinding = function(_button, _bindingPosition = 0, _isGamepad = false) {
			//Figure out what button type we're setting
			var _bindings = (_isGamepad) ? gamepadBindings : keyBindings;
			
			//Pad the array with undefined if it needs to grow.
			if (_bindingPosition >= array_length(_bindings)) {
				ArrayResizePadded(_bindings, _bindingPosition + 1, undefined);
			}
			_bindings[_bindingPosition] = _button;
		}
		
		/** Returns the button constant thats bound to this `InputVerb` at the specified binding position. If no button is bound at the provided position, `undefined` is returned instead.
		 * @arg {Real} _bindingPosition The index of the binding to return where 0 is the primary binding and positive integers are the alternate numbers. Default is 0
		 * @arg {Real} _isGamepad Set true to return a gamepad binding or false to return a kbm binding. Default is false.
		 * @return {Real} */
		static GetButtonBinding = function(_bindingPosition = 0, _isGamepad = false) {
			//Assume no button is bound
			var _button = undefined;
			//Figure out what button type we want
			var _bindings = (_isGamepad) ? gamepadBindings : keyBindings;
			
			//Check we have a valid binding position before getting the button bound there
			if (ArrayIsIndexInBounds(_bindings, _bindingPosition)) {
				_button = keyBindings[_bindingPosition];
			}
			return _button;			
		}
		
		/** Returns the array of kbm button constants that are bound to this `InputVerb`
		 * @return {Array} */ 
		static BindingsGetKbm = function() {
			return keyBindings;
		}	
		
		/** Returns an array of gamepad button constants that are assigned to this `InputVerb`
		 * @return {Array} */
		static BindingsGetGamepad = function() {
			return gamepadBindings;
		}
		
		/** Returns the specified array of button bindings
		 * @arg {Bool} [_forGamepad] Set true to return the verbs gamepad bindings, otherwise, the verbs Kbm bindings are returned instead.
		 * @return {Array<Constant.KbmButton>|Array<Constant.GamepadButton>} */
		static BindingsGet = function(_forGamepad = false) {
			return (_forGamepad) ? gamepadBindings : keyBindings;
		}
		
		/** Set the button bindings for this verb. Specify if the button bindings are for a gamepad
		 * @arg {Array<Constant.KbmButton>|Array<Constant.GamepadButton>} _buttons The array of buttons to bind to this verb
		 * @arg {Bool} [_forGamepad] Set `true` to set this verbs gamepad bindings. Otherwise, kbm bindings are set.
		 * @return {Undefined} */
		static BindingsSet = function(_buttons, _forGamepad = false) {
			return (_forGamepad) ? BindingsSetGamepad(_buttons) : BindingsSetKbm(_buttons);
		}
		
		/** Set new KBM binding values for this `InputVerb`
		 * @arg {Array<Constant.kbmButton>} [_kbmBindings] A single value or array of values of the following types: `vk_*` or `mb_*` constant, or a single character alhpanumerical key.		 
		 * @return {Undefined} */
		static BindingsSetKbm = function(_kbmBindings) {
			_kbmBindings = ArrayConvertValue(_kbmBindings);
			keyBindings = _kbmBindings;
			FixKeyboardStrings();
		}
		
		/** Set new Gamepad binding values for this `InputVerb`
		 * @arg {Array<Constant.GamepadButton>} _gamepadBindings A `gp_*` constant or an array of `gp_*` constants to assign as the gamepad binding
		 * @return {Undefined} */
		static BindingsSetGamepad = function(_gamepadBindings) {
			_gamepadBindings = ArrayConvertValue(_gamepadBindings);
			gamepadBindings = _gamepadBindings;
		}	
		
		/** Returns the binding position index of a button if it is bound to this verb. Returns `-1` if the button could not be found.
		 * @arg {Constant.InputButton} _button The button to look for
		 * @arg {Bool} [_forGamepad] `[=false]` Set to `true` if you're checking for a gamepad button, otherwise, looks for a Kbm button.
		 * @return {Real} */
		static FindBindingPosition = function(_button, _forGamepad = false) {
			var _bindings = (_forGamepad) ? gamepadBindings : keyBindings;
			return array_get_index(_bindings, _button);
		}
		
		
	#endregion
	
	//Main
	
	//Add my name to the list of names if it isn't already there
	ArrayPushUnique(names, _name);
	
	//Setup my button bindings
	BindingsSetKbm(_kbmBinding);	
	BindingsSetGamepad(_gamepadBindings);	
	
}