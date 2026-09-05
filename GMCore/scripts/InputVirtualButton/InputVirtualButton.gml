//feather ignore all

/** InputVirtualButton: Virtual buttons are capable of detecting and collecting touch input and should be used to represent mobile touch screen 
 * buttons, PS4/5 controller touch pads, or other button types that read touch input. By default, virtual buttons are instantiated as a circle. 
 * You can use `.SetBBoxType()` to set rectangular or circular shapes for your button. Finally, virtual buttons are only tracked by the system
 * if they've been added to the input system using the system's `.AddVirtualButton()` method.
 * @arg {Enum.Input_Verb} _click The `click` verb to assign
 * @arg {Struct.Vector2} _position The position to initialize the button at
 * @arg {Struct.Vector2} _size The size to initialize the button at
 * @return {Struct.InputVirtualButton} */
function InputVirtualButton(_click, _position, _size) constructor {
	
	enum Input_VirtualButtonReferencePolicy {
		center,
		touchPoint,
		delta
	}
	
	//Dictates what happens when the button is released
	enum Input_VirtualButtonReleasePolicy {
		destroy,						
		reset,
		none,							//Do nothing
	}
	
	//List of button flags
	enum Input_VirtualButtonFlags {
		destroyed,						//This button has been destroyed
		active,							//This button is currently active
		follow,
		historyEnabled,					//This button uses history
		firstTouch,						//This button only detects the first touch
		holdable,						//This button can be held down
		prevHeld,						//Button was held down in the previous game step
		held,							//Button is held down in the current game step
		heldBuffer						//Button was buffered to be held
	}
	
	//Events publishable by this button
	enum Input_VirtualButtonEvents {
		click,							
		left,							
		right,					
		up,
		down,
	}
	
	//Determines the draw type for the bbox
	enum Input_VirtualButtonBBoxType {
		none,							//No drawing permitted
		circular,						//Draw circle
		rectangular						//Draw rectangle
	}
	
	
	#region Internal
		///@ignore
		static inputSystem = InputSystem.singleton;
		
		///@ignore
		flags = new BitMask(1);											//Tracks flags. Start with `active` flag enabled
		///@ignore
		thresholdMin = INPUT_VIRTUAL_BUTTON_MIN_THRESHOLD;				//Measured in pixels in GUI-space
		///@ignore
		thresholdMax = INPUT_VIRTUAL_BUTTON_MAX_THRESHOLD;				////Measured in pixels in GUI-space
		///@ignore
		priority = 0;													//Priority of this virtual button compared to other virtual buttons
		
		///@ignore
		verbs = new InputVirtualButtonVerbs(self);						//Stores the verbs assigned to this container
		verbs.click = _click;
		
		///@ignore
		prevPos = undefined;											//Previous position
		/////@ignore
		startPos = _position;											//Starting position
		///@ignore
		startSize = _size;												//Starting size
		///@ignore
		bboxType = Input_VirtualButtonBBoxType.rectangular;				//Indicates bbox bbox type
		///@ignore
		bbox = new BBox(startPos, startSize);							//The bbox shape used by the button.
		
		///@ignore
		touchPointIndex = undefined;									//Touch device index the button is related to
		///@ignore
		touchStartPos = undefined;										//The starting position of a touch
		///@ignore
		touchPos = undefined;											//The current position of a touch
		///@ignore
		captureFrame = undefined;										//The frame the last touchpoint was captured at. Also guards against calls to `Collect()` before `TouchPointCapture()`
		///@ignore
		history = [];													//Array of the most recent touch point positions
		///@ignore
		historyCount = 0;												//Current number of entries in history		
		
		///@ignore
		releasePolicy = Input_VirtualButtonReleasePolicy.none;			//Determines what happens when the button is released
		///@ignore
		reference = Input_VirtualButtonReferencePolicy.center;			//Determines the reference point to use for touchpoint following
		
		/** Finds the position of a touch and returns it as a new `Vector2` 
		 * @ignore
		 * @arg {Real} _touchPoint The index of a touch point
		 * @return {Struct.Vector2} */
		static FindTouchPosition = function(_touchPoint) {
			var _x = device_mouse_x_to_gui(_touchPoint);
			var _y = device_mouse_y_to_gui(_touchPoint);
			return new Vector2(_x, _y);
		}
		
		/** Internal add history logic
		 * @ignore
		 * @arg {Struct.InputVirtualButton$$TouchPoint} _point
		 * @return {Undefined} */
		static HistoryPush = function(_point) {
			array_delete(history, INPUT_VIRTUAL_BUTTON_HISTORY_FRAMES, 1);
			array_insert(history, 0, _point);
			historyCount++;
		}
		
		/** Internal verb value capture. Modifies the provided arrays with verb values
		 * @ignore
		 * @arg {Array<Real>} _valueRawArray Raw verb values array
		 * @arg {Array<Real>} _valueRawArray Raw clamped verb value array
		 * @arg {Struct.Vector2} _direction Direction vector representing the direction to follow
		 * @arg {Struct.Vector2} _delta Delta vector. Used only for virtual thumbsticks.
		 * @return {Undefined} */
		static ButtonFollowCapture = function(_valueRawArray, _valueClampArray, _direction, _delta = undefined) {
			ThrowMethodNotImplemented("ButtonFollowCapture");
		}
	#endregion
	
	
	
	#region Basics
		
		/** Returns if this virtual button has been destroyed
		 * @return {Bool} */
		static IsDestroyed = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.destroyed);
		}
		
		/** Marks this virtual button as having been destroyed.
		 * @return {Undefined} */
		static Destroy = function() {
			if (!IsDestroyed()) {
				flags.SetBitState(Input_VirtualButtonFlags.destroyed, true);
				inputSystem.SetVirtualOrderDirty(true);
			}
		}
		
		/** Returns `true` if this button is circular. Returns `false` if its rectangular.
		 * @return {Bool} */
		static IsCircular = function() {
			return (bboxType == Input_VirtualButtonBBoxType.circular);
		}
		
		/** Draw the button at its current position. This method only works if called in a draw event.
		 * @return {Undefined} */
		static Draw = function() {
			if (IsDestroyed() || (bboxType == Input_VirtualButtonBBoxType.none)) {
				return;
			}
			
			bbox.OnDirty();
			//Draw the bbox with an effect when being pressed
			if (flags.IsBitActive(Input_VirtualButtonFlags.active)) {
				if (bboxType == Input_VirtualButtonBBoxType.circular) {
					var _position = bbox.position;
					var _x = _position.x;
					var _y = _position.y;
					var _radius = bbox.radius.x;
					draw_circle(_x, _y, _radius, true);
					draw_circle(_x, _y, _radius-4, true);
					draw_circle(_x, _y, _radius-8, !flags.IsBitActive(Input_VirtualButtonFlags.held));
				}
				else if (bboxType == Input_VirtualButtonBBoxType.rectangular) {
					var _left = bbox.topLeft.x;
					var _top = bbox.topLeft.y;
					var _right = bbox.bottomRight.x;
					var _bottom = bbox.bottomRight.y;
					draw_rectangle(_left, _top, _right, _bottom, true);
					draw_rectangle(_left+4, _top+4, _right-4, _left-4, true);
					draw_rectangle(_left+8, _top+8, _right-8, _left-8, true);
				}	
			}
			
			//Draw normally
			else {
				var _oldAlpha = DRAW_ALPHA;
				draw_set_alpha(0.333*_oldAlpha);
				
				if (bboxType == Input_VirtualButtonBBoxType.circular) {
					draw_circle(bbox.position.x, bbox.position.y, bbox.radius.x, true);
				}
				else if (bboxType == Input_VirtualButtonBBoxType.rectangular) {
					draw_rectangle(bbox.topLeft.x, bbox.topLeft.y, bbox.bottomRight.x, bbox.bottomRight.y, true);
				}
				draw_set_alpha(_oldAlpha);
			}
			
		}
		
		/** Set new threshold values for button input detection. These values are measured in Pixels in GUI-space.
		 * @arg {Real} _min Minimum threshold.
		 * @arg {Real} _max Maximum threshold.
		 * @return {Undefined} */
		static SetThresholdValues = function(_min, _max) {
			thresholdMin = max(0, min(_min, _max));
			thresholdMax = max(thresholdMin, max(_min, _max));
		}
		
		/** Set new threshold values for button input detection. These values are measured in Pixels in GUI-space.
		 * @arg {Real} _threshold Minimum threshold.
		 * @return {Undefined} */		
		static SetThresholdMinimum = function(_threshold) {
			thresholdMin = max(0, _threshold);
		}
		
		/** Set new threshold values for button input detection. These values are measured in Pixels in GUI-space.
		 * @arg {Real} _threshold Maximum threshold.
		 * @return {Undefined} */		
		static SetThresholdMaximum = function(_threshold) {
			thresholdMax = max(thresholdMin, _threshold);
		}
		
		/** Returns the minimum threshold value for touch input measured in Pixels in GUI-space.
		 * @return {Real} */
		static GetThresholdMinimum = function() {
			return thresholdMin;
		}
		
		/** returns the maximum threshold value for touch input measured in Pixels in GUI-space.
		 * @return {Real} */
		static GetThresholdMaximum = function() { 
			return thresholdMax;
		}
		
		/** Sets the priority value of this button
		 * @arg {Real} _priority
		 * @return {Undefined} */
		static SetPriority = function(_priority) {
			priority = _priority
		}		
		
		/** Returns the priority value of this button
		 * @return {Undefined} */
		static GetPriority = function() {
			return priority
		}
		
		/** Returns a copy of the position of this button
		 * @return {Struct.Vector2} */
		static GetPosition = function() {
			return bbox.GetPosition();
		}
		
		/** Set the position of this `BBox`
		 * @arg {Struct.Vector2} _position
		 * @return {Undefined} */
		static SetPosition = function(_position) {
			bbox.SetPosition(_position)
		}
		
		/** Returns a copy of the size of this `BBox`
		 * @return {Struct.Vector2} */
		static GetSize = function() {
			return bbox.GetSize();
		}
		
		/** Set the size of this `BBox`
		 * @arg {Struct.Vector2} _size
		 * @return {Undefined} */
		static SetSize = function(_size) {
			bbox.SetSize(_size);
		}
		
		/** Returns a copy of the struct of verbs assigned to this button
		 * @return {Struct.InputVirtualButtonVerbs} */
		static GetVerbs = function() {
			return variable_clone(verbs);
		}
		
		/** Returns a copy of the starting position of a touch point
		 * @return {Struct.Vector2} */
		static GetTouchStartPosition = function() {
			return variable_clone(touchStartPos, 0);
		}
		
		/** Returns the current position of a touch point
		 * @return {Struct.Vector2} */
		static GetTouchPosition = function() {
			return touchPos;
		}
		
		/** Returns the type of bbox being used by the shape as an `Enum.Input_VirtualButtonBBoxType` value
		 * @return {Real} */
		static GetBBoxType = function() {
			return bboxType;
		}
		
		/** Set the draw type to use for the bbox.
		 * @arg {Enum.Input_VirtualButtonBBoxType} _type The draw type to to set.
		 * @return {Undefined} */
		static SetBBoxDrawType = function(_type) {
			bboxType = _type;
		}
		
		/** Returns if this `InputVirtualButton` is supposed to follow touch points (true) or not (false)
		 * @return {Bool} */
		static GetFollow = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.follow);
		}
		
		/** Set whether or not this `InputVirtualButton` should follow touch points or not
		 * @arg {Bool} _bool Set true to follow touch points.
		 * @return {Undefined} */
		static SetFollow = function(_bool) {
			flags.SetBitState(Input_VirtualButtonFlags.follow, _bool);
		}
		
		/** Returns the currently assigned release policy as an `Enum.Input_VirtualButtonReleasePolicy` value
		 * @return {Real} */
		static GetReleasePolicy = function() {
			return releasePolicy;
		}
		
		/** Allows you to set the release policy for this `InputVirtualButton`
		 * @arg {Enum.Input_VirtualButtonReleasePolicy} _policy
		 * @return {Undefined} */
		static SetReleasePolicy = function(_policy) {
			releasePolicy = _policy;
		}
		
		/** Returns if this `InputVirtualButton` supports only the first touch (true) or not (false)
		 * @return {Bool} */
		static GetFirstTouch = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.firstTouch);
		}
		
		/** Set whether or not this `InputVirtualButton` should only support the first touch or not
		 * @arg {Bool} _bool Set true to support only the first touch.
		 * @return {Undefined} */
		static SetFirstTouch = function(_bool) {
			flags.SetBitState(Input_VirtualButtonFlags.firstTouch, _bool);			
		}
		
		/** Returns the reference point policy for `InputVirtualButtons` that follow touch points. The return is a value from `Enum.Input_VirtualButtonReferencePolicy`
		 * @return {Real} */
		static GetReferencePolicy = function() {
			return reference;
		}
		
		/** Set the reference policy for `InputVirtualButtons` that follow touchpoints
		 * @arg {Enum.Input_VirtualButtonReferencePolicy} _policy
		 * @return {Undefined} */
		static SetReferencePolicy = function(_policy) {
			reference = _policy;			
		}
		
		/** Returns if this `InputVirtualButton` is allowed to be held down (true) or not (false)
		 * @return {Bool} */
		static GetHoldable = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.holdable);
		}
		
		/** Set if this `InputVirtualButton` is allowed to be held down (true) or not (false)
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetHoldable = function(_bool) {
			flags.SetBitState(Input_VirtualButtonFlags.holdable, _bool);				
		}
		
		/** Returns if this `InputVirtualButton` is being held in the current frame or not
		 * @return {Bool} */
		static GetHeld = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.held);
		}
		
		/** Returns if this `InputVirtualButton` was held in the previous frame or not
		 * @return {Bool} */
		static GetPreviouslyHeld = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.prevHeld);
		}
		
		/** Returns if this button is currently enabled or not
		 * @return {Bool} */
		static GetEnabled = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.active);
		}
		
		/** Change if the button is currently enabled or not. A diasabled button will not detect input
		 * @arg {Bool} _enable Set true to activate the button. Set false to deactivate it.
		 * @return {Undefined} */
		static SetEnabled = function(_enable = true) {
			if (IsDestroyed()) {
				return;
			}
			
			if (!_enable) {
				ClearState();
			}
			flags.SetBitState(Input_VirtualButtonFlags.active, _enable);
		}
		
		/** Resets this button back to its default state
		 * @return {Undefined} */
		static ClearState = function() {
			flags.DisableBitGroup([
				Input_VirtualButtonFlags.prevHeld,
				Input_VirtualButtonFlags.held,
				Input_VirtualButtonFlags.heldBuffer
			]);
			
			touchStartPos = undefined;
			touchPos = undefined;
			
			if (IsHistoryEnabled()) {
				historyCount = 0;
				history = [];
			}
			
			//Reset position
			if (releasePolicy == Input_VirtualButtonReleasePolicy.reset) { 
				bbox.SetPosition(startPos.Clone());
				bbox.SetSize(startSize.Clone());
			}
			else if (releasePolicy == Input_VirtualButtonReleasePolicy.destroy) {
				Destroy();
			}
		}	
		
		
		/** Input collection method for virtual buttons
		 * @arg {Array<Real>} _valueRawArray Array to store collected raw verb values
		 * @arg {Array<Real>} _valueClampArray Array to store collected clamped verb values
		 * @return {Undefined} */
		static Collect = function(_valueRawArray, _valueClampArray) {
			//Required collect conditions
			if (IsDestroyed() || is_undefined(touchPointIndex)) {
				flags.DisableBit(Input_VirtualButtonFlags.held);
				return;
			}
			
			//Cache conditionals
			//var _prevHeld = GetPreviouslyHeld();
			//var _held = GetHeld();
			//var _momentary = GetHoldable();
			
			//Virtual button was released
			if (GetPreviouslyHeld() && !GetHeld()) {
				ClearState();
				
				//Early exit if ClearState destroyed this button
				if (IsDestroyed()) {
					return;
				}
			}
			
			//Verify the virtual button is being pressed for the current frame
			flags.SetBitState(Input_VirtualButtonFlags.prevHeld, _held);
			var _currentFrame = inputSystem.GetFrame();
			var _capFrameIsCurrent = (captureFrame == _currentFrame);
			
			//Indicates TouchPointCapture() was successfully called and captured touchPoint positional data
			if (_capFrameIsCurrent) {
				//Since a touch point was captured, we need to process it, even if our state was cleared.
				flags.SetBitState(Input_VirtualButtonFlags.held, true);
				prevPos = FindTouchPosition(touchPointIndex);
			}
			
			
			//We're not being held, so we have no previous position. 
			//unset and skip the rest of the collect call
			if (!GetHeld()) {
				prevPos = undefined;
			}
			//We have positional data to process
			else {
				var _sustain;
				
				if (GetHoldable()) {
					_sustain = _capFrameIsCurrent;
				}
				else {
					_sustain = device_mouse_check_button(touchPointIndex, mb_left);
					
					//Guard against IOS devices dropping a sustained hold on SystemGestureGate timeout
					if (INPUT_IOS) {
						if (!_sustain && (_currentFrame - captureFrame) > 20) {
							flags.ToggleBit(Input_VirtualButtonFlags.heldBuffer);
							if (flags.IsBitActive(Input_VirtualButtonFlags.heldBuffer)) {
								_sustain = true;
							}
						}
					}
				}
				
				//the press wasn't sustained so we won't have data to process.
				//unset and skip the rest of the collect call.
				if (!_sustain) {
					flags.SetBitState(Input_VirtualButtonFlags.held, false);
				}
				
				//Data is available to process
				else {
					
					var _verbClick = verbs.click;
					if (!is_undefined(_verbClick)) {
						
						_valueRawArray[_verbClick] = 1;
						_valueClampArray[_verbClick] = 1;
					}
					
					prevPos = touchPos.Clone();
					
					if (!INPUT_IOS || !flags.IsBitActive(Input_VirtualButtonFlags.heldBuffer)) {
						touchPos = FindTouchPosition(touchPointIndex);
					}
					
					if (IsHistoryEnabled()) {
						HistoryPush(touchPos);
					}
					
					//Force delta for touchpads
					var _reference = (is_instanceof(self, InputVirtualButtonTouchpad)) ? Input_VirtualButtonReferencePolicy.delta : reference;
					var _position = bbox.position;
					var _d;
					switch (_reference) {
						case Input_VirtualButtonReferencePolicy.center:
							_d = touchPos.Subtract(_position);
						break;
						
						case Input_VirtualButtonReferencePolicy.touchPoint:
							_d = touchPos.Subtract(touchStartPos);
						break;
						
						case Input_VirtualButtonReferencePolicy.delta:
							_d = touchPos.Subtract(prevPos);
						break;
						
						default:
							var _err = ExceptionMessage("Collect", $"Reference point type {_reference} not supported");
							ThrowException("Input Error!", _err);
						break;
					}
					
					var _direction = _d.Normalized();
					
					//Button follows the input touch
					if (flags.IsBitActive(Input_VirtualButtonFlags.follow)) {
						var _moveDist;
						
						if (bboxType == Input_VirtualButtonBBoxType.circular) {
							//SDF of a circle
							_moveDist = _direction.Abs().Subtract(bbox.radius).Magnitude();
						}
						else if (bboxType == Input_VirtualButtonBBoxType.rectangular) {
							//SDF of a rectangle
							var _v = _d.Abs().Subtract(bbox.radius);
							_moveDist = _v.Max(0).Add(min(max(_v.x, _v.y), 0)).Magnitude();
						}
						
						var _newPosition = bbox.position.MoveTowardsPoint(_d, _moveDist)
						bbox.SetPosition(_newPosition);
					}
					
					
					if (_d.MagnitudeSqr() > 0) {
						ButtonFollowCapture(_valueRawArray, _valueClampArray, _direction, _d);
					}
				}
			}
		}			
		
	#endregion	
	
	
	#region Touchpoints
		
		#region Classes
			/** Creates a struct to store touch point data
			 * 
			 * @arg {Real} _touchIndex The index of the touch point
			 * @arg {Struct.Vector2} _initialPosition The initial position of the touch
			 * @return {Struct.InputVirtualButton$$TouchPoint} */
			static TouchPoint = function(_touchIndex, _initialPosition, _button) constructor {
				touchIndex = _touchIndex;						//The position of this point in the buttons history array
				position = _initialPosition						//Current position of the touch point
				startingPos = position.Clone();					//Initial starting position of the point
			}			
		#endregion
		
		
		/** Capture the position of a touch input on this button. Returns `true` if touch was detected and captured. Otherwise, returns `false`
		 * @arg {Real} _touchIndex The index of a touch point to try and capture.
		 * @return {Bool} */
		static TouchpointCapture = function(_touchIndex) {
			//Verifying touch captures are allowed
			var _touchDevice = is_undefined(touchPointIndex);
			var _enabled = GetEnabled();
			var _firstTouch = flags.IsBitActive(Input_VirtualButtonFlags.firstTouch);
			var _isGamepad = (_touchIndex > 0);
			if (!_touchDevice || !_enabled || (_firstTouch && _isGamepad)) {
				return false;
			}
			
			//Make Sure BBox is updated since we're directly accessing its data
			bbox.OnDirty();
			
			//Getting the position of the touch point
			var _touchPosition = FindTouchPosition(_touchIndex);
			
			//Check if touch point is over this button
			var _over = false;
			if (IsCircular()) {
				_over = point_in_circle(_touchPosition.x, _touchPosition.y, bbox.position.x, bbox.position.y, bbox.radius.x);
			}
			else {
				_over = point_in_rectangle(_touchPosition.x, _touchPosition.y, bbox.topLeft.x, bbox.topLeft.y, bbox.bottomRight.x, bbox.bottomRight.y);
			}
			
			//If the point is over this button, create a representation for it
			if (_over) {
				
				touchStartPos = _touchPosition;
				touchPos = _touchPosition.Clone();
				var _touchPoint = new TouchPoint(_touchIndex, _touchPosition);
				if (IsHistoryEnabled()) {
					HistoryPush(_touchPoint);
				}
				
				//Setup touch device
				touchPointIndex = _touchIndex;
				captureFrame = inputSystem.GetFrame();
			}
			return _over;
		}
		
		/** Returns the angle direction (in degrees) that a touch input slid in for the the given frame of reference.
		 * @arg {Real} _frame The frame of the touch point
		 * @return {Real} */
		static TouchpointDirection = function(_frame = INPUT_VIRTUAL_BUTTON_HISTORY_FRAMES) {
			var _touch0 = history[0];
			var _touchN = GetHistoryFrame(_frame);
			if (is_undefined(_touchN) || is_undefined(_touch0)) {
				return 0;
			} 
			return _touch0.position.Direction(_touchN.position);
		}
		
		/** Returns the total travel distance of a touch point up to the given frame of reference. Returns `-1` if no touch point data exists for the provided frame.
		 * @arg {Real} _frame The frame of the touch point
		 * @return {Real} */
		static TouchpointDistance = function(_frame = INPUT_VIRTUAL_BUTTON_HISTORY_FRAMES) {
			var _distance = -1;
			var _point0 = history[0];
			var _pointN = GetHistoryFrame(_frame);
			
			//Calculate exact distance by looping through each recorded position of the touch point
			if (!is_undefined(_pointN)) {
				var i = 1; repeat(_frame) {
					_distance += _point0.position.Distance(_pointN.position);
					_point0 = _pointN;
					_pointN = history[i++];
				}				
			}
			
			return _distance;
		}
		
		/** Returns the speed of travel for a touch point at the given frame of reference. Returns `-1` if a touch point for the given frame doesn't exist
		 * @arg {Real} _frame The frame to use for touch point calculation
		 * @return {Real} */
		static TouchpointSpeed = function(_frame = INPUT_VIRTUAL_BUTTON_HISTORY_FRAMES) {
			var _dist = TouchpointDistance(_frame);
			if (_dist == -1) {
				return _dist;
			}
			
			return _dist/_frame;
		}	
			
	#endregion
	
	
	
	#region History
		
		/** Checks if this button records touch history.
		 * @return {Bool} */
		static IsHistoryEnabled = function() {
			return flags.IsBitActive(Input_VirtualButtonFlags.historyEnabled);
		}		
		
		/** Returns the entire history of touch point positions. Returns `undefined` if this button has been destroyed.
		 * @return {Array<Struct.Vector2>} */
		static GetHistory = function() {
			//Can only return if not destroyed
			if (!IsDestroyed()) {
				return history;
			}
		}
		
		/** Returns the `TouchPoint` input history for the given `_frame` index. Returns `undefined` if the frame has no history or if the button has been destroyed.
		 * @arg {Real} _frame The frame number to return history for.
		 * @return {Struct.InputVirtualButton$$TouchPoint} */		
		static GetHistoryFrame = function(_frame = INPUT_VIRTUAL_BUTTON_HISTORY_FRAMES) {
			var _destroyed = IsDestroyed();
			var _inBounds = ArrayIsIndexInBounds(history, 0, INPUT_VIRTUAL_BUTTON_HISTORY_FRAMES);
			if (IsDestroyed() || !_inBounds) {
				return;
			}
			
			//Limit history to the number of frames that have been recorded
			_frame = min(historyCount - 1, _frame, INPUT_VIRTUAL_BUTTON_HISTORY_FRAMES);	
			return history[_frame];
		}
		
	#endregion	
}