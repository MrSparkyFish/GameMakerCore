//feather ignore all

/** InputCluster: A Cluster can be thought of as a type of positional verb. They're used by the system to evaluate 4 directional inputs (Up, Down, Left, and Right) in order to derive, for example, the direction and magnitude of player movement.
 * @arg {Enum.Input_Cluster} _clusterIndex Cluster enum value
 * @arg {Enum.Input_Verb} _verbUp Up verb index
 * @arg {Enum.Input_Verb} _verbDown Down verb index
 * @arg {Enum.Input_Verb} _verbLeft Left verb index
 * @arg {Enum.Input_Verb} _verbRight Right verb index
 * @arg {Real} [_axisBias] Adds straight line bias to the cluster making it easier for the player to move in straight lines. Should be a value between 0 and 1 where 0 = no bias and 1 is complete bias. Defaults to 0.
 * @arg {Bool} [_axisBiasDiag] Whether or not `_axisBias` should be applied to diagonals. Default value is false.
 * @return {Struct.InputCluster} */
function InputCluster(_clusterIndex, _verbUp, _verbDown, _verbLeft, _verbRight, _thresholdType = Input_ClusterThresholdType.both, _axisBias = 0, _axisBiasDiag = false) constructor {
	
	//Used as indicators for gamepad stick hotswap thresholds
	enum Input_ClusterThresholdType {
		left, 																		//Index for left stick
		right,																		//Index for right stick
		both,																		//Both sticks
		none																		//Empty
	}		
	
	#region Cluster Internal
		///@ignore
		index = _clusterIndex;														//Index of this cluster
		///@ignore
		verbUp = _verbUp;															//Index of the Verb that will detect up
		///@ignore
		verbDown = _verbDown;														//Index of the Verb that will detect down
		///@ignore
		verbLeft = _verbLeft;														//Index of the Verb that will detect left
		///@ignore
		verbRight = _verbRight;														//Index of the Verb that will detect right
		///@ignore
		axisBiasFactor = clamp(_axisBias, 0, 1);									//Bias factor for movement displacement
		///@ignore
		axisBiasDiag = _axisBiasDiag;												//If bias factor should be applied to diagonal inputs
		///@ignore
		thresholdType = _thresholdType;												//Threshold type for an input that will trigger a hotswap
		
	#endregion
	
	
	#region Cluster Basics
		
		/** Returns the index of the verb assigned to Up
		 * @return {Real} */
		static VerbIndexUp = function() {
			INLINE;
			return verbUp;
		}
		
		/** Returns the index of the verb assigned to Down
		 * @return {Real} */
		static VerbIndexDown = function() {
			INLINE;
			return verbDown;
		}
		
		/** Returns the index of the verb assigned to Right
		 * @return {Real} */
		static VerbIndexRight = function() {
			INLINE;
			return verbRight;
		}
		
		/** Returns the index of the verb assigned to Left
		 * @return {Real} */
		static VerbIndexLeft = function() {
			INLINE;
			return verbLeft;
		}
		
		/** Returns the factor of axis bias for movement
		 * @return {Real} */
		static AxisBias = function() {
			INLINE;
			return axisBiasFactor;
		}
		
		/** Returns if axis bias should be applied to diagonals.
		 * @return {Bool} */
		static UsesDiagonalBias = function() {
			INLINE;
			return axisBiasDiag;
		}
		
		/** Returns the assigned `Input_ClusterThresholdType` enum value.
		 * @return {Real} */ 
		static ThresholdGetType = function() {
			INLINE;
			return thresholdType;
		}
		
		/** Sets the threshold type of this cluster
		 * @arg {Enum.Input_ClusterThresholdType} _type
		 * @return {Undefined} */
		static ThresholdSetType = function(_type) {
			INLINE;
			thresholdType = _type;
		}
		
		/** Returns the index of this cluster definition
		 * @arg {Real} */
		static GetIndex = function() {
			INLINE;
			return index;
		}
		
	#endregion
}