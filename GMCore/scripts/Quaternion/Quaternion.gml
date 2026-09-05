//feather ignore all
 
/** Quaternion: Represents rotations in 3-dimensions
 * ***
 * Implements: `Vector4`, `Vector3`, `Vector2`, `IString`
 * @arg {Real} x `[=0]`
 * @arg {Real} y `[=0]`
 * @arg {Real} z `[=0]`
 * @arg {Real} w `[=1]`
 * @return {Struct.Quaternion} */
function Quaternion(x = 0, y = 0, z = 0, w = 1) constructor {
	
	//From left to right, the order in which this Quaternion applies rotation when multiplied with a vector.
	enum QuaternionRotationOrder {
		XYZ,
		XZY,
		YXZ,
		YZX,
		ZXY,
		ZYX
	}
	
	self.x = x;					//Vector component x
	self.y = y;					//Vector component y
	self.z = z;					//Vector component z
	self.w = w;					//Scalar component w
	
	/** Create a new `Quaternion` from an array of real values
	 * @arg {Array<Any>} a The array to use. Quaternion values correspond as follows: `x = a[0], y = a[1], z = a[2], w = a[3]`
	 * @return {Struct.Quaternion} */
	static CreateFromArray = function(a) {
		return new Quaternion(a[0], a[1], a[2], a[3]);
	}
	
	/** Create a new `Quaternion` from a `Vector4`.
	 * @arg {Struct.Vector4} vec4 Component values of this vector are assigned directly to the Quaternion.
	 * @return {Struct.Quaternion} */
	static CreateFromVector = function(vec4) {
		return new Quaternion(vec4.x, vec4.y, vec4.z, vec4.w);
	}
	
	/** Create a new `Quaternion` from an angle and axis of rotation
	 * @arg {Real} angle Angle of rotation in degrees
	 * @arg {Struct.Vector3} axis Axis of rotation represented as a direction vector
	 * @return {Struct.Quaternion} */
	static CreateFromAngleAxis = function(angle, axis) {
		var result = new Quaternion();
		result.SetFromAngleAxis(angle, axis);
		return result;
	}
	
	/** Creates a new `Quaternion` from the specified Euler's angles. 
	 * @arg {Real} x Angle x-axis
	 * @arg {Real} y Angle y-axis
	 * @arg {Real} z Angle z-axis
	 * @arg {Enum.QuaternionRotationOrder} [sequence] Optionally specify the rotation sequence of the angles. Defaults to YXZ which is the same order as GM transformation matricies.
	 * @return {Struct.Quaternion} */
	static CreateFromEulersAngles = function(x, y, z, sequence = undefined) {
		var result = new Quaternion();
		result.SetEuler(x, y, z, sequence);
		return result;
	}
	
	/** Creates a new `Quaternion` from the specified vector of Euler's angles. 
	 * @arg {Struct.Vector3} angles
	 * @arg {Enum.QuaternionRotationOrder} [sequence] Optionally specify the rotation sequence of the angles. Defaults to YXZ which is the same order as GM transformation matricies.
	 * @return {Struct.Quaternion} */	
	static CreateFromEulerAngles = function(angles, sequence = undefined) {
		if (LINEAR_ALGEBRA_SAFETY_CHECKS) {
			if (!is_instanceof(angles, Vector3)) {
				
			}
		}
		var result = new Quaternion();
		result.SetEulerAngles(angles, sequence);
		return result;		
	}
	
	/** Creates a new `Quaternion` from the specified right, up, and forward direction vectors
	 * @arg {Struct.Vector3} right
	 * @arg {Struct.Vector3} up
	 * @arg {Struct.Vector3} forward
	 * @return {Struct.Quaternion} */	
	static CreateFromDirections = function(right, up, forward) {
		var result = new Quaternion();
		result.SetFromDirections(right, up, forward);
		return result;
	}
	
	/** Creates a new `Quaternion` that has the specified forwards and upwards directions. Used for looking in a specific direction.
	 * @arg {Struct.Vector3} forward A vector representing the 'forward' direction.
	 * @arg {Struct.Vector3} [up] Optional Up direction vector. If not provided, the default Vector3.Up vector is used.
	 * @return {Struct.Quaternion} */ 
	static CreateFromLookRotation = function(forward, up = undefined) {
		var result = new Quaternion();
		result.SetFromLookRotation(forward, up);
		return result;
	}
	
	/** Creates a new `Quaternion` which rotates from one direction to another. Use this function to make a Quaternion whose axis defined by the 
	 * `from` direction points in the `to` direction.
	 * @arg {Struct.Vector3} from The direction/axis that should do the pointing
	 * @arg {Struct.Vector3} to The direction/axis to point in
	 * @return {Struct.Quaternion} */
	static CreateFromToRotation = function(from, to) {
		var result = new Quaternion();
		result.SetFromToRotation(from, to);
		return result;
	}
	
	/** Creates a new `Quaternion` from the provided 4x4 transformation matrix
	 * @arg {Array<Real>} matrix The matrix to get a quaternion from
	 * @return {Struct.Quaternion} */	
	static CreateFromMatrix = function(matrix) {
		return CreateFromDirections(
			MatrixGetColumn(matrix, 0).Normalize(),
			MatrixGetColumn(matrix, 1).Normalize(),
			MatrixGetColumn(matrix, 2).Normalize()
		);
	}
	
	/** Returns this `Quaternion` as an array where values correspond as follows: `x = a[0], y = a[1], z = a[2], w = a[3]`
	 * @return {Array<Real>} */
	static ToArray = function() {
		return [self.x, self.y, self.z, self.w];
	}
	
	/** Returns this `Quaternion` broken down into its angle-axis components
	 * @return {Struct.QuaternionAngleAxis} */
	static ToAngleAxis = function() {
		return new QuaternionAngleAxis(self);
	}
	
	/** Returns the vector component of this Quaternion as a new `Vector3`.
	 * @return {Struct.Vector3} */
	static GetXYZ = function() {
		return new Vector3(self.x, self.y, self.z);
	}				
	
	/** Extracts the Euler's angles in the specified order, which are measured in degrees (`0` to `360`), from this `Quaternion`.
	 * @arg {Enum.QuaternionRotationOrder} [_sequence] `[=QuaternionRotationOrder.YXZ]`
	 * @return {Struct.Vector3} */
	static GetEulersAngles = function(_sequence = QuaternionRotationOrder.YXZ) {
		//Step 1: Extract data from the quaternion in the order specified
		//Getting the order of evaluation
		var _axis = SplitRotationOrder(_sequence);
		
		//Assign values from our quaternion according to the evaluation sequence.
		var i = ElementaryBasisIndex(_axis[0]);
		var j = ElementaryBasisIndex(_axis[1]);
		var k = ElementaryBasisIndex(_axis[2]);			
		
		//Find the permutation value for our sequence which must be +-1.
		var e = (i-j)*(j-k)*(k-i)/2;			
		
		//Turn into an array so we can extract values in the order provided. 
		//This allows us to easily use the general Quaternion to Euler algorithm	
		var quat = ToArray();
		var a = quat[3];
		var b = quat[i];
		var c = quat[j];
		var d = quat[k];		
		
		//Step 2: Convert extracted quat values into angles.
		//Cache needed values
		var dot = Dot(self);
		var test = (a * c) + (e * b * d);
		var angles = [0, 0, 0];
		
		//North and South pole singularity checks
		var const = 0.4995 * dot;
		var npSingularity = (test > (const));
		var spSingularity = (test < (-const));
		var anySingluarity = (npSingularity || spSingularity);
		
		//Singularity detected
		if (anySingluarity) {
			angles[j] = (npSingularity) ? radtodeg(pi*0.5) : radtodeg(-pi*0.5);
			angles[i] = radtodeg(2 * arctan2(b, a));
		}
		//No singularity
		else {
			var asq = a*a;	
			var bsq = b*b;	
			var csq = c*c;	
			var dsq = d*d;	
			angles[i] = radtodeg(arctan2(2 * ((a * b) - (e * c * d)), dsq - bsq - csq + asq));
			angles[j] = radtodeg(arcsin(2 * test/dot));
			angles[k] = radtodeg(arctan2(2 * ((a * d) - (e * b * c)), bsq - dsq - csq + asq));
		}		
		
		for (var i = 0; i < 3; i++) {
			angles[i] = MathNormalizeAngle(angles[i]);
		}
		return Vector3.CreateFromArray(angles);
	}	
	
	/** Directly set the XYZW components of this `Quaternion`. Modifying a Quaternion directly is NOT recommended unless you are familiar with 
	 * how they operate!
	 * @arg {Real} x The value to set for x
	 * @arg {Real} y The value to set for y
	 * @arg {Real} z The value to set for z
	 * @arg {Real} w The value to set for w
	 * @return {Undefined} */
	static Set = function(x, y, z, w) {
		self.x = x;
		self.y = y;
		self.z = z;
		self.w = w;
	}
	
	/** Directly set the XYZ components of this `Quaternion`. Modifying a Quaternion directly is NOT recommended unless you are familiar with how 
	 * they operate!
	 * @arg {Real} x The value to set for x
	 * @arg {Real} y The value to set for y
	 * @arg {Real} z The value to set for z
	 * @return {Undefined} */
	static SetXYZ = function(x, y, z) {
		self.x = x;
		self.y = y;
		self.z = z;
	}
	
	/** Directly set the W component of this `Quaternion`. Modifying a Quaternion directly is NOT recommended unless you are familiar with how they 
	 * operate!
	 * @arg {Real} w The value to set for w
	 * @return {Undefined} */
	static SetW = function(w) {
		self.w = w;
	}
	
	/** Directly set the values of this `Quaternion` to the values of the specified `Quaternion`. Modifying a Quaternion directly is NOT recommended 
	 * unless you are familiar with how they operate!
	 * @arg {Struct.Quaternion} q The quaternion used to set values
	 * @return {Undefined} */
	static SetFromQuaternion = function(q) {
		self.x = q.x;
		self.y = q.y;
		self.z = q.z;
		self.w = q.w;	
	}
	
	/** Make this `Quaternion` a unit `Quaternion` (x = 0, y = 0, z = 0, w = 1).
	 * @return {Undefined} */
	static SetUnitQuaternion = function() {
		self.x = 0;
		self.y = 0;
		self.z = 0;
		self.w = 1;
	}
	
	/** Modify this `Quaternion` to fit the specified Euler's angles representation. These angles are converted into the Quaternion's internal. Modifying a Quaternion directly is NOT recommended unless you are familiar with how they operate!
	* ***
	* Derived from Amy de Buitléir who wrote a paper "Quaternions" where she derived a general use algorithm for converting any Euler's angle rotation order to a quaternion.
	* @arg {Struct.Vector3} _eulerAngles Struct of EulerAngles
	* @arg {String} [_sequence] `[=YXZ]` The rotation sequence the quaternion should use. Defaults to "YXZ" to match the rotation order of GM transformation matricies.
	* @return {Undefined} */
	static SetEulerAngles = function(_eulerAngles, _sequence = undefined) {
		SetEulerAnglesInternal(_eulerAngles.x, _eulerAngles.y, _eulerAngles.z, _sequence);
	}
	
	/** Sets the values of the XYZW components using an array in XYZW order. Modifying a Quaternion directly is NOT recommended unless you are familiar with how they operate!
	* @arg {Array<Real>} a
	* @return {Undefined} */
	static SetFromArray = function(a) {
		self.x = a[0];
		self.y = a[1];
		self.z = a[2];
		self.w = a[3];
	}
	
	/** Sets the values of the XYZW components using a vector4. Modifying a Quaternion directly is NOT recommended unless you are familiar with how they operate!
	* @arg {Struct.Vector4} v
	* @return {Undefined} */
	static SetFromVector = function(v) {
		self.x = v.x;
		self.y = v.y;
		self.z = v.z;
		self.w = v.w;
	}
	
	/** Modify this `Quaternion` so its rotated from one direction to another. Use this function to make the axis defined by the `_from` direction point in the `_to` direction.
	* @arg {Struct.Vector3} _fromDirection A direction vector for where the quaternion starts 
	* @arg {Struct.Vector3} _toDirection A direction vector for where the quaternion ends
	* @return {Undefined} */
	static SetFromToRotation = function(_fromDirection, _toDirection) {
		var _axis = _fromDirection.Cross(_toDirection);
		var _angle = _fromDirection.Angle(_toDirection);
		SetFromAngleAxis(_angle, _axis);
	}
	
	/** Modifies this `Quaternion` so that it is pointed in the direction of the `_lookTowards` vector while maintaining the same `_up` vector
	* @arg {Struct.Vector3} forwards A vector representing the 'forward' direction.
	* @arg {Struct.Vector3} [upwards] `[=Vector3.Up()]` A vector representing the `up` direction.
	* @return {Struct.Quaternion} */ 
	static SetFromLookRotation = function(forwards, upwards = undefined) {
		upwards ??= Vector3.Up();
		
		//Calculate the forward direction and right direction, then get the perpendicular to the forward and right which is the real up direction
		var forward = forwards.Normalized();
		var right = upwards.Cross(forward).Normalize();
		var up = forward.Cross(right).Normalize();
		SetFromDirections(right, up, forward);
		
		//Delete the vectors we created and no longer need
		delete forward;
		delete right;
		delete up;
	}
	
	/** Modifies this `Quaternion` to be rotated about the specified axis
	* @arg {Real} angle The angle of rotation in degrees (from `0` to `360`)
	* @arg {Struct.Vector3} axis `[=V3Right()]` The axis of rotation.
	* @return {Undefined} */
	static SetFromAngleAxis = function(angle, axis = undefined) {
		axis ??= Vector3.Right();
		
		//Extracting values and checking if we have to do math
		var mag = axis.Magnitude();
		if (mag == 0) {
			SetUnitQuaternion();
		}
		
		else {
			//Apply angle and Normalize the axis values at the same time without creating a separate vector or modifying the input vector
			var radians = degtorad(angle) * 0.5;		//Quaternions work in radian half angles
			var mult = (sin(radians)/mag); 				//simplify from _mult = (1/sqrt(_sqrMag)) * sin(radians)
			Set(axis.x * mult, axis.y * mult, axis.z * mult, cos(radians));
		}
	}
	
	/** Modify this `Quaternion` so its XYZ axis are pointed in the specified right, up, and forwards directions respectively.
	* @arg {Struct.Vector3} _right The direction of right
	* @arg {Struct.Vector3} _up The direction of up
	* @arg {Struct.Vector3} _forward The direction of forward
	* @return {Undefined} */
	static SetFromDirections = function(_right, _up, _forward) {
		//Extract matrix values, avoiding creating vectors for a slight performance boost
		var m00 = _right.x;
		var m01 = _right.y;
		var m02 = _right.z;
		var m10 = _up.x;
		var m11 = _up.y;
		var m12 = _up.z;
		var m20 = _forward.x;
		var m21 = _forward.y;
		var m22 = _forward.z;
		
		//Solving for xyzw
		var _trace = m00 + m11 + m22;
		//Solve w first because w will be the largest value
		if (_trace > 0) {
			self.w = sqrt(_trace + 1) * 0.5;
			
			//w allows us to solve for xyz. 
			//First we get the mult conversion for w so we can avoid slow division
			var _mult = 1 / (4*self.w);
			self.x = (m12 - m21) * _mult;
			self.y = (m20 - m02) * _mult;
			self.z = (m01 - m10) * _mult;
		}
		
		//Solve x first because x will be the largest value
		else if ((m00 >= m11) && (m00 >= m22)) {
			self.x = sqrt(m00 - m11 - m22 + 1) * 0.5;
			
			//solve for yzw
			var _mult = 1/(4*self.x);
			self.y = (m01 + m10) * _mult;
			self.z = (m20 + m02) * _mult;
			self.w = (m12 - m21) * _mult;
		}
		
		//Solve for y first because y will be the largest value
		else if (m11 > m22) {
			self.y = sqrt(-m00 + m11 - m22 + 1) * 0.5;
			
			//Solve for xzw
			var _mult = 1/(4*self.y);
			self.x = (m01 + m10) * _mult;
			self.z = (m12 + m21) * _mult;
			self.w = (m20 - m02) * _mult;
		}
		
		//Solve for z first because z will be the largest value
		else {
			self.z = sqrt(-m00 - m11 + m22 + 1) * 0.5;
			
			//Solve for xyw
			var _mult = 1/(4*self.z);
			self.x = (m20 + m02) * _mult;
			self.y = (m12 + m21) * _mult;
			self.w = (m01 - m10) * _mult;
		}
	}
	
	/** Returns this quaternion as a string
	 * @ignore
	 * @return {String} */
	static toString = function() {
		return $"({self.x}, {self.y}, {self.z}, {self.w})";
	}
	
	/** Returns a copy of this `Quaternion`
	* @return {Struct.Quaternion} */
	static Clone = function() {
		return new Quaternion(self.x, self.y, self.z, self.w);
	}				
	
	/** Finds the angle between this quaternion and another
	 * @arg {Struct.Quaternion} q The other quaternion
	 * @return {Real} */
	static Angle = function(q) {
		var _dot = Dot(q);
		var _angle = darccos(min(abs(_dot), 1));
		return (2 * _angle);
	}
	
	/** Returns a new `Quaternion` that is the conjugate form of the calling one.
	 * @return {Struct.Quaternion} */
	static Conjugate = function() {
		return new Quaternion(-self.x, -self.y, -self.z, self.w);
	}
	
	
	/** Returns the dot product between this quaternion and another
	 * @arg {Struct.Quaternion} q
	 * @return {Real} */
	static Dot = function(q) {
		return dot_product_3d(self.x, self.y, self.z, q.x, q.y, q.z) + (self.w * q.w);
	}	
	
	/** Modifies this `Quaternion` into its Inverse form. For unit `Quaternions` (where magnitude == 1) this is the same as its conjugate form.
	 * @return {Struct.Quaternion} */
	static Inverse = function() {
		//If not unit quat then inverse = Conjugate/mag^2. 
		var magSq = MagnitudeSqr();
		if (magSq != 1) {
			var mult = 1/magSq;
			return new Quaternion(-self.x * mult, -self.y * mult, -self.z * mult, self.w * mult);
		}
		//For unit quaternions (where magnitude == 1) the inverse is the same as the conjugate form
		return Conjugate();
	}
	
	/** Returns `true` if this `Quaternion` is a unit quaternion (has a magnitude of 1)
	 * @return {Bool} */
	static IsUnit = function() {
		return (MagnitudeSqr() == 1);
	}	
	
	/** Returns a new `Quaternion` based off the calling quaternion linearly interpolated with another by amount `t`.
	 * @arg {Struct.Quaternion} q The quaternion to interpolate with
	 * @arg {Real} t The amount of interpolation clamped between `0` and `1`
	 * @return {Struct.Quaternion} */
	static Lerp = function(q, t) {
		return Slerp(q, t);
	}
	
	/** Returns a new `Quaternion` based off the calling quaternion linearly interpolated with another by amount `t`.
	 * @arg {Struct.Quaternion} q The quaternion to interpolate with
	 * @arg {Real} t The amount of interpolation
	 * @return {Struct.Quaternion} */	
	static LerpUnclamped = function(q, t) {
		return SlerpUnclamped(q, t);
	}
	
	/** Returns the magnitude of this quaternion
	 * @return {Real} */
	static Magnitude = function() {
		return sqrt(dot_product_3d(self.x, self.y, self.z, self.x, self.y, self.z) + (self.w * self.w));
	}
	
	/** Returns the square of the `Magnitude` of this `Quaternion`
	 * @return {Real} */ 
	static MagnitudeSqr = function() {
		return dot_product_3d(self.x, self.y, self.z, self.x, self.y, self.z) + (self.w * self.w);
	}
	
	/** Returns the product of this quaternion multiplied with another
	  * @arg {Struct.Quaternion} rhs The right hand side quaternion to multiply with
	  * @return {Struct.Quaternion} */
	static Multiply = function(r) { 
		return new Quaternion(
			self.w * r.x + self.x * r.w + self.y * r.z - self.z * r.y,	//x
			self.w * r.y + self.y * r.w + self.z * r.x - self.x * r.z,	//y
			self.w * r.z + self.z * r.w + self.x * r.y - self.y * r.x,	//z
			self.w * r.w - self.x * r.x - self.y * r.y - self.z * r.z	//w
		);
		
	}
	
	/** Returns a quaternion that is this `Quaternion` * -1. 
	 * @return {Struct.Quaternion} */
	static Negate = function() {
		return new Quaternion(-self.x, -self.y, -self.z, -self.w);
	}
	
	/** Modifies this `Quaternion` so that it's magnitude (length) is 1. If you don't want to modify this `Quaternion` use `QuaternionNormalize()` instead.
	 * @return {Struct.Quaternion} */
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
	
	/** Returns a normalized `Quaternion` based on the calling one.
	 * @return {Struct.Quaternion} */
	static Normalized = function() {
		var mag = Magnitude();
		if (mag > 0) {
			var mult = 1/mag;
			return new Quaternion(self.x * mult, self.y * mult, self.z * mult, self.w * mult);			
		}
		return Clone();
	}	
	
	/** Returns a new `Quaternion` based on the calling quaternion rotated towards the specified `to` quaterion by angle `degrees`
	 * @arg {Struct.Quaternion} to The `Quaternion` to rotate in the direction of
	 * @arg {Real} degrees The amount of rotation to apply (in degrees)
	 * @return {Struct.Quaternion} */
	static RotateTowards = function(to, degrees) {
		var _angle = Angle(to);
		if (_angle == 0) {
			return to.Clone();
		}
		else {
			return SlerpUnclamped(to, min(1, degrees/_angle));			
		}
	}
	
	/** Multiplies this quaternion with a vector and returns the result.
	 * @arg {Struct.Vector3} vec3 The vector to multiply with
	 * @return {Struct.Vector3} */
	static RotateVector = function(vec3) {
		//Do math manually to support the vector interface
		var _x = self.x * 2;
		var _y = self.y * 2;
		var _z = self.z * 2;
		
		var _xx = self.x * _x;
		var _yy = self.y * _y;
		var _zz = self.z * _z;
		var _xy = self.x * _y;
		var _xz = self.x * _z;
		var _yz = self.y * _z;
		var _wx = self.w * _x;
		var _wy = self.w * _y;
		var _wz = self.w * _z;
		
		
		var _vx = vec3.x;
		var _vy = vec3.y;
		var _vz = vec3.z;
		return new Vector3(
			(1 - (_yy + _zz)) * _vx + (_xy - _wz) * _vy + (_xz + _wy) * _vz,	//x
			(_xy + _wz) * _vx + (1 - (_xx + _zz)) * _vy + (_yz - _wx) * _vz,	//y
			(_xz - _wy) * _vx + (_yz + _wx) * _vy + (1 - (_xx + _yy)) * _vz,	//z
		);
	}
	
	/** Returns a new `Quaternion` based off the calling quaternion spherically interpolated with another by amount `t`.
	 * @arg {Struct.Quaternion} q The `Quaternion` to interpolate with
	 * @arg {Real} t The amount of interpolation to apply clamped between `0` and `1`
	 * @return {Struct.Quaternion} */
	static Slerp = function(q, t) {
		t = MathClamp01(t);
		return SlerpUnclamped(q, t);
	}
	
	/** Returns a new `Quaternion` based off the calling quaternion spherically interpolated with another by amount `t`.
	 * @arg {Struct.Quaternion} q The `Quaternion` to interpolate with
	 * @arg {Real} t The amount of interpolation to apply
	 * @return {Struct.Quaternion} */
	static SlerpUnclamped = function(q, t) {
		//Can we early exit?
		if (MagnitudeSqr() == 0) {
			if (q.MagnitudeSqr() == 0) {
				return new Quaternion();
			}
			return q.Clone();
		}
		else if (q.MagnitudeSqr() == 0) {
			return Clone();
		}
		
		//Extracting values
		var _qx = q.x;
		var _qy = q.y;
		var _qz = q.z;
		var _qw = q.w;
		
		var _cosHalfHangle = Dot(q);
		if ((_cosHalfHangle >= 1) || (_cosHalfHangle <= -1)) {
			//Angle is 0 so return input
			return Clone();
		}
		else if (_cosHalfHangle < 0) {
			_qx = -_qx;
			_qy = -_qy;
			_qz = -_qz;
			_qw = -_qw;
			_cosHalfHangle = -_cosHalfHangle;
		}
		
		//do proper slerp for big angles
		var result;
		if (_cosHalfHangle < 0.99) {
			var _halfAngle = arccos(_cosHalfHangle);
			var _sinHalfAngle = sin(_halfAngle);
			var _oneOverSin = 1/_sinHalfAngle;
			
			var _blendA = sin(_halfAngle * (1 - t) * _oneOverSin);
			var _blendB = sin(_halfAngle * t) * _oneOverSin;
			
			result = new Quaternion(
				(self.x * _blendA) + (_blendB * _qx),
				(self.y * _blendA) + (_blendB * _qy),
				(self.z * _blendA) + (_blendB * _qz),
				(self.w * _blendA) + (_blendB * _qw)
			);
		}
		//do a regular lerp for small angles
		else {
			result = new Quaternion(lerp(self.x, _qx, t), lerp(self.y, _qy, t), lerp(self.z, _qz, t), lerp(self.w, _qw, t));
		}
		
		//Quaternions should always be normalized.
		return result.Normalize();
	}
	
	
	/** Throw a Quaternion Related Error
	 * @arg {String} func The name of the function throwing the error
	 * @arg {String} desc Brief description of the error
	 * @arg {Struct|Id.Instance} [scope] Optional scope. Default is the current scope.
	 * @return {Undefined} */
	static QuaternionError = function(func, desc, scope = undefined) {
		ThrowException("Quaternion Error!", ExceptionMessage(scope, func, desc));
	}	
	
	#region Private Internal methods
		///@ignore
		static sequenceStrings = ["xyz", "xzy", "yxz", "yzx", "zxy", "zyx"];
		
		/** Used for euler angle sequencing
		 * @ignore
		 * @arg {String} _axis
		 * @return {Real} */
		static ElementaryBasisIndex = function(_axis) {
			if (_axis == "x") {
				return 0;
			}
			else if (_axis == "y") {
				return 1;
			}
			else if (_axis == "z") {
				return 2;
			}
			else {
				ThrowInvalidType("QuaternionElementaryBasisIndex", "_axis", _axis, "x, y, or z", self);
			}
		}
		
		/** Returns the sequence order strings separated into a array
		 * @ignore
		 * @arg {Enum.QuaternionRotationOrder} _sequence
		 * @return {Array<String>} */		
		static SplitRotationOrder = function(_sequence) {
			var _order = [
				string_char_at(sequenceStrings[_sequence], 1),
				string_char_at(sequenceStrings[_sequence], 2),
				string_char_at(sequenceStrings[_sequence], 3),
			];
			return _order;
		}
		
		/** Modify this `Quaternion` to fit the specified Euler's angles representation. These angles are converted into the Quaternion's internal 
		 * ***
		 * Derived from Amy de Buitléir who wrote a paper "Quaternions" where she derived a general use algorithm for converting any Euler's angle rotation order to a quaternion.
		 * @ignore
		 * @arg {Real} _x Rotation angle around x-axis
		 * @arg {Real} _y Rotation angle around y-axis
		 * @arg {Real} _z Rotation angle around z-axis
		 * @arg {String} [_sequence] `[=YXZ]` The rotation sequence the quaternion should use. Defaults to "YXZ" to match the rotation order of GM transformation matricies.
		 * @return {Undefined} */		
		static SetEulerAnglesInternal = function(_x, _y, _z, _sequence = undefined) {
			//Step 1: Extract data from the quaternion in the order specified
			//Getting the order of evaluation
			_sequence ??= QuaternionRotationOrder.YXZ;
			var _axis = SplitRotationOrder(_sequence);
			
			//Assign values from our quaternion according to the evaluation sequence.
			var i = ElementaryBasisIndex(_axis[0]);
			var j = ElementaryBasisIndex(_axis[1]);
			var k = ElementaryBasisIndex(_axis[2]);
			
			//Find the permutation value for our sequence which must be +-1.
			var e = (i-j)*(j-k)*(k-i)/2;			
			
			//Converting angles into half angles in an array for proper sequencing
			var _angles = [_x * 0.5, _y * 0.5, _z * 0.5];
			
			//Find cs for each angle
			var _c1 = dcos(_angles[i]);	//X angle.		
			var _s1 = dsin(_angles[i]);			
			
			var _c2 = dcos(_angles[j]);	//Y angle.		
			var _s2 = dsin(_angles[j]);	
			
			var _c3 = dcos(_angles[k]);	//Z angle.		
			var _s3 = dsin(_angles[k]);						
			
			//Similar to how Quaternion.GetEulerAngles() uses "a,b,c,d" we do the same here, but directly assign as w,x,y,z for optimization
			self.w = (_c3 * _c2 * _c1) - (e *_s3 * _s2 * _s1);	
			self[$ _axis[0]] = (_c3 * _c2 * _s1) + (e * _s3 * _s2 * _c1);	
			self[$ _axis[1]] = (_c3 * _s2 * _c1) - (e * _s3 * _c2 * _s1);	
			self[$ _axis[2]] = (_s3 * _c2 * _c1) + (e * _c3 * _s2 * _s1);
		}
		
	#endregion	
}

///Initialize
new Quaternion();
