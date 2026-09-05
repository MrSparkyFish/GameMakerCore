//feather ignore all


#region Helper Funcs
	
	/** Returns the mask value when only the specified bit index is set to 1 
	 * @arg {Real} bitIndex The bit index (from 0 to 63) to get the value for
	 * @return {Real} */
	function BitMask_BitValue(bitIndex) {
		INLINE;
		return (1<<bitIndex);
	}	
	
#endregion


#region Mask Comparisons
	
	/** Returns `true` if the calling bitMask has any active bit that is also active in another bitMask.
	 * For example: Calling mask `0110` and _bitMask `0010` would return true because they both have at least 1 matching active bit
	 * @arg {Real} a The mask to check
	 * @arg {Real} b The mask to compare to
	 * @return {Bool} */
	function BitMask_MatchesAny(a, b) {
		return (a == b) ? true : bool(a & b);
	}
	
	/** Returns `true` if the calling mask has the same bits active as the argument mask.
	 * ***
	 * For example: Calling mask `0110` and _bitMask `0010` would return `true` because the calling mask contains a matching bit for 
	 * every active bit in _bitMask
	 * ***
	 * similarly, calling mask `0110` and _bitMask `1010` would return false because the calling mask doesn't have a matching bit 
	 * for every active bit in _bitMask
	 * @arg {Real} a The mask to check.
	 * @arg {Real} b The mask to compare to
	 * @return {Bool} */
	function BitMask_MatchesAll(a, b) {
		//All bits match if they're the same value
		if (a == b) {
			return true;
		}
		//Otherwise check bits
		var _mask = b;
		var _val = a & _mask;
		return ((_val & a) == (_val & _mask));
	}
	
	/** Returns `true` if the calling mask has no active bits that overlap with the argument mask.
	* @arg {Real} a The mask to check
	* @arg {Real} b The mask to check
	* @return {Bool} */
	function BitMask_MatchesNone(a, b) {
		return ((a & b) == 0);
	}			
	
	/** Returns `true` if no bits of the current mask are active
	 * @arg {Real} mask The mask to check
	* @return {Bool} */
	function BitMask_NoActiveBits(mask) {
		return (mask == 0);
	}
	
	/** Returns `true` if any bit in the current mask is active
	* @return {Bool} */
	function BitMask_AnyActiveBits(mask) {
		return (mask != 0);
	}	
	
	/** Returns `true` if all bits of the current mask are active.
	* @return {Bool} */
	function BitMask_AllActiveBits(mask) {
		return (mask == -1);
	}
	
#endregion


