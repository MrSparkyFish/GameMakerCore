//feather ignore all

/** Creates a scale matrix
 * @arg {Real} x Scale X
 * @arg {Real} y Scale Y
 * @arg {Real} z Scale Z
 * @arg {Array<Real>} [matrix] Optional matrix to modify
 * @return {Array<Real>} */	
function MatrixCreateScale(x, y, z, matrix = matrix_build_identity()) {
	return matrix_build(0, 0, 0, 0, 0, 0, x, y, z, matrix);
}

/** Creates a rotation matrix from the specified angles of rotation
 * ***
 * For 2D rotation, set `x` and `y` to `0` and pass your rotation value to `z` 
 * @arg {Real} x Rotation X in degrees
 * @arg {Real} y Rotation Y in degrees
 * @arg {Real} z Rotation Z in degrees
 * @arg {Array<Real>} [matrix] Optional matrix to modify 
 * @return {Array<Real>} */
function MatrixCreateRotation(x, y, z, matrix = matrix_build_identity()) {
	return matrix_build(0, 0, 0, x, y, z, 1, 1, 1, matrix);
}

/** Creates a translation matrix
 * @arg {Real} x Position X
 * @arg {Real} y Position Y
 * @arg {Real} z Position Z
 * @arg {Array<Real>} [matrix] Optional matrix to modify
 * @return {Array<Real>} */	
function MatrixCreateTranslation(x, y, z, matrix = matrix_build_identity()) {
	return matrix_build(x, y, z, 0, 0, 0, 1, 1, 1, matrix);
}

/** Creates a rotation matrix using vectors representing translation, rotation, and scale.
 * @arg {Struct.Vector3} position The xyz position
 * @arg {Struct.Quaternion} rotation The xyz rotation in degrees
 * @arg {Struct.Vector3} scale The xyz scale where.
 * @arg {Array<Real>} [matrix] Optional matrix to modify
 * @return {Array<Real>} */		
function MatrixCreateTransformation(position, rotation, scale, matrix = matrix_build_identity()) {
	var euler = rotation.GetEulersAngles();
	return matrix_build(position.x, position.y, position.z, euler.x, euler.y, euler.z, scale.x, scale.y, scale.z, matrix);	
}

/** Create a matrix with the specified position and rotation
 * @arg {Struct.Vector3} position The position used to create the matrix
 * @arg {Struct.Quaternion} rotation Angles used to create the matrix
 * @arg {Array<Real>} [matrix] Optional matrix to modify
 * @return {Array<Real>} */
function MatrixCreatePositionAndRotation(position, rotation, matrix = matrix_build_identity()) {
	var euler = rotation.GetEulersAngles();
	return matrix_build(position.x, position.y, position.z, euler.x, euler.y, euler.z, 1, 1, 1, matrix);
}


/** Returns the main diagonal of a matrix as a `Vector4`
 * @arg {Array<Real>} matrix A 4x4 matrix
 * @return {Struct.Vector4} */
function MatrixGetDiagonal4(matrix) {
	return new Vector4(matrix[0], matrix[5], matrix[10], matrix[15]);
}

/** Returns the main diagonal of a matrix as a `Vector3`
 * @arg {Array<Real>} matrix A 4x4 matrix
 * @return {Struct.Vector3} */
function MatrixGetDiagonal3(matrix) {
	return new Vector3(matrix[0], matrix[5], matrix[10]);
}

/** Return a column of a 4x4 matrix as a `new Vector4`
 * @arg {Array<Real>} matrix The matrix to get a column from
 * @arg {Real} index The index of a column to get from `0` to `3`
 * @return {Struct.Vector4} */
function MatrixGetColumn(matrix, index) {
	index = 4 * clamp(index, 0, 3);
	return new Vector4(matrix[index], matrix[index + 1], matrix[index + 2], matrix[index + 3]);
}

/** Set the values of a 4x4 matrix column
 * @arg {Array<Real>} matrix The matrix to set a column for
 * @arg {Real} index The index of the column from `0` to `3`
 * @arg {Real} x
 * @arg {Real} w
 * @arg {Real} z
 * @arg {Real} w
 * @return {Undefined} */
