//feather ignore all

/** InputVirtualButtonDPad: A type of `InputVirtualButton` with both horizontal and vertical axis. DPad buttons are capable of 4-Directional or 8-Directional movement.
 * @arg {Enum.Input_Verb} _click The `click` verb to assign
 * @arg {Enum.Input_Verb} _up The `up` verb to assign
 * @arg {Enum.Input_Verb} _down The `down` verb to assign
 * @arg {Enum.Input_Verb} _left The `left` verb to assign
 * @arg {Enum.Input_Verb} _right The `right` verb to assign
 * @arg {Struct.Vector2} _position The position to initialize the button at
 * @arg {Struct.Vector2} _size The size to initialize the button at
 * @arg {Bool} _4d If the dpad is 4 directional (true) or 8 directional (false). DPad's are 8D by default.
 * @return {Struct.InputVirtualButtonDPad} */
function InputVirtualButtonDPad(_click, _up, _down, _left, _right, _position, _size, _4d = false) : InputVirtualButton(_click, _position, _size) constructor {
	
	
	#region Internal
		
		///@ignore
		is4D = _4d;	
		
		verbs.up = _up;
		verbs.down = _down;		
		verbs.left = _left;
		verbs.right = _right;
		
		
		/** Internal verb value capture for 4D D-Pads. Modifies the provided arrays with verb values
		 * @ignore
		 * @arg {Array<Real>} _valueRawArray Raw verb values array
		 * @arg {Array<Real>} _valueRawArray Raw clamped verb value array
		 * @arg {Real} _direction Direction to follow in degrees
		 * @return {Undefined} */
		static ButtonFollowCapture4D = function(_valueRawArray, _valueClampArray, _direction) {
			//45 = 0.25*360;	90 = 0.5*180;
			var _d = ((_direction + 45)/90) % 4;
			
			//4 possible direction splits
			switch (_d) {
				case 0:
					var _right = verbs.right;
					if (!is_undefined(_right)) {
						_valueRawArray[_right] = 1;
						_valueClampArray[_right] = 1;
					}				
				break;
				
				case 1:
					var _up = verbs.up;
					if (!is_undefined(_up)) {
						_valueRawArray[_up] = 1;
						_valueClampArray[_up] = 1;
					}					
				break;
				
				case 2:
					var _left = verbs.left;
					if (!is_undefined(_left)) {
						_valueRawArray[_left] = 1;
						_valueClampArray[_left] = 1;
					}					
				break;
				
				case 3:
					var _down = verbs.down;
					if (!is_undefined(_down)) {
						_valueRawArray[_down] = 1;
						_valueClampArray[_down] = 1;
					}					
				break;
			}
		}
		
		
		/** Internal verb value capture for 8D D-Pads. Modifies the provided arrays with verb values
		 * @ignore
		 * @arg {Array<Real>} _valueRawArray Raw verb values array
		 * @arg {Array<Real>} _valueRawArray Raw clamped verb value array
		 * @arg {Real} _direction Direction of the follow in degrees		 
		 * @return {Undefined} */
		static ButtonFollowCapture8D = function(_valueRawArray, _valueClampArray, _direction) {
			//22.5 = (1/8)*360;	45 = 0.25*180;
			var _d = ((_direction + 22.5)/45) % 8;
			
			//8 possible direction splits
			//Horizontal directions
			switch (_d) {
				case 0:
				case 1:
				case 7:
					var _right = verbs.right;
					if (!is_undefined(_right)) {
						_valueRawArray[_right] = 1;
						_valueClampArray[_right] = 1;
					}				
				break;
				
				case 3:
				case 4:
				case 5:
					var _left = verbs.left;
					if (!is_undefined(_left)) {
						_valueRawArray[_left] = 1;
						_valueClampArray[_left] = 1;
					}					
				break;
			}
			//Vertical directions
			switch (_d) {
				
				case 1:
				case 2:
				case 3:
					var _up = verbs.up;
					if (!is_undefined(_up)) {
						_valueRawArray[_up] = 1;
						_valueClampArray[_up] = 1;
					}						
				break;
				
				case 5:
				case 6:
				case 7:
					var _down = verbs.down;
					if (!is_undefined(_down)) {
						_valueRawArray[_down] = 1;
						_valueClampArray[_down] = 1;
					}					
				break;
			}			
		}				
		
		/** Internal verb value capture. Modifies the provided arrays with verb values
		 * @override
		 * @ignore
		 * @arg {Array<Real>} _valueRawArray Raw verb values array
		 * @arg {Array<Real>} _valueRawArray Raw clamped verb value array
		 * @arg {Struct.Vector2} _direction Direction vector representing the direction to follow 
		 * @return {Undefined} */
		static ButtonFollowCapture = function(_valueRawArray, _valueClampArray, _direction) {
			_direction = _direction.Direction();
			if (is4D) {
				return ButtonFollowCapture4D(_valueRawArray, _valueClampArray, _direction);
			}
			else {
				return ButtonFollowCapture8D(_valueRawArray, _valueClampArray, _direction);
			}
		}		
	#endregion
	
	/** Change if this d-pad is 4-Directional or 8-Directional.
	 * @arg {Bool} _set4D Set `true` to enable 4-Directional movement. Set `false` to enable 8-directional movement.
	 * @return {Undefined} */
	static Restrict4Directional = function(_set4D) {
		is4D = _set4D;
	}
	
	
}