#region Single bit operations
	
	/** Returns a value that is the specified mask value shifted by value `n`. Optionally set the shift direction to right or left.
	 * @arg {Real} mask The mask to get the left shift for
	 * @arg {Real} n The number of places to shift.
	 * @arg {Bool} [left] `[=true]` Set `true` to shift left (multiply) or `false` to shift right (divide).
	 * @return {Real} */
	function BitMask_ShiftMask(mask, n, left = true) {
		var value = (left) ? (mask << n) : (mask >> n);
		return value;
	}
	
	/** Returns a mask value that is the input value with the specified bit number set to 1.
	 * @arg {Real} mask The initial mask value
	 * @arg {Real} bitIndex The bit you want to enable (0 to 63)
	 * @return {Real} */
	function BitMask_EnableBit(mask, bitIndex) {
		var value = mask | BitMask_BitValue(bitIndex);
		return value;
	}	
	
	/** Returns a mask value where all bits are set to 0 and the specified bit is set to 1.
	 * @arg {Real} _bitIndex The bit you want to enable (0 to 63)
	 * @return {Real} */
	function BitMask_EnableBitExclusive(bitIndex) {
		return BitMask_EnableBit(0, bitIndex);
	}	
	
	/** Returns a mask value that is the input value with the specified bit set to 0.
	 * @arg {Real} mask The initial mask value
	 * @arg {Real} bitIndex The bit you want to disable
	 * @return {Real} */
	function BitMask_DisableBit(mask, bitIndex) {
		var value = (mask & (~BitMask_BitValue(bitIndex)));
		return value;
		//mask &= ~(BitMask_BitValue(bitIndex));
		//return mask;
	}
	
	/** Returns a mask value where all bits are set to 1 and the specified bit is set to 0.
	* @arg {Real} _bitIndex The bit you want to disable	
	* @return {Real} */	
	function BitMask_DisableBitExclusive(bitIndex) {
		//var value = (-1 ^ BitMask_BitValue(bitIndex));
		return BitMask_DisableBit(-1, bitIndex);
	}
	
	/** Returns a mask value that is the input value with all the bit indicies held by the specified array set to 0.
	 * ***
	 * For example, if we input a mask value of 12 with an array of bit indicies [0, 2], the output value will be 8.
	 * Since bit index 0 is already inactive in the value 12, it only turns off index 2 which leaves us with 8.
	 * @arg {Real} mask 
	 * @arg {Array<Real>} bits Array of bit index values to set to 0
	 * @return {Real} */
	function BitMask_DisableBitGroup(mask, bits) {
		var len = array_length(bits);
		for (var i = 0, value; i < len; i++) {
			mask = BitMask_DisableBit(mask, bits[i]);
		}
		return mask;
	}
	
	/** Sets a series of mask bits to 1.
	 * @arg {Real|Array<Real>} bits Array of bit index values to set to 1
	 * @return {Undefined} */
	function BitMask_EnableBitGroup(mask, bits) {
		var len = array_length(bits);
		for (var i = 0; i < len; i++) {
			mask = BitMask_EnableBit(mask, bits[i]);
		}
		return mask;
	}
	
	/** Returns the mask value that is the input value with the specified bit set to a 1 or 0.
	 * @arg {Real} mask The input value
	 * @arg {Real} bitIndex The bit index to set (0 to 63)
	 * @arg {Bool} state The state of the bit to set (1 or 0).
	 * @return {Undefined} */
	function BitMask_SetBitState(mask, bitIndex, state) {
		var value = (state) ? BitMask_EnableBit(mask, bitIndex) : BitMask_DisableBit(mask, bitIndex);
		return value;
	}
	
	/** Returns a mask value that is the input value with all the specified bit's set to be active or inactive
	 * @arg {Real} mask The input value
	 * @arg {Array<Real>} bitIndicies Array of bits to set
	 * @arg {Bool} state Set each bit in the array to 1 or 0
	 * @return {Undefined} */
	function BitMask_SetBitGroup(mask, bitIndicies, state) {
		var len = array_length(bitIndicies);
		for (var i = 0; i < len; i++) {
			mask = BitMask_SetBitState(mask, bitIndicies[i], state);
		}
	}
	
	/** Return a mask value that is the input value with the specified bit toggled from its current state.
	* @arg {Real} bitIndex The bit index to toggle (0 to 63)
	* @return {Undefined} */
	function BitMask_ToggleBit(mask, bitIndex) {
		var value = (mask ^ BitMask_BitValue(bitIndex));
		return value;
	}
	
	/** Returns true if the specified bit index is set to 1 in the specified mask value.
	 * @arg {Real} mask The mask value to check
	 * @arg {Real} bitIndex The bit index to check (0 to 63)
	 * @return {Bool} */
	function BitMask_IsBitActive(mask, bitIndex) {
		var val = BitMask_BitValue(bitIndex);
		return ((mask & val) == val); 
	}	
#endregion







/** BitMask: Represents a 64bit mask and provides methods for easily manipulating mask bits.
 * ***
 * Just use global functions
 * @deprecated
 * @ignore
 * @arg {Real} _initValue The initial value of the bitmask. Defaults to 0.
 * @return {Struct.BitMask} */