function MatrixSetColumn(matrix, index, x, y, z, w) {
	index = 4 * clamp(index, 0, 3);
	matrix[index] = x;
	matrix[index+1] = y;
	matrix[index+2] = z;
	matrix[index+3] = w;
}

/** Set the values of a 4x4 matrix column using an array
 * @arg {Array<Real>} matrix The matrix to set a column for
 * @arg {Real} index The index of the column from `0` to `3`
 * @arg {Array<Real>} _array The array to use
 * @return {Undefined} */
function MatrixSetColumnArray(matrix, index, _array) {
	MatrixSetColumn(matrix, index, _array[0], _array[1], _array[2], _array[3]);
}

/** Set a column of a 4x4 matrix using a `Vector4`
 * @arg {Array<Real>} matrix The matrix to set a column for
 * @arg {Real} index The index of the column from `0` to `3`
 * @arg {Struct.Vector4} vector The vector to use as the column
 * @return {Undefined} */
function MatrixSetColumnVector(matrix, index, vector) {
	MatrixSetColumn(matrix, index, vector.x, vector.y, vector.z, vector.w);
}

/** Returns a row of a 4x4 matrix as a `new Vector4`
 * @arg {Array<Real>} matrix The matrix to get a row from
 * @arg {Real} index The index of a row to get from `0` to `3`
 * @return {Struct.Vector3} */
function MatrixGetRow(matrix, index) {
	index = clamp(index, 0, 3);
	return new Vector4(matrix[index], matrix[index + 4], matrix[index + 8], matrix[index + 12]);
}

/** Attempts to return scale from the specified matrix
 * @arg {Array<Real>} matrix The matrix to attempt to get scale from
 * @return {Struct.Vector3} */
function MatrixGetLossyScale(matrix) {
	var _column1 = new Vector3(matrix[0], matrix[1], matrix[2]);
	var _column2 = new Vector3(matrix[4], matrix[5], matrix[6]);
	var _column3 = new Vector3(matrix[8], matrix[9], matrix[10]);
	var _result = new Vector3(_column1.Magnitude(), _column2.Magnitude(), _column3.Magnitude());
	return _result;
}

/** Set the values of a 4x4 matrix row
 * @arg {Array<Real>} matrix The matrix to set a row for
 * @arg {Struct.Vector4} vector The vector to use as the row
 * @arg {Real} index The index of the row from `0` to `3`
 * @arg {Real} x
 * @arg {Real} w
 * @arg {Real} z
 * @arg {Real} w
 * @return {Undefined} */
function MatrixSetRow(matrix, index, x, y, z, w) {
	index = clamp(index, 0, 3);
	matrix[index] = x;
	matrix[index + 4] = y;
	matrix[index + 8] = z;
	matrix[index + 12] = w;	
}

/** Set a row of a 4x4 matrix using a `Vector4`
 * @arg {Array<Real>} matrix The matrix to set a row for
 * @arg {Real} index The index of the row to set from `0` to `3`
 * @arg {Struct.Vector4} vector The vector to use 
 * @return {Undefined} */	
function MatrixSetRowVector(matrix, index, vector) {
	MatrixSetRow(matrix, index, vector.x, vector.y, vector.z, vector.w);
}

/** Set a row of a 4x4 matrix using an array of values
 * @arg {Array<Real>} matrix The matrix to set a row for
 * @arg {Real} index The index of the row to set from `0` to `3`
 * @arg {Array<Real>} _array The array to use 
 * @return {Undefined} */	
function MatrixSetRowArray(matrix, index, _array) {
	MatrixSetRow(matrix, index, _array[0], _array[1], _array[2], _array[3]);
}

/** Build a "LookAt" matrix using vectors `from`, `to`, and `up`
 * @arg {Struct.Vector3} from
 * @arg {Struct.Vector3} to
 * @arg {Struct.Vector3} up `[=Vector3Up]`
 * @arg {Array<Real>} [matrix] Optional matrix to modify with the results.
 * @return {Array<Real>} */
function MatrixLookAt(from, to, up = undefined, matrix = array_create(16)) {
	up ??= Vector3.Up();
	return matrix_build_lookat(from.x, from.y, from.z, to.x, to.y, to.z, up.x, up.y, up.z, matrix);
}

