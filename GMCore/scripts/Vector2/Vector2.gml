//feather ignore all

/** Vector2: Represents an instance of a 2D vector or a 2-tuple of real numbers.
 * ***
 * Implements: `IString`, `Vector2`
 * @arg {Real} x `[= 0]` Value of X
 * @arg {Real} y `[= 0]` Value of Y
 * @return {Struct.Vector2} */
function Vector2(x = 0, y = 0) constructor {
	self.x = x;
	self.y = y;
	
	/** Creates a new `Vector2` from an array
	 * @arg {Array<Real>} a The array to use. x = a[0], y = a[1]
	 * @return {Struct.Vector2} */
	static CreateFromArray = function(a) {
		return new Vector2(a[0], a[1]);
	}
	
	/** Returns a new direction vector (0, -1)
	 * @return {Struct.Vector2} */
	static Up = function() {
		return new Vector2(0, -1);
	}
	
	/** Returns a new direction vector (0, 1)
	 * @return {Struct.Vector2} */		
	static Down = function() {
		return new Vector2(0, 1);
	}
	
	/** Returns a new direction vector (-1, 0)
	 * @return {Struct.Vector2} */		
	static Left = function() {
		return new Vector2(-1, 0);
	}
	
	/** Returns a new direction vector (1, 0)
	 * @return {Struct.Vector2} */		
	static Right = function() {
		return new Vector2(1, 0);
	}
	
	/** Returns a new direction vector (-infinity, -infinity)
	 * @return {Struct.Vector2} */		
	static NegativeInfinity = function() {
		return new Vector2(-infinity, -infinity);
	}
	
	/** Returns a new direction vector (infinity, infinity)
	 * @return {Struct.Vector2} */		
	static PositiveInfinity = function() {
		return new Vector2(infinity, infinity);
	}	
	
	/** Set the X,Y value of the calling vector
	 * @return {Undefined} */
	static Set = function(x, y) {
		self.x = x;
		self.y = y;
	}
	
	/** Sets the XY values of the calling vector from an array where index 0 is used as the x value and index 1 is used as the y value
	 * @arg {Array<Real>} a The array to use when setting this vector
	 * @return {Undefined} */
	static SetFromArray = function(a) {
		self.x = a[0];
		self.y = a[1];
	}
	
	/** Returns the XY components of this vector as an array where index 0 holds the x value and index 1 holds the y value
	 * @return {Array<Real>} */
	static ToArray = function() {
		return [self.x, self.y];
	}
	
	/** Returns a copy of this vector
	 * @return {Struct.Vector2} */
	static Clone = function() {
		return new Vector2(self.x, self.y);
	}
	
	/** Returns this vector as a string
	 * @ignore
	 * @return {String} */
	static toString = function() {
		return $"({self.x}, {self.y})";
	}
	
	
	#region Operators
		
		/** Returns the sum of this vector and a value
		 * @arg {Real|Struct.Vector2} vec2alue
		 * @return {Struct.Vector2} */
		static Add = function(value) {
			if (is_numeric(value)) {
				return new Vector2(self.x + value, self.y + value)
			}
			return new Vector2(self.x + value.x, self.y + value.y);
		}
		
		/** Returns the difference between this vector and a value
		 * @arg {Real|Struct.Vector2} vec2alue 
		 * @return {Struct.Vector2} */
		static Subtract = function(value) {
			if (is_numeric(value)) {
				return new Vector2(self.x - value, self.y - value)
			}
			return new Vector2(self.x - value.x, self.y - value.y);
		}
		
		/** Returns the product of this vector and a value
		 * @arg {Real|Struct.Vector2} vec2alue
		 * @return {Struct.Vector2} */
		static Multiply = function(value) {
			if (is_numeric(value)) {
				return new Vector2(self.x * value, self.y * value)
			}
			return new Vector2(self.x * value.x, self.y * value.y);
		}
		
		/** Returns the quotient of this vector and a value
		 * @arg {Real|Struct.Vector2} vec2alue
		 * @return {Struct.Vector2} */
		static Divide = function(value) { 
			if (is_numeric(value)) {
				return new Vector2(self.x / value, self.y / value)
			}
			return new Vector2(self.x / value.x, self.y / value.y);			
		}
		
		/** Returns the dot product between this vector and another
		 * @arg {Struct.Vector2} vec2
		 * @return {Real} */
		static Dot = function(vec2) {
			return dot_product(self.x, self.y, vec2.x, vec2.y);
		}
		
		/** Returns the cross product between this vector and another resulting in a scalar value
		 * @arg {Struct.Vector2} vec2 
		 * @return {Real} */
		static Cross = function(vec2) {
			return (self.x * vec2.y) - (self.y * vec2.x);
		}		
		
		/** Returns the inverse of this vector. Its magnitude is kept unchanged. This is the same as multiplying `self * -1` or rotating it 180 degrees around the room origin.
		 * @return {Struct.Vector2} */
		static Inverse = function() {
			return new Vector2(-self.x, -self.y);
		}
		
		/** Returns true if the calling vector has a component value that is less than the value of the same component of `v`
		 * @arg {Struct.Vector2} vec2
		 * @return {Bool} */
		static LessThan = function(vec2) {
			if (self.x == vec2.x) {
				return (self.y < vec2.y);
			}
			return (self.x < vec2.x);
		}
		
		/** Returns true if the calling vector has a component value that is less than or equal to the value of the same component of `v`
		 * @arg {Struct.Vector2} vec2
		 * @return {Bool} */
		static LessThanOrEqualTo = function(vec2) {
			if (self.x == vec2.x) {
				return (self.y <= vec2.y);
			}
			return (self.x <= vec2.x);
		}
		
		/** Returns true if the calling vector has a component value that is greater than the value of the same component of `v`
		 * @arg {Struct.Vector2} vec2
		 * @return {Bool} */		
		static GreaterThan = function(vec2) {
			if (self.x == vec2.x) {
				return (self.y > vec2.y);
			}
			return (self.x > vec2.x);
		}
		
		/** Returns true if the calling vector has a component value that is greater than the value of the same component of `v`
		 * @arg {Real|Struct.Vector2} vec2
		 * @return {Bool} */		
		static GreaterThanOrEqualTo = function(vec2) {
			if (self.x == vec2.x) {
				return (self.y >= vec2.y);
			}
			return (self.x >= vec2.x);
		}
		
		/** Returns true if the this vectors components are equal to the value of the same component of `v`
		 * @arg {Real|Struct.Vector2} vec2
		 * @return {Bool} */
		static Equals = function(vec2) {
			return ((self.x == vec2.x) && (self.y == vec2.y));
		}
	#endregion
	
	
	#region Algebra
		
		/** Returns the absolute value of this vector
		 * @return {Struct.Vector2} */
		static Abs = function() {
			return new Vector2(abs(self.x), abs(self.y));
		}
		
		/** Returns the direction of the specified vector from the calling vector relative to the room origin (in degrees).
		 * @arg {Struct.Vector2} vec2
		 * @return {Real} */
		static Angle = function(vec2) {
			return point_direction(self.x, self.y, vec2.x, vec2.y);
		}
		
		/** Returns the direction of the specified vector from the calling vector relative to the room origin (in radians).
		 * @arg {Struct.Vector2} vec2
		 * @return {Real} */
		static AngleRadians = function(vec2) {
			return degtorad(point_direction(self.x, self.y, vec2.x, vec2.y));
		}
		
		/** Returns a vector that is the calling vector rounded up to its nearest integer values
		 * @return {Struct.Vector2} */				
		static Ceil = function() {
			return new Vector2(ceil(self.x), ceil(self.y));
		}
		
		/** Returns a vector that is the calling vector clamped to the specified min/max vectors
		 * @arg {Struct.Vector2} _min The lower limit vector 
		 * @arg {Struct.Vector2} _max The upper limit vector
		 * @return {Struct.Vector2} */
		static Clamp = function(_min, _max) {
			return new Vector2(clamp(self.x, _min.x, _max.x), clamp(self.y, _min.y, _max.y));
		}	
		
		/** Returns a vector that is the calling vector set to a maximum length. 
		 * @arg {Real} maxLength
		 * @return {Struct.Vector2} */
		static ClampMagnitude = function(maxLength) {
			var dist = (1/point_distance(0, 0, self.x, self.y)) * maxLength;
			return new Vector2(self.x * dist, self.y * dist);
		}
		
		/** Returns the angle of this vector in degrees from the origin of the room.
		 * @return {Struct.Vector2} */
		static Direction = function() {
			return point_direction(0, 0, x, y);
		}
		
		/** Returns the angle of this vector in radians from the origin of the room.
		 * @return {Real} */
		static DirectionRadians = function() {
			return degtorad(point_direction(0, 0, x, y));
		}
	
		/** Returns a direction vector that points in the direction of the specified target
		 * @arg {Struct.Vector2} target The target to get the direction of
		 * @return {Struct.Vector2} */
		static DirectionTarget = function(target) {
			return target.Subtract(self).Normalize();
		}
		
		/** Returns the distance between the calling vector and a point
		 * @arg {Struct.Vector2} vec2
		 * @return {Real} */
		static Distance = function(vec2) {
			return point_distance(self.x, self.y, vec2.x, vec2.y);
		}
		
		/** Returns a vector with swapped X and Y values
		 * @return {Struct.Vector2} */
		static Flip = function() {
			return new Vector2(self.y, self.x);
		}		
		
		/** Returns a vector that is this vector's component values rounded down to their nearest integer values.
		 * @return {Struct.Vector2} */				
		static Floor = function() {
			return new Vector2(floor(self.x), floor(self.y));
		}
		
		/** Returns a vector that is only the fractional part of the calling vector. That is, only the value that is behind the decimal of the components.
		 * @return {Struct.Vector2} */
		static Frac = function() {
			return new Vector2(frac(self.x), frac(self.y));
		}
		
		/** Returns the vector that is this vector linearly interpolated with another vector by the specified amount
		 * @arg {Struct.Vector2} vec2 Vector to interpolate with 
		 * @arg {Real} t Interpolation amount clamped between `0` and `1`
		 * @return {Struct.Vector2} */
		static Lerp = function(vec2, t) {
			return LerpUnclamped(vec2, MathClamp01(t));
		}
		
		/** Returns the vector that is this vector linearly interpolated with another vector by the specified amount
		 * @arg {Struct.Vector2} vec2 Vector to interpolate with 
		 * @arg {Real} t Interpolation amount		 
		 * @return {Struct.Vector2} */		
		static LerpUnclamped = function(vec2, t) {
			//Avoid math if im not changing
			if (t == 0) {
				return Clone();
			}
			
			//Avoid math if I should be equal to v
			if (t == 1) {
				return vec2.Clone(); 
			}
			
			return new Vector2(lerp(x, vec2.x, t), lerp(y, vec2.y, t));
		}
		
		/** Returns the magnitude of this vector
		 * @return {Real} */
		static Magnitude = function() {
			return point_distance(0, 0, x, y);
		}
		
		/** Returns the square magnitude of this vector. This is the equivalent of the dot product with itself.
		 * @return {Real} */
		static MagnitudeSqr = function() {
			return dot_product(self.x, self.y, self.x, self.y);
		}
		
		/** Returns the maximum of this vector and a value
		 * @arg {Real|Struct.Vector2} vec2 Must be a vector or a scalar
		 * @return {Struct.Vector2} */
		static Max = function(vec2) {
			if (is_numeric(vec2)) {
				return new Vector2(max(self.x, vec2), max(self.y, vec2));
			}				
			return new Vector2(max(self.x, vec2.x), max(self.y, vec2.y));
		}
		
		/** Returns the minimum of the calling vector and a value
		 * @arg {Real|Struct.Vector2} vec2 Must be a vector or a scalar
		 * @return {Struct.Vector2} */
		static Min = function(vec2) {
			if (is_numeric(vec2)) {
				return new Vector2(min(self.x, vec2), min(self.y, vec2));
			}				
			return new Vector2(min(self.x, vec2.x), min(self.y, vec2.y));
		}					
		
		/** Modifies this vector so that its magnitude is 1
		 * @return {Struct.Vector2} */
		static Normalize = function() {
			var mag = Magnitude();
			if (mag > 0) {
				var mult = 1/mag;
				self.x *= mult;
				self.y *= mult;				
			}
			return self;
		}
		
		/** Returns a normalized vector based on the calling vector.
		 * @return {Struct.Vector2} */
		static Normalized = function() {
			var mag = Magnitude();
			if (mag > 0) {
				var mult = 1/mag;
				return new Vector2(self.x * mult, self.y * mult);			
			}
			return Clone();
		}
		
		/** Returns the rounded version of the calling vector
		 * @return {Struct.Vector2} */
		static Round = function() {
			return new Vector2(round(self.x), round(self.y));
		}
		
		/** Modify this vector so its components are -1, 0, or 1 according to the sign of its component values.
		 * @return {Struct.Vector2} */
		static Sign = function() {
			return new Vector2(sign(self.x), sign(self.y));
		}
	#endregion
	
	
	#region Orientation
		
		/** Returns a new vector that is the calling vector moved towards a target point by the specified distance. Will not overshoot the target position.
		 * @arg {Struct.Vector2} target The target point to move towards
		 * @arg {Real} distance How far to move in a single step
		 * @return {Struct.Vector2} */
		static MoveTowardsPoint = function(target, distance) {
			//Slightly faster to avoid vector ops.
			//Normalize the target position to get a pure direction vector
			var dir = target.Normalized();
			var maxDist = min(point_distance(self.x, self.y, target.x, target.y), distance);
			return new Vector2(self.x + (dir.x * maxDist), self.y + (dir.y * maxDist));
		}	
		
		/** Returns a vector with its XY components swapped then Y is negated (ie; vector [3,5] becomes [5, -3]). This is the same as rotating it 90 degrees clockwise around the room origin.
		 * @return {Struct.Vector2} */
		static PerpendicularClockwise = function() {
			return new Vector2(self.y, -self.x);
		}
		
		/** Returns a vector with its XY components swapped then X is negated (ie; vector [3,5] becomes [-5, 3]). This is the same as rotating it 90 degrees counterclockwise around the room origin.
		 * @return {Struct.Vector2} */		
		static PerpendicularCounterClockwise = function() {
			return new Vector2(-self.y, self.x);		
		}
		
		/** Returns the vector that is the calling vector projected onto vector `v`. The resulting projection is the amount of the vector 
		 * that points in the same direction as the normal. You can use projection to work out the closest point along a line to 
		 * a target vector which can be useful for moving or orienting items in the direction of a moving target for example. 
		 * @arg {Struct.Vector2} vec2 The vector to project onto. Should be a vector that has a magnitude > 0
		 * @return {Struct.Vector2} */
		static Project = function(vec2) {
			var mult = dot_product(self.x, self.y, vec2.x, vec2.y)/dot_product(vec2.x, vec2.y, vec2.x, vec2.y);
			return new Vector2(vec2.x * mult, vec2.y * mult);
		}
		
		/** Returns a new `Vector2` that is the reflection of this vector across another.
		 * @url https://math.libretexts.org/Bookshelves/Applied_Mathematics/Mathematics_for_Game_Developers_(Burzynski)/02%3A_Vectors_In_Two_Dimensions/2.06%3A_The_Vector_Projection_of_One_Vector_onto_Another
		 * @arg {Struct.Vector2} vec2 The vector to reflect across (the vector perpendicular to a surface)
		 * @return {Struct.Vector2} */
		static Reflect = function(vec2) {
			//Formula: reflection = inVect - 2*(inVect . vNorm) * vNorm
			//where inVect refers to the vector being reflected (self)
			var c = 2 * dot_product(self.x, self.y, vec2.x, vec2.y);
			return new Vector2(self.x - (c * vec2.x), self.y - (c * vec2.y));
		}
		
		/** Modify the vector by rotating around the origin of the room (0, 0). To rotate around a different point, use `.RotateAround()` instead.
		 * @arg {Real} degrees The amount of rotation to apply in degrees
		 * @return {Struct.Vector2} */
		static Rotate = function(degrees) {
			///@ignore
			static m = array_create(16);
			matrix_build(0, 0, 0, 0, 0, degrees, 1, 1, 1, m);
			return MatrixTransformVector2(m, self);
		}
		
		/** Returns a new vector that is the calling vector rotated around a point
		 * @arg {Struct.Vector2} point The vector representing the point to rotate around
		 * @arg {Real} degrees The amount of rotation to apply in degrees
		 * @return {Struct.Vector2} */
		static RotateAround = function(point, degrees) {
			///@ignore
			static m = array_create(16);
			matrix_build(point.x, point.y, 0, 0, 0, degrees, 1, 1, 1, m);
			return MatrixTransformVector2(m, new Vector2(self.x - point.x, self.y - point.y));
		}
		
		/** Returns the vector that is the calling vector sheared along the x-axis by factor `n`
		 * @arg {Real} n The amount of shear to apply where 0 is no shear
		 * @return {Struct.Vector2} */
		static ShearX = function(n) {
			var matrix = [
				1, 0, 0, 0,		//Column 1
				n, 1, 0, 0,		//Column 2
				0, 0, 1, 0,		//Column 3
				0, 0, 0, 1		//Column 4
			];
			return MatrixTransformVector2(matrix, self);			
		}
		
		/** Returns the vector that is the calling vector sheared along the y-axis by factor `n`
		 * @arg {Real} [n] `[=1]` The amount of shear to apply where 0 is no shear
		 * @return {Struct.Vector2} */	
		static ShearY = function(n) {
			var matrix = [
				1, n, 0, 0,		//Column 1
				0, 1, 0, 0,		//Column 2
				0, 0, 1, 0,		//Column 3
				0, 0, 0, 1		//Column 4
			];	
			return MatrixTransformVector2(matrix, self);			
		}
		
		/** Gradually changes a vector towards a desired goal over time. The vector is smoothed by a spring-like damper function, such that 
		 * the speed slows as it nears the target position. The motion doesn't overshoot the target position. A common use of this method 
		 * is smoothing the motion of a follow camera. This function should only be used in a `Step` event.
		 * @arg {Struct.Vector2} _vector The vector to modify
		 * @arg {Struct.Vector2} _target Position to move towards
		 * @arg {Struct.Vector2} _currentVelocity Initial velocity. This struct is modified every step.
		 * @arg {Real} _smoothTime The amount of time that you want to travel for (in seconds)
		 * @arg {Real} _maxSpeed `[=infinity]` The maximum speed allowed. By default, there is no maximum speed
		 * @arg {Real} _deltaTime `[=MathMultiplyOneThousand(delta_time)]` The amount of time in between calls to this function (in seconds).
		 * @return {Struct.Vector2} */
		static SmoothDamp = function(_vector, _target, _currentVelocity, _smoothTime, _maxSpeed = infinity, _deltaTime = MathMultiplyOneThousand(delta_time)) {
			var _x = 0;
			var _y = 0;
			
			//Based on Game Programming Gems 4 Chapter 1.10 
			_smoothTime = max(0.00001, _smoothTime);
			var _omega = 2/_smoothTime;
			var _omegaTime = _omega * _deltaTime;
			var _sqOmegaTime = _omegaTime*_omegaTime;
			var _exp = 1/(1 + _omegaTime + (0.48 * _sqOmegaTime + 0.235) * (_omegaTime * _sqOmegaTime));
			
			//distance to the target
			var _changeX = _vector.x - _target.x;
			var _changeY = _vector.y - _target.y;
			
			var _ogTarget = _target;
			
			
			//Clamping speed. Better optimization to manually normalize
			var _maxChange = _maxSpeed * _smoothTime;
			var _magSqr = _changeX*_changeX + _changeY*_changeY;
			if (_magSqr > (_maxChange*_maxChange)) {
				var _mult = 1/sqrt(_magSqr);
				_mult *= _maxChange;
				
				_changeX *= _mult;
				_changeY *= _mult;
			}
			
			
			//Better optimization to avoid vector ops
			_target.x = _vector.x - _changeX;
			_target.y = _vector.y - _changeY;
			
			var _tempX = (_currentVelocity.x + (_omega * _changeX)) * _deltaTime;
			var _tempY = (_currentVelocity.y + (_omega * _changeY)) * _deltaTime;
			
			
			_currentVelocity.x = (_currentVelocity.x - (_omega * _tempX)) * _exp;
			_currentVelocity.y = (_currentVelocity.y - (_omega * _tempY)) * _exp;
			
			_x = _target.x + (_changeX + _tempX) * _exp;
			_y = _target.y + (_changeY + _tempY) * _exp;
			
			//Prevent overshooting
			var _ogMinCurX = _ogTarget.x - _vector.x;
			var _ogMinCurY = _ogTarget.y - _vector.y;
			var _minOrigX = _x - _ogTarget.x;
			var _minOrigY = _y - _ogTarget.y;
			if (dot_product(_ogMinCurX, _ogMinCurY, _minOrigX, _minOrigY) > 0) {
				_x = _ogTarget.x;
				_y = _ogTarget.y;
				
				_currentVelocity.x = (_x - _ogTarget.x) / _deltaTime;
				_currentVelocity.y = (_y - _ogTarget.y) / _deltaTime;
			}
			
			_vector.x = _x;
			_vector.y = _y;
			return _vector;
		}				
		
		/** Returns a new vector that is the calling vector transformed by the specified transformation matrix.
		 * @deprecated
		 * @ignore
		 * @arg {Array<Real>} matrix The matrix to use in the transformation
		 * @return {Struct.Vector2} */
		static Transformation = function(matrix) {
			///@ignore
			static transformedPoint = [0, 0, 0, 0];
			matrix_transform_vertex(matrix, self.x, self.y, 1, 1, transformedPoint);
			return new Vector2(transformedPoint[0], transformedPoint[1]);
		}
	#endregion
}

//Initialize so we can access class methods.
new Vector2();