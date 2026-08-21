//feather ignore all

/** QuaternionAngleAxis: Stores the extracted components of a `Quaternion`.
 * @arg {Struct.Quaternion} q The `Quaternion` instance to extract data from
 * @return {Struct.QuaternionAngleAxis} */
function QuaternionAngleAxis(q) constructor {
	
	///@ignore The angle of rotation derived from the parent quaternion
	angle = undefined;
	
	///@ignore The axis of rotation derived from the parent quaternion
	axis = undefined;
	
	Extract(q);
	
	/** Returns the angle of rotation in degrees for the owning quaternion
	 * @return {Real} */
	static GetAngle = function() {
		return self.angle;
	}
	
	/** Returns the axis of rotation as a direction vector
	 * @return {Struct.Vector3} */
	static GetAxis = function() {
		return self.axis;
	}
	
	/** Extracts the angle and axis of rotation from the specified quaternion. Results can be retrieved by calling `GetAngle()` and `GetAxis()`
	 * @arg {Struct.Quaternion} q The quaternion to extract from
	 * @return {Undefined} */
	static Extract = function(q) {
		if (LINEAR_ALGEBRA_SAFETY_CHECKS) {
			if (!is_instanceof(q, Quaternion)) {
				ThrowInvalidType("Extract", "q", q, "Quaternion");
			}		
		}
		
		//Extracting	
		if (abs(q.w > 1)) {
			q = q.Normalized();
		}
		self.angle = radtodeg(arccos(q.w));
		
		var denominator = sqrt(1 - (q.w*q.w));
		if (denominator > 0.00001) {
			var _mult = 1/denominator;
			self.axis = new Vector3(q.x*_mult, q.y*_mult, q.z*_mult);
		}
		else {
			self.axis = Vector3.Right();
		}		
	}
}