function BitMask(_initValue = 0) constructor {
	
	
	#region Private
		
		///@ignore
		mask = int64(_initValue);
		
		/** Returns the bit value of a bit index
		 * @arg {Real} _bitIndex The bit index (from 0 to 63) to get the value for
		 * @return {Real} */
		static BitIndexValue = function(_bitIndex) {
			return (1<<_bitIndex);
		}	
		
	#endregion
	
	
	#region Mask Settings
		
		/** Sets a new value for the mask. If you need to activate all bits, assign a value of `-1`. This works because `-1` in binary
		 * is represented by setting all bits to 1. Similarly, if you need to deactivate all bits, simply assign a value of `0`.
		 * @arg {Real} _maskValue The value to set for the mask
		 * @return {Undefined} */	
		static SetMask = function(_maskValue) {
			mask = _maskValue;
		}
		
		/** Shift the mask value. This effectively multiplies or divides the mask value by (2^n)
		 * @arg {Real} _n The number of places to shift.
		 * @arg {Bool} [_left] `[=true]` Set `true` to shift left (multiply) or `false` to shift right (divide).
		 * @return {Undefined} */
		static ShiftMask = function(_n, _left = true) {
			 mask = (_left) ? (mask << _n) : (mask >>_n);
		}
		
		/** Returns `true` if the calling bitMask has any active bit that is also active in another bitMask.
		 * For example: Calling mask `0110` and _bitMask `0010` would return true because they both have at least 1 matching active bit
		 * @arg {Struct.BitMask} _bitMask The sub mask to check
		 * @return {Bool} */
		static MatchesAny = function(_bitMask) {
			return (mask == _bitMask.mask) ? true : bool(mask & _bitMask.mask);
		}
		
		/** Returns `true` if the calling mask has the same bits active as the argument mask.
		 * ***
		 * For example: Calling mask `0110` and _bitMask `0010` would return `true` because the calling mask contains a matching bit for 
		 * every active bit in _bitMask
		 * ***
		 * similarly, calling mask `0110` and _bitMask `1010` would return false because the calling mask doesn't have a matching bit 
		 * for every active bit in _bitMask
		 * @arg {Struct.BitMask} _bitMask The sub mask to check.
		 * @return {Bool} */
		static MatchesAll = function(_bitMask) {
			//All bits match if they're the same value
			if (mask == _bitMask.mask) {
				return true;
			}
			//Otherwise check bits
			var _mask = _bitMask.mask;
			var _val = mask & _mask;
			return ((_val & mask) == (_val & _mask));
		}
		
		/** Returns `true` if the calling mask has no active bits that overlap with the argument mask.
		 * @arg {Struct.BitMask} _bitMask The sub mask to check
		 * @return {Bool} */
		static MatchesNone = function(_bitMask) {
			return ((mask & _bitMask.mask) == 0);
		}			
		
		/** Returns `true` if no bits of the current mask are active
		 * @return {Bool} */
		static NoActiveBits = function() {
			return (mask == 0);
		}
		
		/** Returns `true` if any bit in the current mask is active
		 * @return {Bool} */
		static AnyActiveBits = function() {
			return (mask != 0);
		}	
		
		/** Returns `true` if all bits of the current mask are active.
		 * @return {Bool} */
		static AllActiveBits = function() {
			return (mask == -1);
		}
		
	#endregion
	
	
	#region Single bit manipulation
		/** Sets a mask bit to 1.
		 * @arg {Real} _bitIndex The bit you want to enable (0 to 63)
		 * @return {Undefined} */
		static EnableBit = function(_bitIndex) {
			 mask |= BitIndexValue(_bitIndex);
		}	
		
		/** Sets a mask bit to 1 and all other bits to 0
		 * @arg {Real} _bitIndex The bit you want to enable (0 to 63)
		 * @return {Undefined} */
		static EnableBitExclusive = function(_bitIndex) {
			mask = 0 ^ BitIndexValue(_bitIndex);
		}	
		
		/** Sets a mask bit to 0.
		 * @arg {Real} _bitIndex The bit you want to disable
		 * @return {Undefined} */
		static DisableBit = function(_bitIndex) {
			 mask &= ~(BitIndexValue(_bitIndex));
		}
		
		/** Sets a mask bit to 0 and all other bits to 1
		 * @arg {Real} _bitIndex The bit you want to disable	
		 * @return {Undefined} */	
		static DisableBitExclusive = function(_bitIndex) {
			mask = -1 ^ BitIndexValue(_bitIndex);
		}
		
		/** Sets an array of mask bits to 0.
		 * @arg {Array<Real>} _bits Array of bit index values to set to 0
		 * @return {Undefined} */
		static DisableBitGroup = function(_bits) {
			_bits = ArrayConvertValue(_bits);
			array_foreach(_bits, DisableBit);
		}
		
		/** Sets a series of mask bits to 1.
		 * @arg {Real|Array<Real>} _bits Array of bit index values to set to 1
		 * @return {Undefined} */
		static EnableBitGroup = function(_bits) {
			_bits = ArrayConvertValue(_bits);
			array_foreach(_bits, EnableBit);
		}
		
		/** Sets the activity state of the specified bit
		 * @arg {Real} _bitIndex The bit index to set (0 to 63)
		 * @arg {Bool} _bool The state of the bit to set (1 or 0).
		 * @return {Undefined} */
		static SetBitState = function(_bitIndex, _bool) {
			return (_bool) ? EnableBit(_bitIndex) : DisableBit(_bitIndex);
		}
		
		/** Set a group of bits to be active or inactive
		 * @arg {Array<Real>} _bitIndicies Array of bits to set
		 * @arg {Bool} _bool Set each bit in the array to 1 or 0
		 * @return {Undefined} */
		static SetBitGroup = function(_bitIndicies, _bool) {
			_bitIndicies = ArrayConvertValue(_bitIndicies);
			var i = 0; repeat(array_length(_bitIndicies)) {
				SetBitState(_bitIndicies[i++], _bool);
			}
		}
		
		/** Toggles a bit
		 * @arg {Real} _bitIndex The bit index to toggle (0 to 63)
		 * @return {Undefined} */
		static ToggleBit = function(_bitIndex) {
			mask = mask ^ BitIndexValue(_bitIndex);
		}
		
		/** Returns true if the argument bitNumber is active.
		 * @arg {Real} _bitIndex The bit index to check (0 to 63)
		 * @return {Bool} */
		static IsBitActive = function(_bitIndex) {
			var _val = BitIndexValue(_bitIndex);
			return ((mask & _val) == _val); 
		}	
	#endregion
}