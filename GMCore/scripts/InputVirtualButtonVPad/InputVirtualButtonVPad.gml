//feather ignore all
/** InputVirtualButtonVPad: A type of `InputVirtualButton` with a vertical axis only.
 * @ignore
 * @arg {Enum.Input_Verb} _click The `click` verb to assign
 * @arg {Enum.Input_Verb} _up The `up` verb to assign
 * @arg {Enum.Input_Verb} _down The `down` verb to assign
 * @arg {Struct.Vector2} _position The position to initialize the button at
 * @arg {Struct.Vector2} _size The size to initialize the button at
 * @return {Struct.InputVirtualButtonVPad} */
function InputVirtualButtonVPad(_click, _up, _down, _position, _size) : InputVirtualButton(_click, _position, _size) constructor {
	
	
	#region Internal
		
		verbs.up = _up;
		verbs.down = _down;
		
		
		/** Internal verb value capture. Modifies the provided arrays with verb values
		 * @override
		 * @ignore
		 * @arg {Array<Real>} _valueRawArray Raw verb values array
		 * @arg {Array<Real>} _valueRawArray Raw clamped verb value array
		 * @arg {Struct.Vector2} _direction Direction vector representing the direction to follow	 
		 * @return {Undefined} */
		static ButtonFollowCapture = function(_valueRawArray, _valueClampArray, _direction) {
			_direction = _direction.Direction();
			var _d = (_direction/180) % 2;
			if (_d == 1) {
				var _down = verbs.down;
				if (!is_undefined(_down)) {
					_valueRawArray[_down] = 1;
					_valueClampArray[_down] = 1;
				}
			} 
			else {
				var _up = verbs.up;
				if (!is_undefined(_up)) {
					_valueRawArray[_up] = 1;
					_valueClampArray[_up] = 1;
				}
			}
		}
		
	#endregion
	
}