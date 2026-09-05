//feather ignore all
/** InputVirtualButtonHPad: A type of `InputVirtualButton` with a horizontal axis only.
 * 
 * @arg {Enum.Input_Verb} _click The `click` verb to assign
 * @arg {Enum.Input_Verb} _left The `left` verb to assign
 * @arg {Enum.Input_Verb} _right The `right` verb to assign
 * @arg {Struct.Vector2} _position The position to initialize the button at
 * @arg {Struct.Vector2} _size The size to initialize the button at
 * @return {Struct.InputVirtualButtonHPad} */
function InputVirtualButtonHPad(_click, _left, _right, _position, _size) : InputVirtualButton(_click, _position, _size) constructor {
	
	#region Internal
		
		verbs.left = _left;
		verbs.right = _right;
		
		
		/** Internal verb value capture. Modifies the provided arrays with verb values
		 * @override
		 * @ignore
		 * @arg {Array<Real>} _valueRawArray Raw verb values array
		 * @arg {Array<Real>} _valueRawArray Raw clamped verb value array
		 * @arg {Struct.Vector2} _direction Direction vector representing the direction to follow	 
		 * @return {Undefined} */
		static ButtonFollowCapture = function(_valueRawArray, _valueClampArray, _direction) {
			_direction = _direction.Direction();
			var _d = ((_direction+270)/180) % 2;
			if (_d == 1) {
				var _right = verbs.right;
				if (!is_undefined(_right)) {
					_valueRawArray[_right] = 1;
					_valueClampArray[_right] = 1;
				}
			} 
			else {
				var _left = verbs.left;
				if (!is_undefined(_left)) {
					_valueRawArray[_left] = 1;
					_valueClampArray[_left] = 1;
				}
			}
		}
		
	#endregion	
	
}