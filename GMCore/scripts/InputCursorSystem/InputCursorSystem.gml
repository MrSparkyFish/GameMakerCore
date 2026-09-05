//feather ignore all

/** InputCursorSystem: An `InputSystem` plug-in that provides fine tuned control over mouse position
 * @return {Struct.InputCursorSystem} */
function InputCursorSystem() constructor {
	
	//Coordinate spaces for cursors
	enum Input_CursorSpace {
		roomSpace,										//"World Space"
		guiSpace,										//Any gui space (GUI, Draw GUI, etc)
		deviceSpace										//Window coordinates (if the game is in windowed mode on desktop) or the entire sceen if not in windowed mode.
	}
	
	//Limit types that can be applied to the cursor
	enum Input_CursorLimitType {
		boundary,
		aabb,
		circle,
		none
	}
	
	//The coordinate space that cursors should exist in. You can convert between coordinate spaces when
	//getting cursor values but the elastic and limit features will only be applied in the primary
	//coordinate space.
	#macro INPUT_CURSOR_PRIMARY_COORD_SPACE  Input_CursorSpace.roomSpace
	
	//Whether a player's cursor should follow the mouse when using the `INPUT_KBM` deivce (keyboard
	//and mouse). Set this macro to `false` to make the keyboard move the cursor via the cluster
	//defined below.
	#macro INPUT_CURSOR_MOUSE_CONTROL  true
	
	//Optional Cluster to read to move cursors when using a gamepad or keyboard. This cluster should be defined
	//alongside verbs and other clusters in `InputDictionary`; for example, Input_Cluster.navigation.
	//After being defined in the dictionary, replace the `-1` with the enumerated cluster.
	#macro INPUT_CURSOR_CLUSTER  -1
	
	//Default speed of the cursor when using a gamepad or keyboard. This value is measured in pixels
	//per frame and as such is *not* inherently delta-timed. You can change the cursor speed at runtime
	//by calling `InputCursorSetSpeed()`.
	#macro INPUT_CURSOR_DEFAULT_SPEED  8
	
	//Movement exponent, applied when using a gamepad or keyboard. This value is very sensitive to
	//change it slowly whilst testing!
	#macro INPUT_CURSOR_EXPONENT  1
	
	
	#region Private
	    //Build out lots of cached values
	    //We use these to detect changes that might trigger a recalculation of application_get_position()
	    //Doing all this work is faster than calling application_get_position() all the time
		static windowSize = new Vector2();							//Size of the window xy = width,height
		static appSurfSize = new Vector2();							//Size of the surface xy = width,height
		static appSurfDrawPositions = new Vector4();				//Coordinates of the draw surface. [left(X), top(Y), right(Z), bottom(W)] 
		static appSurfDrawSize = new Vector2();						//Holds the size of the drawing surface
		static viewPort = new Vector4();							//Holds the origin point (XY) and size (ZW) of the view port
		static viewAngle = 0;										//Cache the view angle
	    static recacheTime  = -infinity;							//Used as basic timer for caching corner positions
		static coordinate = new Vector2();							//Our transformation point
		static inputSystem = InputSystem.singleton;
		
		cursors = array_create(INPUT_MAX_PLAYERS);
		for (var i = 0; i < INPUT_MAX_PLAYERS; i++) {
			cursors[i] = new InputCursorPlayer(i);
		}
		
		/**
		 * 
		 * @arg {Struct.Vector2} _vector The vector to transform
		 * @return {Struct.Vector2} */
		static CursorTransformCoordinate = function(_vector, _fromSpace, _toSpace, _camera = undefined) {
			
			//Only convert from one coordinate space to the next if they're actually different spaces
			if (_fromSpace != _toSpace) {
				
				//Update the cached camera properties for roomSpace conversions.
				if ((_fromSpace == Input_CursorSpace.roomSpace) || (_toSpace == Input_CursorSpace.roomSpace)) {
					//Cache the view port, Default to room dimensions
					viewPort.Set(0, 0, room_width, room_height);
					viewAngle = 0;
					
					if (is_undefined(_camera) && view_enabled && view_visible[0]) {
						_camera = view_camera[0];
						viewAngle = camera_get_view_angle(_camera);		
		                viewPort.Set(
							camera_get_view_x(_camera), 
							camera_get_view_y(_camera),
							camera_get_view_width(_camera), 
							camera_get_view_height(_camera)
						);
					}
				}
				
				//Update the cached surface and camera properties for device space tranformations
				if ((_fromSpace == Input_CursorSpace.deviceSpace) || (_toSpace) == Input_CursorSpace.deviceSpace) {
					var _appSurfW = surface_get_width(application_surface);
					var _appSurfH = surface_get_height(application_surface);
					var _windowW = window_get_width();
					var _windowH = window_get_height();
					
					//Cache surface size if its changed
					if ((appSurfSize.x != _appSurfW) || (appSurfSize.y != _appSurfH)) {
						appSurfSize.Set(_appSurfW, _appSurfH);
						recacheTime = -infinity;
					}
					
					//Cache positions if needed
					if (current_time > recacheTime) {
						recacheTime = infinity;
						appSurfDrawPositions.SetFromArray(application_get_position());
						appSurfDrawSize.Set(
							appSurfDrawPositions.z - appSurfDrawPositions.x,
							appSurfDrawPositions.w - appSurfDrawPositions.y
						);
					}
					
					//Cache window size if it has changed
					if ((windowSize.x != _windowW) || (windowSize.y != _windowH)) {
						windowSize.Set(_windowW, _windowH);
						recacheTime = current_time + 200; //effectively sets a timer for 200ms to allow GM time to update properly
					}
				}
				
				//Normalizing the input vector to the space it's converting from
				if (_fromSpace == Input_CursorSpace.roomSpace) {
					//Normalize the vector to roomspace using the viewport
					_vector.x = (_vector.x - viewPort.x) / viewPort.z;
					_vector.y = (_vector.y - viewPort.y) / viewPort.z;
					
				}
				else if (_fromSpace == Input_CursorSpace.guiSpace) {
					//Normalize vector to gui space
					_vector.x /= display_get_gui_width();
					_vector.y /= display_get_gui_height();
				}
				//Converting from device space
				else if (_fromSpace == Input_CursorSpace.deviceSpace) {
					//Normalize to device space
					_vector.x = (_vector.x - appSurfDrawPositions.x) / appSurfDrawSize.x;
					_vector.y = (_vector.y - appSurfDrawPositions.y) / appSurfDrawSize.y;
					
				}
				
				
				//Once normalized to the appropriate "from" space, we can should be able to easily transform into the "to" space
				//Transform matrix vars.
				var _tx = 0;	
				var _ty = 0;
				var _sx = 1;
				var _sy = 1;
				var _r = 0;
				
				
				//Set vars to build matrix that converts to roomSpace
				if (_toSpace == Input_CursorSpace.roomSpace) {
					_tx = viewPort.x;
					_ty = viewPort.y;
					_r = viewAngle;
				}
				
				//Set vars to build matrix that converts to guiSpace
				else if (_toSpace == Input_CursorSpace.guiSpace) {
					_sx = display_get_gui_width();
					_sy = display_get_gui_width();
				}
				
				//Set vars to build matrix that converts to guiSpace
				else if (_toSpace == Input_CursorSpace.deviceSpace) {
					_sx = appSurfDrawSize.x;
					_sy = appSurfDrawSize.y;
					_tx = appSurfDrawPositions.x;
					_ty = appSurfDrawPositions.y;					
				}
				
				else {
					inputSystem.ThrowInputError("BuildTransformationMatrix", "Invalid 'toSpace' coordinate system", self);
				}	
				
				//Build the matrix that will transform the vector to the appropriate space
				//2D rotations by transform matrix are applied using the z-axis.
				var _matrix = matrix_build(_tx, _ty, 0, 0, 0, _r, _sx, _sy, 1);
				_vector.Transformation(_matrix);			
			}
			return _vector;
		}
		
		/** 
		 * @arg {Real} _playerIndex The input player that was updated
		 * @return {Undefined} */
		static OnUpdatePlayer = function(_playerIndex) {
			//Give the player a cursor handler
			cursors[_playerIndex].Update();
		}
		
	#endregion
	
	
	/** Returns a vector that is the difference between the current and previous position of a player's cursor in the coordinate space of your choosing.
	 * @arg {Real} _playerIndex The player to get the cursor position for
	 * @arg {Enum.Input_CursorSpace} [_coordSpace] `[=INPUT_CURSOR_PRIMARY_COORDSPACE]` The coordinate space to get position in
	 * @return {Struct.Vector2} */
	static CursorGetDistanceTraveled = function(_playerIndex, _coordSpace = undefined) {
		var _cursor = cursors[_playerIndex];
		var _position = _cursor.position.Subtract(_cursor.prevPosition);
		CursorTransformCoordinate(_position, INPUT_CURSOR_PRIMARY_COORD_SPACE, _coordSpace ?? INPUT_CURSOR_PRIMARY_COORD_SPACE);
		return _position;
	}
	
	/** Returns a vector that is the difference between the current and previous position of a player's cursor in the coordinate space of your choosing.
	 * @arg {Real} _playerIndex The player to get the cursor position for
	 * @arg {Enum.Input_CursorSpace} [_coordSpace] `[=INPUT_CURSOR_PRIMARY_COORDSPACE]` The coordinate space to get position in
	 * @return {Struct.Vector2} */	
	static CursorGetPosition = function(_playerIndex, _coordSpace = undefined) {
		var _position = cursors[_playerIndex].position.Clone();
		CursorTransformCoordinate(_position, INPUT_CURSOR_PRIMARY_COORD_SPACE, _coordSpace ?? INPUT_CURSOR_PRIMARY_COORD_SPACE);
		return _position;		
	}
	
	/** Set the position of the player's cursor in its global coordinate space, as determined by `INPUT_CURSOR_PRIMARY_COORD_SPACE`
	 * @arg {Struct.Vector2} _vector The position to set
	 * @arg {Real} _playerIndex The player to set cursor position for
	 * @return {Undefined} */
	static CursorSetPosition = function(_position, _playerIndex) {
		if (!variable_instance_exists(_position, "x") && !variable_instance_exists(_position, "y")) {
			ThrowInterfaceNotImplemented("CursorSetPosition", _position, "Vector2", self);
		}
		cursors[_playerIndex].position.SetFromVector(_position);
	}
	
	
	/** Returns the speed of the player's cursor in pixels per frame
	 * @arg {Real} _playerIndex The index of the player to get cursor speed from
	 * @return {Real} */
	static CursorGetSpeed = function(_playerIndex) {
		return cursors[_playerIndex].speed;
	}
	
	/** Set the speed of a player's cursor. Speed is measured in pixels per frame and therefore isn't inherently delta-timed. 
	 * @arg {Real} _speed The speed to set
	 * @arg {Real} _playerIndex The player to set speed for
	 * @return {Undefined} */
	static CursorSetSpeed = function(_speed, _playerIndex) {
		if (!AssertIsNumeric(_speed)) {
			inputSystem.ThrowInputError("CursorSetSpeed", $"_speed must be a numerical value", self);
		}
		cursors[_playerIndex].speed = _speed;
	}
	
	/** Returns a struct of the elastic properties for a player's cursor. If no elastic properties have been set, then `enabled` will be
	 * set to `false` and all other members will be set to `undefined`
	 * ***
	 * * enabled - If elasticity has been enabled
	 * * position - The elastic cursor position
	 * * strength - Elasticity strength
	 * @arg {Real} _playerIndex The index of the player to get cursor properties for
	 * @return {Struct} */
	static ElasticGet = function(_playerIndex) {
		var _cursor = cursors[_playerIndex];
		var _enabled = _cursor.elasticEnabled;
		var _result = {
			enabled : _enabled,
			position : undefined,
			strength : undefined
		}
		
		if (_enabled) {
			_result.position = _cursor.elasticPosition;
			_result.strength = _cursor.elasticStrength;
		}
		
		return _result;
	}
	
	/** Set up a springy force that pulls the cursor towards the given point. This is useful for building aiming systems and works especially
	 * well with `LimitCircle()`. The center position of the force should be in `INPUT_CURSOR_PRIMARY_COORD_SPACE`. 
	 * @arg {Real} _x 
	 * @arg {Real} _y
	 * @arg {Real} _strength A normalized value between `0` and `1`
	 * @arg {Real} _playerIndex The player to set elasticity for
	 * @arg {Bool} [_moveCursor] `[=true]` If the cursor should move by the same amount that the center of the elastic force has moved. Convenient for shots where the elastic force is centered on the player and moving the force would also need to move the cursor by the same amount
	 * @return {Undefined} */
	static ElasticSet = function(_x, _y, _strength, _playerIndex, _moveCursor = undefined) {
		_moveCursor ??= true;
		
		var _cursor = cursors[_playerIndex];
		var _elasticPosition = _cursor.elasticPosition;
		if (_moveCursor && _cursor.elasticEnabled) {
			_cursor.position.Subtract(_elasticPosition);
		}
		
		_elasticPosition.Set(_x, _y);
		_cursor.elasticStrength = _strength;
		_cursor.elasticEnabled = true;
	}
	
	/** Remove the elastic properties for a player's cursor
	 * @arg {Real} _playerIndex The player to remove elasticity from
	 * @return {Undefined} */
	static ElasticRemove = function(_playerIndex) {
		var _cursor = cursors[_playerIndex];
		_cursor.elasticPosition.Set(0, 0);
		_cursor.elasticStrength = 0;
		_cursor.elasticEnabled = false;
	}
	
	/** Limits the player's cursor position to an axis-aligned bounding box. The coordinates of the box are in pixels in coordinate space
	 * `INPUT_CURSOR_PRIMARY_COORD_SPACE`
	 * @arg {Real} _left 
	 * @arg {Real} _top
	 * @arg {Real} _right
	 * @arg {Real} _bottom
	 * @arg {Real} _playerIndex
	 * @return {Undefined} */
	static LimitAABB = function(_left, _top, _right, _bottom, _playerIndex) {
		var _cursor = cursors[_playerIndex];
		_cursor.limitType = Input_CursorLimitType.aabb;
		_cursor.boundsTopLeft.Set(_left, _top);
		_cursor.boundsBottomRight.Set(_right, _bottom);
	}
	
	/** Limits the player's cursor to the visible portion of the game window. Optionally specify a padded margin around the edge of the 
	 * game window (in pixels of the primary coordinate space)
	 * @arg {Real} _playerIndex The index of the player to limit
	 * @arg {Real} [_margin] `[=0]` Optional margin value
	 * @return {Undefined} */
	static LimitBoundary = function(_playerIndex, _margin) {
		var _cursor = cursors[_playerIndex];
		_cursor.limitType = Input_CursorLimitType.boundary;
		_cursor.limitMargin = _margin;
		_cursor.Limit();
	}
	
	/** Limit the player's cursor within the bounds of a circle
	 * @arg {Real} _x
	 * @arg {Real} _y
	 * @arg {Real} _radius
	 * @arg {Real} _playerIndex
	 * @return {Undefined} */
	static LimitCircle = function(_x, _y, _radius, _playerIndex) {
		var _cursor = cursors[_playerIndex];
		_cursor.limitType = Input_CursorLimitType.circle;
		_cursor.limitPoint.Set(_x, _y);
		_cursor.limitRadius = _radius;
		_cursor.Limit();
	}
	
	/** Removes cursor limits from the player's cursor
	 * @arg {Real} _playerIndex
	 * @return {Undefined} */
	static LimitRemove = function(_playerIndex) {
		cursors[_playerIndex].limitType = Input_CursorLimitType.none;
	}
	
	/** Returns limit data for the specified player's cursor
	 * @arg {Real} _playerIndex
	 * @return {Struct} */
	static LimitGet = function(_playerIndex) {
	    var _result = {
	        type:   INPUT_CURSOR_LIMIT_NONE,
	        x:      0,
	        y:      0,
	        radius: 0,
	        left:   0,
	        top:    0,
	        right:  0,
	        bottom: 0,
	        margin: 0,
	    };
	    
	    var _cursor = cursors[_playerIndex];
		var _limitType = _cursor.limitType;
		if (_limitType == Input_CursorLimitType.circle) {
			_result.type   = Input_CursorLimitType.circle;
			_result.x      = _cursor.limitPoint.x;
			_result.y      = _cursor.limitPoint.y;
			_result.radius = _cursor.limitRadius;
			_result.left   = undefined;
			_result.top    = undefined;
			_result.right  = undefined;
			_result.bottom = undefined;
			_result.margin = undefined;
		}
		else if (_limitType == Input_CursorLimitType.boundary)
		{
			_result.type   = Input_CursorLimitType.boundary;
			_result.x      = undefined;
			_result.y      = undefined;
			_result.radius = undefined;
			_result.left   = undefined;
			_result.top    = undefined;
			_result.right  = undefined;
			_result.bottom = undefined;
			_result.margin = _cursor.limitMargin;
		}
		else if (_limitType == Input_CursorLimitType.aabb)
		{
			_result.type   = Input_CursorLimitType.aabb;
			_result.x      = undefined;
			_result.y      = undefined;
			_result.radius = undefined;
			_result.left   = _cursor.boundsTopLeft.x;
			_result.top    = _cursor.boundsTopLeft.y;
			_result.right  = _cursor.boundsBottomRight.x;
			_result.bottom = _cursor.boundsBottomRight.y;
			_result.margin = undefined;
		}
		else {
			_result.type   = Input_CursorLimitType.none;
			_result.x      = undefined;
			_result.y      = undefined;
			_result.radius = undefined;
			_result.left   = undefined;
			_result.top    = undefined;
			_result.right  = undefined;
			_result.bottom = undefined;
			_result.margin = undefined;
	    }
	    
	    return _result;		
	}
}