/** Returns the position vector from a 4x4 transformation matrix
 * @return {Struct.Vector3} */
function MatrixGetPosition(matrix) {
	return new Vector3(matrix[12], matrix[13], matrix[14]);
}

/** Returns the determinante value of a 4x4 matrix.
 * @arg {Array<Real>} matrix The matrix to get the determinant of
 * @return {Real} */
function MatrixGetDeterminate(matrix) {
	//index numbers
	//0, 4, 8, 12	column1 index numbers [0, 1, 2, 3]
	//1, 5, 9, 13	column2 index numbers [4, 5, 6, 7]
	//2, 6, 10, 14	column3 index numbers [8, 9, 10, 11]
	//3, 7, 11, 15	column4 index numbers [12, 13, 14, 15];	
	
	//Positive half
	var a = matrix[0] * matrix[5] * matrix[10] * matrix[15];
	var b = matrix[4] * matrix[9] * matrix[14] * matrix[3];
	var c = matrix[8] * matrix[13] * matrix[2] * matrix[7];
	var d = matrix[12] * matrix[1] * matrix[6] * matrix[11];
	
	//Negative half
	var e = matrix[12] * matrix[9] * matrix[6] * matrix[3];
	var f = matrix[8] * matrix[5] * matrix[2] * matrix[15];
	var g = matrix[4] * matrix[1] * matrix[14] * matrix[11];
	var h = matrix[0] * matrix[13] * matrix[10] * matrix[7];
	
	return a + b + c + d - e - f - g - h;
}

/** Returns `true` if the specified matrix is an identity matrix
 * @arg {Array<Real>} matrix The matrix to check
 * @return {Undefined} */
function MatrixIsIdentity(matrix) {
	///@ignore
	static identity = matrix_build_identity();
	
	if (array_length(matrix) != 16) {
		return false;
	}
	for (var i = 0; i < 16; i++) {
		if (matrix[i] != identity[i]) {
			return false;
		}
	}
	return true;
}

/** Multiply a matrix and a vector
 * @arg {Array<Real>} mat The matrix to multiply
 * @arg {Struct.Vector2} vec2 The vector to multiply with
 * @return {Struct.Vector2} */
function MatrixTransformVector2(mat, vec2) {
	///@ignore
	static transformedPoint = [0, 0, 0, 0];
	matrix_transform_vertex(mat, vec2.x, vec2.y, 1, 1, transformedPoint);
	return Vector2.CreateFromArray(transformedPoint);
}

/** Multiply a matrix and a vector
 * @arg {Array<Real>} mat The matrix to multiply
 * @arg {Struct.Vector3} vec3 The vector to multiply with
 * @return {Struct.Vector3} */
function MatrixTransformVector3(mat, vec3) {
	///@ignore
	static transformedPoint = [0, 0, 0, 0];
	matrix_transform_vertex(mat, vec3.x, vec3.y, vec3.z, 1, transformedPoint);
	return Vector3.CreateFromArray(transformedPoint);
}

/** Multiply a matrix and a vector
 * @arg {Array<Real>} mat The matrix to multiply
 * @arg {Struct.Vector4} vec4 The vector to multiply with
 * @return {Struct.Vector4} */
function MatrixTransformVector4(mat, vec4) {
	///@ignore
	static transformedPoint = [0, 0, 0, 0];
	matrix_transform_vertex(mat, vec4.x, vec4.y, vec4.z, vec4.z, transformedPoint);
	return Vector4.CreateFromArray(transformedPoint);	
}

/** Modifies a 4x4 matrix so its columns become its rows (ie: Column 1 becomes row 1, column 2 becomes row 2, etc)
 * @arg {Array<Real>} matrix The matrix to modify
 * @return {Undefined} */
function MatrixTranspose(matrix) {
	var _columnA = MatrixGetColumn(matrix, 0);
	var _columnB = MatrixGetColumn(matrix, 1);
	var _columnC = MatrixGetColumn(matrix, 2);
	var _columnD = MatrixGetColumn(matrix, 3);
	MatrixSetRowVector(matrix, 0, _columnA);
	MatrixSetRowVector(matrix, 1, _columnB);
	MatrixSetRowVector(matrix, 2, _columnC);
	MatrixSetRowVector(matrix, 3, _columnD);
}