//feather ignore all

/** InputPointer: Helper class for `InputSystem` thats used to track mouse/touch inputs.
 * @ignore
 * @arg {Real} _pointerIndex The mouse index this pointer should use when updating positions
 * @return {Struct.InputPointer} */
function InputPointer(_pointerIndex = 0) constructor {
	
	#region Private
		///@ignore
		pointerIndex = _pointerIndex;					//Pointer index for position retrieval functions. 
		///@ignore
		position = new Vector2();						//Pointer device position
		///@ignore
		prevPosition = new Vector2();					//previous pointer position (in device space)
		///@ignore
		roomPosition = new Vector2();					//Room position
		///@ignore
		guiPosition = new Vector2();					//GUI position
	#endregion
	
	
	
	
	
	#region Positions
		/** Returns if this `InputPointer` has moved from its previous position or not
		 * @return {Bool} */
		static GetMoved = function() {
			return (!prevPosition.Equals(position));
		}
		
		/** Returns the internal mouse index number that's used to update pointer positions.
		 * @return {Real} */
		static GetPointerIndex = function() {
			return pointerIndex;
		}
		
		/** Returns the previous position of this pointer
		 * @return {Struct.Vector2} */
		static GetPreviousPosition = function() {
			return prevPosition.Clone();
		}
		
		/** Returns the current position of this pointer in device space
		 * @return {Struct.Vector2} */
		static GetDevicePosition = function() {
			return position.Clone();
		}
		
		/** Returns the current room position of this pointer
		 * @return {Struct.Vector2} */
		static GetRoomPosition = function() {
			return roomPosition.Clone();
		}
		
		/** Returns the current position of this pointer in GUI space
		 * @return {Struct.Vector2} */
		static GetGUIPosition = function() {
			return guiPosition.Clone();
		}
		
		/** Updates the position of the the pointer
		 * @return {Undefined} */
		static UpdatePosition = function() {
			var _x, _y;
			if (INPUT_WINDOWS) {
				_x = display_mouse_get_x() - window_get_x();
				_y = display_mouse_get_y() - window_get_y();				
			}
			else {
				_x = device_mouse_raw_x(pointerIndex);
				_y = device_mouse_raw_y(pointerIndex);
			}
			position.Set(_x, _y);
		}
		
		/** Updates the position of the pointer using raw coordinate system
		 * @return {Undefined} */
		static UpdatePositionRaw = function() {
			position.Set(device_mouse_raw_x(pointerIndex), device_mouse_raw_y(pointerIndex));
		}
		
		/** Updates the GUI position of the mouse
		 * @return {Undefined} */
		static UpdateGUIPosition = function() {
			guiPosition.Set(device_mouse_x_to_gui(pointerIndex), device_mouse_y_to_gui(pointerIndex));
		}
		
		/** Updates the room position vector of the pointer
		 * @return {Undefined} */
		static UpdateRoomPosition = function() {
			roomPosition.Set(device_mouse_x(pointerIndex), device_mouse_y(pointerIndex));
		}
		
		/** Updates the previous position of the pointer
		 * @return {Undefined} */
		static UpdatePreviousPosition = function() {
			prevPosition.SetFromVector(position);
		}
		
		
	#endregion
	
	
}