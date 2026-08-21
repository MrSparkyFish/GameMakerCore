//feather ignore all

/** Vector3: Represents an instance of a 3D vector or a 3-tuple of real numbers.
 * ***
 * Implements: `IString`, `Vector3`, `Vector3`
 * @arg {Real} [x] `[= 0]` Value of X
 * @arg {Real} [y] `[= 0]` Value of y
 * @arg {Real} [z] `[= 0]` Value of Z
 * @return {Struct.Vector3} */
function Vector3(x = 0, y = 0, z = 0) constructor {
	self.x = x;
	self.y = y;
	self.z = z;
	
	
	/** Create a new `Vector3` from an array of values
	 * @arg {Array<Real>} a
	 * @return {Struct.Vector3} */
	static CreateFromArray = function(a) {
		return new Vector3(a[0], a[1], a[2]);
	}
	
	/** Returns a new direction vector (0, -1, 0)
	 * @return {Struct.Vector3} */
	static Up = function() {
		return new Vector3(0, -1, 0);
	}
	
	/** Returns a new direction vector (0, 1, 0)
	 * @return {Struct.Vector3} */		
	static Down = function() {
		return new Vector3(0, 1, 0);
	}
	
	/** Returns a new direction vector (-1, 0, 0)
	 * @return {Struct.Vector3} */		
	static Left = function() {
		return new Vector3(-1, 0, 0);
	}
	
	/** Returns a new direction vector (1, 0, 0)
	 * @return {Struct.Vector3} */		
	static Right = function() {
		return new Vector3(1, 0, 0);
	}
	
	/** Returns a direction vector (0, 0, 1)
	 * @return {Struct.Vector3} */	
	static Forwards = function() {
		return new Vector3(0, 0, 1);
	}
	
	/** Returns a direction vector (0, 0, -1)
	 * @return {Struct.Vector3} */
	static Backwards = function() {
		return new Vector3(0, 0, -1);
	}
	
	/** Returns a new direction vector (-infinity, -infinity)
	 * @return {Struct.Vector3} */		
	static NegativeInfinity = function() {
		return new Vector3(-infinity, -infinity, -infinity);
	}
	
	/** Returns a new direction vector (infinity, infinity)
	 * @return {Struct.Vector3} */		
	static PositiveInfinity = function() {
		return new Vector3(infinity, infinity, infinity);
	}	
	
	/** Sets the XYZ value of this vector 
	 * @arg {Real} x
	 * @arg {Real} y
	 * @arg {Real} z
	 * @return {Undefined} */
	static Set = function(x, y, z) {
		self.x = x;
		self.y = y;
		self.z = z;
	}
	
	/** Sets the XYZ values of this vector using an array where index 0 is used as the x value, index 1 is used as the y value, and index 2 is used as the z value
	 * @arg {Array<Real>} a
	 * @return {Undefined} */
	static SetFromArray = function(a) {
		self.x = a[0];
		self.y = a[1];
		self.z = a[2];
	}
	
	/** Returns the XYZ components of this vector as an array where index 0 holds the x value, index 1 holds the y value and index 2 holds the z value
	 * @return {Array<Real} */
	static ToArray = function() {
		return [x, y, z];
	}	
	
	/** Returns a copy of this vector
	 * @return {Struct.Vector3} */
	static Clone = function() {
		return new Vector3(self.x, self.y, self.z);
	}				
	
	/** Returns this vector as a string
	 * @ignore
	 * @return {String} */
	static toString = function() {
		return $"({self.x}, {self.y}, {self.z})";
	}
	
	#region Operators
		
		/** Modifies this vector by adding value to each of its components
		 * @arg {Real|Struct.Vector3} value
		 * @return {Struct.Vector3} */
		static Add = function(value) {
			if (is_numeric(value)) {
				return new Vector3(self.x + value, self.y + value, self.z + value);
			}
			return new Vector3(self.x + value.x, self.y + value.y, self.z + value.z);
		}
		
		/** Modifies this vector by subtracting value from each of its components
		 * @arg {Real|Struct.Vector3} value
		 * @return {Struct.Vector3} */
		static Subtract = function(value) {
			if (is_numeric(value)) {
				return new Vector3(self.x - value, self.y - value, self.z - value);
			}
			return new Vector3(self.x - value.x, self.y - value.y, self.z - value.z);
		}
		
		/** Modifies this vector by multiply value to each of its components
		 * @arg {Real|Struct.Vector3} value
		 * @return {Struct.Vector3} */
		static Multiply = function(value) {
			if (is_numeric(value)) {
				return new Vector3(self.x * value, self.y * value, self.z * value);
			}
			return new Vector3(self.x * value.x, self.y * value.y, self.z * value.z);
		}	
		
		/** Returns a new Vector3 that is the quotient of this vector and another value
		 * @arg {Real} value
		 * @return {Struct.Vector3} */
		static Divide = function(value) {
			if (is_numeric(value)) {
				return new Vector3(self.x / value, self.y / value, self.z / value);
			}
			return new Vector3(self.x / value.x, self.y / value.y, self.z / value.z);
		}
		
		/** Returns the dot product between this vector and another
		 * @arg {Struct.Vector3} vec3
		 * @return {Real} */
		static Dot = function(vec3) {
			return dot_product_3d(self.x, self.y, self.z, vec3.x, vec3.y, vec3.z);
		}
		
		/** Returns the vector that is perpendicular (orthogonal) to the calling vector and vector `v`
		 * @arg {Struct.Vector3} vec3
		 * @return {Struct.Vector3} */
		static Cross = function(vec3) {
			return new Vector3(
				(self.y * vec3.z) - (self.z * vec3.y),
				(self.z * vec3.x) - (self.x * vec3.z),
				(self.x * vec3.y) - (self.y * vec3.x)
			);			
		}
		
		/** Returns the inverse of the calling vector This is the same as multiplying `-1`. 
		 * @return {Struct.Vector3} */
		static Inverse = function() {
			return new Vector3(-self.x, -self.y, -self.z);
		}	
		
		/** Returns true if the calling vector has a component value that is less than the value of the same component of `v`
		 * @arg {Struct.Vector3} vec3
		 * @return {Bool} */
		static LessThan = function(vec3) {
			if (self.x == vec3.x) {
				if (self.y == vec3.y) {
					return (self.z < vec3.z);
				}
				return (self.y < vec3.y);
			}
			return (self.x < vec3.x);
		}
		
		/** Returns true if the calling vector has a component value that is less than or equal to the value of the same component of `v`
		 * @arg {Struct.Vector3} vec3
		 * @return {Bool} */
		static LessThanOrEqualTo = function(vec3) {
			if (self.x == vec3.x) {
				if (self.y == vec3.y) {
					return self.z <= vec3.z;
				}
				return (self.y <= vec3.y);
			}
			return (self.x <= vec3.x);
		}
		
		/** Returns true if the calling vector has a component value that is greater than the value of the same component of `v`
		 * @arg {Struct.Vector3} vec3
		 * @return {Bool} */		
		static GreaterThan = function(vec3) {
			if (self.x == vec3.x) {
				if (self.y == vec3.y) {
					return (self.z > vec3.z);
				}
				return (self.y > vec3.y);
			}
			return (self.x > vec3.x);
		}
		
		/** Returns true if the calling vector has a component value that is greater than the value of the same component of `v`
		 * @arg {Struct.Vector3} vec3
		 * @return {Bool} */		
		static GreaterThanOrEqualTo = function(vec3) {
			if (self.x == vec3.x) {
				if (self.y == vec3.y) {
					return (self.z >= vec3.z);
				}
				return (self.y >= vec3.y);
			}
			return (self.x >= vec3.x);
		}
		
		/** Returns true if the this vectors components are equal to anothers
		 * @arg {Struct.Vector3} vec3
		 * @return {Bool} */
		static Equals = function(vec3) {
			return ((self.x == vec3.x) && (self.y == vec3.y) && (self.z == vec3.z));
		}
		
	#endregion
	
	
	/** Returns the absolute value of this vector
	 * @return {Struct.Vector3} */
	static Abs = function() {
		return new Vector3(abs(self.x), abs(self.y), abs(self.z));
	}
	
	/** Returns the direction of the specified vector from the calling vector relative to the room origin (in degrees).
	 * @arg {Struct.Vector3} vec3 Must not have a magnitude of 0.
	 * @return {Real} */
	static Angle = function(vec3) {
		return radtodeg(AngleRadians(vec3));
	}
	
	/** Returns the direction of the specified vector from the calling vector relative to the room origin (in radians).
	 * @arg {Struct.Vector3} vec3 Must not have a magnitude of 0.
	 * @return {Real} */
	static AngleRadians = function(vec3) {
		var den = point_distance_3d(0, 0, 0, self.x, self.y, self.z) * point_distance_3d(0, 0, 0, vec3.x, vec3.y, vec3.z);
		if (den == 0) {
			return arccos(0);
		}
		var num = dot_product_3d(self.x, self.y, self.z, vec3.x, vec3.y, vec3.z);
		return arccos(clamp(num/den, -1, 1));
	}
	
	/** Returns a vector that is the calling vector rounded up to its nearest integer values
	 * @return {Struct.Vector3} */				
	static Ceil = function() {
		return new Vector3(ceil(self.x), ceil(self.y), ceil(self.z));
	}
	
	/** Returns a vector that is the calling vector clamped to the specified min/max vectors
	 * @arg {Struct.Vector3} _min The lower limit vector 
	 * @arg {Struct.Vector3} _max The upper limit vector
	 * @return {Struct.Vector3} */
	static Clamp = function(_min, _max) {
		return new Vector3(clamp(self.x, _min.x, _max.x), clamp(self.y, _min.y, _max.y), clamp(self.z, _min.z, _max.z));
	}	
	
	/** Returns a vector that is the calling vector set to a maximum length. 
	 * @arg {Real} maxLength
	 * @return {Struct.Vector3} */
	static ClampMagnitude = function(maxLength) {
		var dist = (1/point_distance_3d(0, 0, 0, self.x, self.y, self.z)) * maxLength;
		return new Vector3(self.x * dist, self.y * dist, self.z * dist);
	}
	
	/** Returns the distance between this vector and a point
	 * @arg {Struct.Vector3} vec3
	 * @return {Real} */
	static Distance = function(vec3) {
		return point_distance_3d(self.x, self.y, self.z, vec3.x, vec3.y, vec3.z);
	}
	
	/** Returns a vector that represents the angles of direction (in degrees) of the target vector.
	 * @arg {Struct.Vector3} target The point to get the direction for
	 * @return {Struct.Vector3} */
	static Direction = function(target) {
		var dir = Subtract(target).Normalize();
		dir.Set(darccos(dir.x), darccos(dir.y), darccos(dir.z));
		return dir;
	}
	
	/** Returns a vector that represents the angles of direction (in radians) of the target vector.
	 * @arg {Struct.Vector3} target The point to get the direction for
	 * @return {Struct.Vector3} */
	static DirectionRadians = function(target) {
		var dir = Subtract(target).Normalize();
		dir.Set(arccos(dir.x), arccos(dir.y), arccos(dir.z));
		return dir;
	}
	
	/** Returns a direction vector that points in the direction of the specified target
	 * @arg {Struct.Vector3} target The target to get the direction of
	 * @return {Struct.Vector3} */
	static DirectionTarget = function(target) {
		return target.Subtract(self).Normalize();
	}
	
	/** Returns a vector that is this vector's component values rounded down to their nearest integer values.
	 * @return {Struct.Vector3} */				
	static Floor = function() {
		return new Vector3(floor(self.x), floor(self.y), floor(self.z));
	}
	
	/** Returns a vector that is only the fractional part of the calling vector. That is, only the value that is behind the decimal of the components.
	 * @return {Struct.Vector3} */
	static Frac = function() {
		return new Vector3(frac(self.x), frac(self.y), frac(self.z));
	}
	
	/** Returns the vector that is this vector linearly interpolated with another vector by the specified amount
	 * @arg {Struct.Vector3} vec3 The vector to interpolate with
	 * @arg {Real} t The amount of interpolation clamped between `0` and `1`
	 * @return {Struct.Vector3} */
	static Lerp = function(vec3, t) {
		return LerpUnclamped(vec3, MathClamp01(t));
	}
	
	/** Returns the vector that is this vector linearly interpolated with another vector by the specified amount
	 * @arg {Struct.Vector3} vec3 The vector to interpolate with
	 * @arg {Real} t The amount of interpolation
	 * @return {Struct.Vector3} */
	static LerpUnclamped = function(vec3, t) {
		//Avoid math if im not changing
		if (t == 0) {
			return Clone();
		}
		//Avoid math if I should be equal to v
		if (t == 1) {
			return vec3.Clone();
		}
		return new Vector3(lerp(self.x, vec3.x, t), lerp(self.y, vec3.y, t), lerp(self.z, vec3.z, t));
	}		
	
	/** Returns the length of this vector
	 * @return {Real} */
	static Magnitude = function() {
		return point_distance_3d(0, 0, 0, self.x, self.y, self.z);
	}
	
	/** Returns the length of this vector squared. Faster than Magnitude and more useful for comparing vector magnitudes
	 * @return {Real} */
	static MagnitudeSqr = function() {
		return dot_product_3d(self.x, self.y, self.z, self.x, self.y, self.z);
	}
	
	/** Returns the maximum of this vector and a value
	 * @arg {Real|Struct.Vector3} vec3 Must be a vector or a scalar
	 * @return {Struct.Vector3} */
	static Max = function(vec3) {
		if (is_numeric(vec3)) {
			return new Vector3(max(self.x, vec3), max(self.y, vec3), max(self.z, vec3));
		}				
		return new Vector3(max(self.x, vec3.x), max(self.y, vec3.y), max(self.z, vec3.z));
	}
	
	/** Returns the minimum of the calling vector and a value
	 * @arg {Real|Struct.Vector3} vec3 Must be a vector or a scalar
	 * @return {Struct.Vector3} */
	static Min = function(vec3) {
		if (is_numeric(vec3)) {
			return new Vector3(min(self.x, vec3), min(self.y, vec3), min(self.z, vec3));
		}				
		return new Vector3(min(self.x, vec3.x), min(self.y, vec3.y), min(self.z, vec3.z));
	}	
	
	/** Returns a new vector that is the calling vector moved towards a target point by the specified distance. Will not overshoot the target position.
	 * @arg {Struct.Vector3} target The target point to move towards
	 * @arg {Real} distance How far to move in a single step
	 * @return {Struct.Vector3} */
	static MoveTowardsPoint = function(target, distance) {
		//More performance optimized to avoid vector ops and assign values manually
		var dir = target.Normalized();
		var maxDist = min(point_distance_3d(self.x, self.y, self.z, target.x, target.y, target.z), distance);
		return new Vector3(self.x + (dir.x * maxDist), self.y + (dir.y * maxDist), self.z + (dir.z * maxDist));
	}	
	
	/** Modify this vector so that it's magnitude is 1.
	 * @return {Struct.Vector3} */
	static Normalize = function() {
		var mag = Magnitude();
		if (mag > 0) {
			var mult = 1/mag;
			self.x *= mult;
			self.y *= mult;
			self.z *= mult;			
		}
		return self;
	}
	
	/** Returns a normalized vector based on the calling vector.
	 * @return {Struct.Vector3} */
	static Normalized = function() {
		var mag = Magnitude();
		if (mag > 0) {
			var mult = 1/mag;
			return new Vector3(self.x * mult, self.y * mult, self.z * mult);			
		}
		return Clone();
	}
	
	/** Returns the vector that is the calling vector projected onto vector `v`. The resulting projection is the amount of the vector 
	 * that travels in the same direction as the normal. You can use projection to work out the closest point along a line to 
	 * a target vector which can be useful for moving or orienting items in the direction of a moving target for example. 
	 * @arg {Struct.Vector3} vec3 The vector to project onto. Should be a normalized vector that has a magnitude of 1.
	 * @return {Struct.Vector3} */	
	static Project = function(vec3) {
		var mult = dot_product_3d(self.x, self.y, self.z, vec3.x, vec3.y, vec3.z)/dot_product_3d(vec3.x, vec3.y, vec3.z, vec3.x, vec3.y, vec3.z) ?? 0;
		return new Vector3(vec3.x * mult, vec3.y * mult, vec3.z * mult);
	}
	
	/** Returns the vector that is the calling vector projected onto a plane. The resulting projection is the "flattened" version of the vector as though
	 * you were looking at it directly from a top-down view of the plane.
	 * @arg {Struct.Vector3} vec3 The vector to project onto. Should be a normalized vector that has a magnitude of 1.
	 * @return {Struct.Vector3} */
	static ProjectOnPlane = function(vec3) {
		//Find the vector that is the inverse of `Project()`
		var mult = dot_product_3d(self.x, self.y, self.z, vec3.x, vec3.y, vec3.z)/dot_product_3d(vec3.x, vec3.y, vec3.z, vec3.x, vec3.y, vec3.z) ?? 0;
		var vx = vec3.x * mult;
		var vy = vec3.y * mult;
		var vz = vec3.z * mult;		
		
		//Add back to self
		return new Vector3(self.x - vx, self.y - vy, self.z - vz);
	}	
	
	/** Returns a new `Vector3` that is the reflection of this vector across another.
	 * @url https://math.libretexts.org/Bookshelves/Applied_Mathematics/Mathematics_for_Game_Developers_(Burzynski)/02%3A_Vectors_In_Two_Dimensions/2.06%3A_The_Vector_Projection_of_One_Vector_onto_Another
	 * @arg {Struct.Vector3} vec3 The vector to reflect across (the vector perpendicular to a surface)
	 * @return {Struct.Vector3} */	
	static Reflect = function(vec3) {
		//Formula: reflection = inVect - 2*(inVect . vNorm) * vNorm
		//where inVect refers to the vector being reflected (self)
		var c = 2 * dot_product_3d(self.x, self.y, self.z, vec3.x, vec3.y, vec3.z);
		return new Vector3(self.x - (c * vec3.x), self.y - (c * vec3.y), self.z - (c * vec3.z));
	}
	
	/** Returns the vector that is this vector rotated around the room origin by the angles specified
	 * @arg {Struct.Vector3} angles A vector containing the XYZ angles of rotation to apply
	 * @return {Struct.Vector3} */
	static Rotate = function(angles) {
		///@ignore
		static m = array_create(16);
		matrix_build(0, 0, 0, angles.x, angles.y, angles.z, 1, 1, 1, m);
		return MatrixTransformVector3(m, self);
	}
	
	/** Modifies this vector to be rotated around a point
	 * @arg {Struct.Vector3} point The point to rotate around
	 * @arg {Struct.Vector3} angles A vector containing the XYZ angles of rotation to apply
	 * @return {Struct.Vector3} */
	static RotateAround = function(point, angles) {
		///@ignore
		static m = array_create(16);
		matrix_build(point.x, point.y, point.z, angles.x, angles.y, angles.z, 1, 1, 1, m);
		return MatrixTransformVector3(m, new Vector3(self.x - point.x, self.y - point.y, self.z - point.z));
	}
	
	/** Returns the rounded version of the calling vector
	 * @return {Struct.Vector3} */
	static Round = function() {
		return new Vector3(round(self.x), round(self.y), round(self.z));
	}
	
	/** Returns the vector that is the calling vector sheared along the x-axis by factor `ny` and `nz`
	 * @arg {Real} nx The amount of shear to apply to y
	 * @arg {Real} nz The amount of shear to apply to z
	 * @return {Struct.Vector3} */
	static ShearX = function(ny, nz) {
		var matrix = [
			1, 0, 0, 0,		//Column 1
			ny, 1, 0, 0,	//Column 2
			nz, 0, 1, 0,	//Column 3
			0, 0, 0, 1		//Column 4
		];
		return MatrixTransformVector3(matrix, self);			
	}
	
	/** Returns the vector that is the calling vector sheared along the y-axis by factor `nx` and `nz`
	 * @arg {Real} nx The amount of shear to apply to x
	 * @arg {Real} nz The amount of shear to apply to z
	 * @return {Struct.Vector3} */	
	static ShearY = function(nx, nz) {
		var matrix = [
			1, nx, 0, 0,	//Column 1
			0, 1, 0, 0,		//Column 2
			0, nz, 1, 0,	//Column 3
			0, 0, 0, 1		//Column 4
		];	
		return MatrixTransformVector3(matrix, self);			
	}	
	
	/** Returns the vector that is the calling vector sheared along the y-axis by factor `nx` and `ny`
	 * @arg {Real} nx The amount of shear to apply to x
	 * @arg {Real} ny The amount of shear to apply to y
	 * @return {Struct.Vector3} */	
	static ShearZ = function(nx, ny) {
		var matrix = [
			1, 0, nx, 0,	//Column 1
			0, 1, ny, 0,	//Column 2
			0, 0, 1, 0,		//Column 3
			0, 0, 0, 1		//Column 4
		];	
		return MatrixTransformVector3(matrix, self);			
	}	
	
	/** Modify this vector so its component values are -1, 0, or 1 according to their value sign
	 * @return {Struct.Vector3} */
	static Sign = function() {
		return new Vector3(sign(self.x), sign(self.y), sign(self.z));
	}
	
	/** Gradually changes a vector towards a desired goal over time.The vector is smoothed by a spring-like damper function, such that 
	 * the speed slows as it nears the target position. The motion doesn't overshoot the target position. A common use of this method 
	 * is smoothing the motion of a follow camera. This function should only be used in a `Step` event
	 * @arg {Struct.Vector3} _current Initial position
	 * @arg {Struct.Vector3} _target Position to move towards
	 * @arg {Struct.Vector3} _currentVelocity Initial velocity. This struct is modified every step.
	 * @arg {Real} _smoothTime The amount of time that you want to travel for (in seconds)
	 * @arg {Real} _maxSpeed `[=infinity]` The maximum speed allowed. By default, there is no maximum speed
	 * @arg {Real} _deltaTime `[=delta_time]` The amount of time in between calls to this function (in seconds).
	 * @return {Struct.Vector3} */
	static SmoothDamp = function(_current, _target, _currentVelocity, _smoothTime, _maxSpeed = infinity, _deltaTime = MathMultiplyOneThousand(delta_time)) {
		var _x = 0;
		var _y = 0;
		var _z = 0;
		
		//Based on Game Programming Gems 4 Chapter 1.10 
		_smoothTime = max(0.0001, _smoothTime);
		var _omega = 2/_smoothTime;
		var _omegaTime = _omega * _deltaTime;
		var _sqOmegaTime = _omegaTime * _omegaTime
		var _exp = 1/(1 + _omegaTime + (0.48 * _sqOmegaTime) + (0.235 * _omegaTime * _sqOmegaTime));
		
		var _changeX = _current.x - _target.x;
		var _changeY = _current.y - _target.y;
		var _changeZ = _current.z - _target.z;
		
		var _ogTarget = _target;
		
		
		//Clamping speed. Better optimization to manually do magnitude
		var _maxChange = _maxSpeed * _smoothTime;
		var _magSqr = _changeX*_changeX + _changeY*_changeY + _changeZ*_changeZ;
		if (_magSqr > (_maxChange*_maxChange)) {
			var _mult = 1/sqrt(_magSqr);
			_mult *= _maxChange;
			
			_changeX *= _mult;
			_changeY *= _mult;
			_changeZ *= _mult;
		}
		
		//Better optimization to avoid vector ops
		_target.x = _current.x - _changeX;
		_target.y = (_current.y - _changeY);
		_target.z = (_current.z - _changeZ);
		
		var _tempX = (_currentVelocity.x + (_omega * _changeX)) * _deltaTime;
		var _tempY = (_currentVelocity.y + (_omega * _changeY)) * _deltaTime;
		var _tempZ = (_currentVelocity.z + (_omega * _changeZ)) * _deltaTime;
		
		_currentVelocity.x = ((_currentVelocity.x - (_omega * _tempX)) * _exp);
		_currentVelocity.y = ((_currentVelocity.y - (_omega * _tempY)) * _exp);
		_currentVelocity.z = ((_currentVelocity.z - (_omega * _tempZ)) * _exp);
		
		_x = _target.x + (_changeX + _tempX) * _exp;
		_y = _target.y + (_changeY + _tempY) * _exp;
		_z = _target.z + (_changeZ + _tempZ) * _exp;
		
		//Prevent overshooting
		var _ogMinCurX = _ogTarget.x - _current.x;
		var _ogMinCurY = _ogTarget.y - _current.y;
		var _ogMinCurZ = _ogTarget.z - _current.z;
		var _minOrigX = _x - _ogTarget.x;
		var _minOrigY = _y - _ogTarget.y;
		var _minOrigZ = _z - _ogTarget.z;
		if (dot_product_3d(_ogMinCurX, _ogMinCurY, _ogMinCurZ, _minOrigX, _minOrigY, _minOrigZ) > 0) {
			_x = _ogTarget.x;
			_y = _ogTarget.y;
			_z = _ogTarget.z;
			
			_currentVelocity.x = (_x - _ogTarget.x) / _deltaTime;
			_currentVelocity.y = (_y - _ogTarget.y) / _deltaTime;
			_currentVelocity.z = (_z - _ogTarget.z) / _deltaTime;
		}
		
		_current.x = _x;
		_current.y = _y;
		_current.z = _z;
		return _current;
	}	
	
	/** Returns a new vector that is the calling vector transformed by the specified transformation matrix.
	 * @deprecated
	 * @ignore
	 * @arg {Array<Real>} matrix The matrix to use in the transformation
	 * @return {Struct.Vector3} */
	static Transformation = function(matrix) {
		///@ignore
		static transformedPoint = [0, 0, 0, 0];
		matrix_transform_vertex(matrix, self.x, self.y, self.z, 1, transformedPoint);
		return new Vector3(transformedPoint[0], transformedPoint[1], transformedPoint[2]);
	}
}

new Vector3();