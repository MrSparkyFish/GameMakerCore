//feather ignore all
/** InputVirtualButtonThumbstick: A type of `InputVirtualButton` that represents a digital thumbstick.
 * @ignore
 * @arg {Enum.Input_Verb} _click The `click` verb to assign
 * @arg {Enum.Input_Verb} _up The `up` verb to assign
 * @arg {Enum.Input_Verb} _down The `down` verb to assign
 * @arg {Enum.Input_Verb} _left The `left` verb to assign
 * @arg {Enum.Input_Verb} _right The `right` verb to assign
 * @arg {Struct.Vector2} _position The position to initialize the button at
 * @arg {Struct.Vector2} _size The size to initialize the button at
 * @return {Struct.InputVirtualButtonThumbstick} */
function InputVirtualButtonThumbstick(_click, _up, _down, _left, _right, _position, _size) : InputVirtualButton(_click, _position, _size) constructor {
	
	
	#region Internal
		verbs.up = _up;
		verbs.down = _down;		
		verbs.left = _left;
		verbs.right = _right;	
		
		
		
		/** Internal verb value capture. Modifies the provided arrays with verb values
		 * @override
		 * @ignore
		 * @arg {Array<Real>} _valueRawArray Raw verb values array
		 * @arg {Array<Real>} _valueRawArray Raw clamped verb value array
		 * @arg {Struct.Vector2} _direction Direction vector representing the direction to follow 
		 * @arg {Struct.Vector2} _delta The Delta vector of the follow
		 * @return {Undefined} */
		static ButtonFollowCapture = function(_valueRawArray, _valueClampArray, _direction, _delta) {
			var _sign = _direction.Sign();
			var _left = verbs.left;
			var _right = verbs.right;
			var _up = verbs.up;
			var _down = verbs.down;
			
			if (!is_undefined(_left)) {
				_valueRawArray[_left] = max(0, -_delta.x);
				_valueClampArray[_left] = max(0, -_sign.x);
			}
			
			if (!is_undefined(_up)) {
				_valueRawArray[_up] = max(0, -_delta.y);
				_valueClampArray[_up] = max(0, -_sign.y);				
			}
			
			if (!is_undefined(_right)) {
				_valueRawArray[_right] = max(0, _delta.x);
				_valueClampArray[_right] = max(0, _sign.x);
			}
			
			if (!is_undefined(_down)) {
				_valueRawArray[_down] = max(0, _delta.y);
				_valueClampArray[_down] = max(0, _sign.y);			
			}						
		}			
		
	#endregion
	
	
}