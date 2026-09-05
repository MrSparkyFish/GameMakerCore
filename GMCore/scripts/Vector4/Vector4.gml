//feather ignore all

/** Vector4: Represents an instance of a 4D vector or a 4-tuple of real numbers.
 * ***
 * Implements: `IString`, `Vector4`, `Vector3`, `Vector2`
 * @arg {Real} x `[= 0]`
 * @arg {Real} y `[= 0]`
 * @arg {Real} z `[= 0]`
 * @arg {Real} w `[= 0]`
 * @return {Struct.Vector4} */
function Vector4(x = 0, y = 0, z = 0, w = 0) constructor {
	
	self.x = x;
	self.y = y;
	self.z = z;
	self.w = w;
	
	/** Create a new `Vector4` from an array of values
	 * @arg {Array<Real>} a
	 * @return {Struct.Vector3} */
	static CreateFromArray = function(a) {
		return new Vector4(a[0], a[1], a[2], a[3]);
	}
	
	/** Set the individual X,Y,Z,W values of this vector
	 * @arg {Real} x
	 * @arg {Real} y
	 * @arg {Real} z
	 * @arg {Real} w
	 * @return {Undefined} */
	static Set = function(x, y, z, w) {
		self.x = x;
		self.y = y;
		self.z = z;
		self.w = w;
	}
	
	/** Sets the XY values of this vector from an array where index 0 is used as the x value, index 1 is used as the y value, index 2 is used as the z value, and index 3 is used as the w value.
	 * @arg {Array<Real>} a The array to set the vector to
	 * @return {Undefined} */
	static SetFromArray = function(a) {
		self.x = a[0];
		self.y = a[1];
		self.z = a[2];
		self.w = a[3];
	}
	
	/** Set this vector 4 to have the equivalent values of another vector 4
	 * @arg {Struct.Vector4} vec4 The vect4 to use in the assignment
	 * @return {Undefined} */
	static SetFromVector = function(vec4) {
		Set(vec4.x, vec4.y, vec4.z, vec4.w);
	}
	
	/** Returns the XY components of this vector as an array where index 0 holds the x value, index 1 holds the y value, index 2 holds the z value, and index 3 is used as the w value
	 * @return {Array<Real} */
	static ToArray = function() {
		return [self.x, self.y, self.z, self.w];
	}
	
	/** Returns a copy of this vector
	 * @return {Struct.Vector4} */
	static Clone = function() {
		return new Vector4(self.x, self.y, self.z, self.w);
	}	
	
	/** Returns this vector as a string
	 * @ignore
	 * @return {String} */
	static toString = function() {
		return $"({self.x}, {self.y}, {self.z}, {self.w})";
	}
	
	#region Operators
		
		/** Modifies this vector by adding value to each of its components
		 * @arg {Real|Struct.Vector4} value
		 * @return {Struct.Vector4} */
		static Add = function(value) {
			if (is_numeric(value)) {
				return new Vector4(self.x + value, self.y + value, self.z + value, self.w + value);
			}
			return new Vector4(self.x + value.x, self.y + value.y, self.z + value.z, self.w + value.w);
		}
		
		/** Modifies this vector by subtracting value from each of its components
		 * @arg {Real|Struct.Vector4} value
		 * @return {Struct.Vector4} */
		static Subtract = function(value) {
			if (is_numeric(value)) {
				return new Vector4(self.x - value, self.y - value, self.z - value, self.w - value);
			}
			return new Vector4(self.x - value.x, self.y - value.y, self.z - value.z, self.w - value.w);
		}
		
		/** Modifies this vector by multiply value to each of its components
		 * @arg {Real|Struct.Vector4} value
		 * @return {Struct.Vector4} */
		static Multiply = function(value) {
			if (is_numeric(value)) {
				return new Vector4(self.x * value, self.y * value, self.z * value, self.w * value);
			}
			return new Vector4(self.x * value.x, self.y * value.y, self.z * value.z, self.w * value.w);
		}	
		
		/** Returns a new Vector4 that is the quotient of this vector and another value
		 * @arg {Real} value
		 * @return {Struct.Vector4} */
		static Divide = function(value) {
			if (is_numeric(value)) {
				return new Vector4(self.x / value, self.y / value, self.z / value, self.w / value);
			}
			return new Vector4(self.x / value.x, self.y / value.y, self.z / value.z, self.w / value.w);
		}
		
		/** Returns the dot product between this vector and another
		 * @arg {Struct.Vector4} vec4
		 * @return {Real} */
		static Dot = function(vec4) {
			return dot_product_3d(self.x, self.y, self.z, vec4.x, vec4.y, vec4.z) + (self.w * vec4.w);
		}		
		
		/** Modify this vector so that its direction is reversed. Its magnitude is kept unchanged. This is the same as multiplying `self * -1`. If you don't want to modify this vector, use `Vector2Reverse()` instead 
		 * @return {Struct.Vector4} */
		static Inverse = function() {
			return new Vector4(-self.x, -self.y, -self.z, -self.w);
		}	
		
		/** Returns true if the calling vector has a component value that is less than the value of the same component of `_vector`
		 * @arg {Struct.Vector4} vec4.
		 * @return {Bool} */
		static LessThan = function(vec4) {
			if (self.x == vec4.x) {
				if (self.y == vec4.y) {
					if (self.z == vec4.z) {
						return (self.w < vec4.w);
					}
					return (self.z < vec4.z);
				}
				return (self.y < vec4.y);
			}
			return (self.x < vec4.x);
		}
		
		/** Returns true if the calling vector has a component value that is less than or equal to the value of the same component of `_vector`
		 * @arg {Struct.Vector4} vec4.
		 * @return {Bool} */
		static LessThanOrEqualTo = function(vec4) {
			if (self.x == vec4.x) {
				if (self.y == vec4.y) {
					if (self.z == vec4.z) {
						return (self.w <= vec4.w);
					}
					return (self.z <= vec4.z);
				}
				return (self.y <= vec4.y);
			}
			return (self.x <= vec4.x);
		}
		
		/** Returns true if the calling vector has a component value that is greater than the value of the same component of `_vector`
		 * @arg {Struct.Vector4} vec4.
		 * @return {Bool} */		
		static GreaterThan = function(vec4) {
			if (self.x == vec4.x) {
				if (self.y == vec4.y) {
					if (self.z == vec4.z) {
						return (self.w > vec4.w);
					}
					return (self.z > vec4.z);
				}
				return (self.y > vec4.y);
			}
			return (self.x > vec4.x);
		}
		
		/** Returns true if the calling vector has a component value that is greater than the value of the same component of `_vector`
		 * @arg {Struct.Vector4} vec4.
		 * @return {Bool} */		
		static GreaterThanOrEqualTo = function(vec4) {
			if (self.x == vec4.x) {
				if (self.y == vec4.y) {
					if (self.z == vec4.z) {
						return (self.w >= vec4.w);
					}
					return (self.z >= vec4.z);
				}
				return (self.y >= vec4.y);
			}
			return (self.x >= vec4.x); 
		}
		
		/** Returns true if the this vectors components are equal to anothers
		 * @arg {Struct.Vector4} vec4.
		 * @return {Bool} */
		static Equals = function(vec4) {
			return ((self.x == vec4.x) && (self.y == vec4.y) && (self.z == vec4.z) && (self.w == vec4.w))
		}	
		
	#endregion
	/** Modify this vector's components to be the absolute value of their values. If you don't want to modify this vector, use `Vector4.Abs()` instead.
	 * @return {Struct.Vector4} */
	static Abs = function() {
		return new Vector4(abs(self.x), abs(self.y), abs(self.z), abs(self.w));
	}
	
	/** Returns the direction of the specified vector from the calling vector relative to the room origin (in degrees).
	 * @arg {Struct.Vector4} vec4
	 * @return {Real} */
	static Angle = function(vec4) {
		return radtodeg(AngleRadians(vec4));
	}
	
	/** Returns the direction of the specified vector from the calling vector relative to the room origin (in radians).
	 * @arg {Struct.Vector4} vec4
	 * @return {Real} */
	static AngleRadians = function(vec4) {
		var den = Magnitude() * vec4.Magnitude();
		if (den == 0) {
			return arccos(0);
		}
		return arccos(clamp(Dot(vec4)/den, -1, 1));
	}	
	
	/** Modify this vector's XYZW value to be rounded up to their nearest integer values. If you don't want to modify this vector, use `Vector4.Ceil()` instead.
	 * @return {Struct.Vector4} */				
	static Ceil = function() {
		return new Vector4(ceil(self.x), ceil(self.y), ceil(self.z), ceil(self.w));
	}
	
	/** Modify this vector so that its XYZW values are clamped to the component values of the `_min` and `_max` vectors. If you don't want to modify this vector, use `Vector4.Clamp()` instead.
	 * @arg {Struct.Vector4} _min The lower limit vector 
	 * @arg {Struct.Vector4} _max The upper limit vector
	 * @return {Struct.Vector4} */
	static Clamp = function(_min, _max) {
		return new Vector4(clamp(self.x, _min.x, _max.x), clamp(self.y, _min.y, _max.y), clamp(self.z, _min.z, _max.z), clamp(self.w, _min.w, _max.w));
	}	
	
	/** Modify this vector so that its length is clamped to _maxLength. If you don't want to modify this vector, use `Vector4.ClampMagnitude()` instead.
	 * @arg {Real} maxLength
	 * @return {Struct.Vector4} */
	static ClampMagnitude = function(maxLength) {
		var dist = (1/sqrt(dot_product_3d(self.x, self.y, self.z, self.x, self.y, self.z) + (self.w * self.w))) * maxLength;
		return new Vector4(self.x * dist, self.y * dist, self.z * dist, self.w * dist);
	}
	
	/** Returns the distance between this vector and another
	 * @arg {Struct.Vector4} vec4
	 * @return {Real} */
	static Distance = function(vec4) {
		return sqrt(sqr(self.x - vec4.x) + sqr(self.y - vec4.y) + sqr(self.z - vec4.z) + sqr(self.w - vec4.w));
	}
	
	/** Modify this vector's XYZ value to be rounded down to their nearest integer values. If you don't want to modify this vector, use `Vector3Floor()` instead.
	 * @return {Struct.Vector4} */				
	static Floor = function() {
		return new Vector4(floor(self.x), floor(self.y), floor(self.z), floor(self.w));
	}
	
	/** Returns a vector that is only the fractional part of the calling vector. That is, only the value that is behind the decimal of the components.
	 * @return {Struct.Vector4} */
	static Frac = function() {
		return new Vector4(frac(self.x), frac(self.y), frac(self.z), frac(self.w));
	}	
	
	/** Modify this vector by linearly interpolating it with another vector by the specified amount
	 * @arg {Struct.Vector4} vec4 The vector to interpolate with
	 * @arg {Real} t The amount of interpolation clamped between `0` and `1`
	 * @return {Struct.Vector4} */
	static Lerp = function(vec4, t) {
		return LerpUnclamped(vec4, MathClamp01(t));
	}
	
	/** Modify this vector by linearly interpolating it with another vector by the specified amount
	 * @arg {Struct.Vector4} vec4 The vector to interpolate with
	 * @arg {Real} t The amount of interpolation
	 * @return {Struct.Vector4} */
	static LerpUnclamped = function(vec4, t) {
		//Avoid math if im not changing
		if (t == 0) {
			return Clone();
		}
		//Avoid math if I should be equal to v
		if (t == 1) {
			return vec4.Clone();
		}
		return new Vector4(lerp(self.x, vec4.x, t), lerp(self.y, vec4.y, t), lerp(self.z, vec4.z, t), lerp(self.w, vec4.w, t));
	}	
	
	/** Returns the length of this vector
	 * @return {Real} */
	static Magnitude = function() {
		return sqrt(dot_product_3d(self.x, self.y, self.z, self.x, self.y, self.z) + (self.w * self.w));
	}		
	
	/** Returns the length of this vector squared. Faster than Magnitude and more useful for comparing vector magnitudes
	 * @return {Real} */
	static MagnitudeSqr = function() {
		return dot_product_3d(self.x, self.y, self.z, self.x, self.y, self.z) + (self.w * self.w);
	}
	
	/** Modify this vector so that its XYZ components are the maximum values between two vectors or between a vector and a scalar. If you don't want to modify this vector, use `Vector3Max()` instead
	 * @arg {Real|Struct.Vector4} vec4 Must be a vector or a scalar
	 * @return {Struct.Vector4} */
	static Max = function(vec4) {
		if (is_numeric(vec4)) {
			return new Vector4(max(self.x, vec4), max(self.y, vec4), max(self.z, vec4), max(self.w, vec4));
		}				
		return new Vector4(max(self.x, vec4.x), max(self.y, vec4.y), max(self.z, vec4.z), max(self.w, vec4.w));
	}
	
	/** Modify this vector so that its XYZ components are the minimum values between two vectors or between a vector and a scalar. If you don't want to modify this vector, use `Vector3Min()` instead
	 * @arg {Real|Struct.Vector4} vec4 Must be a vector or a scalar
	 * @return {Struct.Vector4} */
	static Min = function(vec4) {
		if (is_numeric(vec4)) {
			return new Vector4(min(self.x, vec4), min(self.y, vec4), min(self.z, vec4), min(self.w, vec4));
		}				
		return new Vector4(min(self.x, vec4.x), min(self.y, vec4.y), min(self.z, vec4.z), min(self.w, vec4.w));
	}
	
	/** Move this vector towards a target point by the specified distance
	 * @arg {Struct.Vector4} _target
	 * @arg {Real} _distance
	 * @return {Struct.Vector4} */
	static MoveTowardsPoint = function(target, distance) {
		//More performance optimized to avoid vector ops and assign values manually
		var dir = target.Normalized();
		var maxDist = min(Distance(target), distance);
		return new Vector4(self.x + (dir.x * maxDist), self.y + (dir.y * maxDist), self.z + (dir.z * maxDist), self.w + (dir.w * maxDist));
	}				
	
	/** Modify this vector so that it's magnitude is 0 or 1.
	 * @return {Struct.Vector4} */	
	static Normalize = function() {
		var mag = Magnitude();
		if (mag > 0) {
			var mult = 1/mag;
			self.x *= mult;
			self.y *= mult;
			self.z *= mult;	
			self.w *= mult;		
		}
		return self;
	}
	
	/** Returns a normalized vector based on the calling vector.
	 * @return {Struct.Vector4} */
	static Normalized = function() {
		var mag = Magnitude();
		if (mag > 0) {
			var mult = 1/mag;
			return new Vector4(self.x * mult, self.y * mult, self.z * mult, self.w * mult);			
		}
		return Clone();
	}	
	
	/** Returns a vector that is this vector projected onto another vector.
	 * @return {Struct.Vector4} */	
	static Project = function(vec4) {
		var mult = Dot(vec4)/vec4.MagnitudeSqr() ?? 0;
		return new Vector4(vec4.x * mult, vec4.y * mult, vec4.z * mult, vec4.w * mult);
	}	
	
	/** Returns the vector that is the calling vector projected onto a plane. The resulting projection is the amount of the vector 
	 * that points in the same direction as the normal. You can use projection to work out the closest point along a line to 
	 * a target vector which can be useful for moving or orienting items in the direction of a moving target for example. 
	 * @arg {Struct.Vector4} vec4 The vector representing the plane to project onto. Should be a vector that has a magnitude > 0.
	 * @return {Struct.Vector4} */
	static ProjectOnPlane = function(vec4) {
		//Find the vector that is the inverse of `Project()`
		var mult = -Dot(vec4)/vec4.MagnitudeSqr() ?? 0;
		var vx = vec4.x * mult;
		var vy = vec4.y * mult;
		var vz = vec4.z * mult;		
		var vw = vec4.w * mult;
		
		//Add back to self
		return new Vector4(self.x + vx, self.y + vy, self.z + vz, self.w + vw);
	}
	
	/** Returns a new `Vector4` that is the reflection of this vector across another.
	 * @url https://math.libretexts.org/Bookshelves/Applied_Mathematics/Mathematics_for_Game_Developers_(Burzynski)/02%3A_Vectors_In_Two_Dimensions/2.06%3A_The_Vector_Projection_of_One_Vector_onto_Another
	 * @arg {Struct.Vector4} vec4 The vector to reflect across (the vector perpendicular to a surface)
	 * @return {Struct.Vector4} */	
	static Reflect = function(vec4) {
		//Formula: reflection = inVect - 2*(inVect . vNorm) * vNorm
		//where inVect refers to the vector being reflected (self)
		var c = 2 * Dot(vec4);
		return new Vector4(self.x - (c * vec4.x), self.y - (c * vec4.y), self.z - (c * vec4.z), self.w - (c * vec4.w));
	}
	
	/** Returns the rounded version of the calling vector
	 * @return {Struct.Vector4} */
	static Round = function() {
		return new Vector4(round(self.x), round(self.y), round(self.z), round(self.w));
	}				
	
	/** Modify this vector so its component values are -1, 0, or 1 according to their value sign
	 * @return {Struct.Vector4} */
	static Sign = function() {
		return new Vector4(sign(self.x), sign(self.y), sign(self.z), sign(self.w));
	}
	
	/** Translate, Rotate, and Scale this vector using the specified transformation matrix, useful for changing position in 3D space.
	 * @deprecated
	 * @ignore
	 * @arg {Array<Real>} matrix The transformation matrix to apply
	 * @return {Struct.Vector4} */	
	static Transformation = function(matrix) {
		///@ignore
		static transformedPoint = [0, 0, 0, 0];
		matrix_transform_vertex(matrix, self.x, self.y, self.z, self.w, transformedPoint);
		return new Vector4(transformedPoint[0], transformedPoint[1], transformedPoint[2], transformedPoint[3]);
	}	
}	

new Vector4();