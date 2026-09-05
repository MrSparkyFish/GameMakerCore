//feather ignore all

/**
 * @arg {Real} _playerIndex
 * @return {Struct.InputCursorPlayer} */
function InputCursorPlayer(_playerIndex) constructor {
	
	static inputSystem = InputSystem.singleton;
	playerIndex = _playerIndex;
	speed = INPUT_CURSOR_DEFAULT_SPEED;
	position = new Vector2();
	prevPosition = new Vector2();				
	elasticPosition = undefined;
	elasticStrength = 0;
	
	limitType = Input_CursorLimitType.none;
	limitPoint = new Vector2();
	limitRadius = 0;
	limitMin = new Vector2();								//Minimum xy limit
	limitMax = new Vector2();								//Maximum xy limit
	limitMargin = 0;
	
	boundsTopLeft = new Vector2();
	boundsBottomRight = new Vector2();
	
	static Update = function() {
		//Update prev position
		prevPosition.SetFromVector(position);
		
		//Finding where the cursor is currently at
		var _player = inputSystem.GetPlayer(playerIndex);
		if (INPUT_CURSOR_MOUSE_CONTROL && _player.UsesKbm()) {
			if (INPUT_CURSOR_PRIMARY_COORD_SPACE == Input_CursorSpace.roomSpace) {
				position.SetFromVector(inputSystem.PointerGetRoomPosition());
			}
			else if (INPUT_CURSOR_PRIMARY_COORD_SPACE == Input_CursorSpace.guiSpace) {
				position.SetFromVector(inputSystem.PointerGetGuiPosition());
			}
			else if (INPUT_CURSOR_PRIMARY_COORD_SPACE == Input_CursorSpace.deviceSpace) {
				position.SetFromVector(inputSystem.PointerGetDevicePosition());
			}
		}
		//Calculating cursor position manually
		else {
			var _systemComponent = inputSystem.RequestSystemComponent(playerIndex);
			var _dxdy = _systemComponent.ClusterPosition(INPUT_CURSOR_CLUSTER);
			_dxdy.Multiply(speed);
			
			if (INPUT_CURSOR_EXPONENT != 1) {
				var _coef = power(_dxdy.Magnitude(), INPUT_CURSOR_EXPONENT);
				_dxdy.Multiply(_coef);
			}
			position.Add(_dxdy);
			
			//Scaling position
			if (elasticStrength > 0) {
				position.x += (position.x - prevPosition.x) / elasticStrength;
				position.y += (position.y - prevPosition.y) / elasticStrength;
				
				var _lerp = position.LerpUnclamped(elasticPosition, elasticStrength);
				position.Set(_lerp.x, _lerp.y);
			}
		}
		
		Limit();
	}
	
	
	static Limit = function() {
		
		if (limitType == Input_CursorLimitType.circle) {
			var _dxdy = position.Subtract(limitType);
			var _mag = _dxdy.Magnitude();
			
			if ((_mag > 0) && (_mag > limitRadius)) {
				var _mult = limitRadius/_mag;
				position.SetFromVector(_dxdy.Multiply(_mult).Add(limitPoint));
			}
		}
		
		else if (limitType == Input_CursorLimitType.aabb) {
			position.Clamp(limitMin, limitMax);
		}
		
		else if (limitType == Input_CursorLimitType.boundary) {
			
			if (INPUT_CURSOR_PRIMARY_COORD_SPACE == Input_CursorSpace.roomSpace) {
				var _camera = (view_enabled && view_visible[0]) ? view_camera[0] : undefined;
				if (_camera != undefined) {
					//Camera origin is on a corner, we need to find its center point
					boundsTopLeft.x = camera_get_view_x(_camera);				//left
					boundsTopLeft.y = camera_get_view_y(_camera);				//top
					boundsBottomRight.x = camera_get_view_width(_camera) - 1;	//right
					boundsBottomRight.y = camera_get_view_height(_camera) - 1;	//bottom
					var _viewAngle = camera_get_view_angle(_camera);
					
					if (_viewAngle != 0.0) {
						//Find our pivot (center) point. 
						var _pivot = boundsTopLeft.Add(boundsBottomRight);
						_pivot.Multiply(0.5);
						_viewAngle = radtodeg(_viewAngle);
						position.RotateAround(_viewAngle, _pivot);
					}
				}
				
				else {
					//Fall back to rooms dimensions
					boundsTopLeft.Set(0, 0);
					boundsBottomRight.Set(room_width, room_height);
				}
			}
			
			
			if (INPUT_CURSOR_PRIMARY_COORD_SPACE == Input_CursorSpace.guiSpace) {
				boundsTopLeft.Set(0, 0);
				boundsBottomRight.Set(display_get_gui_width(), display_get_gui_height());
			}
			
			else if (INPUT_CURSOR_PRIMARY_COORD_SPACE == Input_CursorSpace.deviceSpace) {
				boundsTopLeft.Set(0, 0);
				boundsBottomRight.Set(window_get_width(), window_get_height());
			}
			
			limitMin.Set(limitMargin + boundsTopLeft.x, limitMargin + boundsTopLeft.y);
			limitMax.Set(limitMargin + boundsBottomRight.x, limitMargin + boundsBottomRight.y);
			position.Clamp(limitMin, limitMax);
		}
	}
}