//feather ignore all
 
/** EnterableStateContainer: Represents a collection of enterable states.
 * @return {Struct.EnterableStateContainer} */
function EnterableStateContainer() constructor {
	
	///@ignore list of all states the container holds
	states = [];
	
	///@ignore List of just the atomic states the container holds
	atomicStates = [];
	
	
	/** Wrapper so we can typecast `EnterableState` to the states and atomicStates arrays.
	 * @ignore
	 * @arg {Array<Struct.EnterableState>} _array
	 * @arg {Struct.EnterableState} _state
	 * @return {Undefined} */
	static AddUniqueState = function(_array, _state) {
		return ArrayPushUnique(_array, _state);
	}
	
	/** Returns the total number of states in this container
	 * @return {Real} */
	static StateCount = function() {
		return array_length(states);
	}
	
	/** Returns the total number of atomic states in this container
	 * @return {Real} */
	static AtomicStateCount = function() {
		return array_length(atomicStates);
	}
	
	/** Returns an array of all the enterable states held by this container.
	 * @return {Array<Struct.EnterableState>} */
	static GetStates = function() {
		return states;
	}
	
	/** Returns a struct of all active atomic states
	 * @return {Array<Struct.EnterableState>} */
	static GetAtomicStates = function() {
		return atomicStates;
	}
	
	/** Returns the number of active atomic states in this container
	 * @return {Real} */
	static GetAtomicStateCount = function() {
		return array_length(atomicStates);
	}
	
	/** Returns the total number of active states in this container
	 * @return {Real} */
	static GetActiveStateCount = function() {
		return array_length(states);
	}
	
	/** Add/Enter an active state.
	 * @arg {Struct.EnterableState} _state The state to enter.
	 * @return {Undefined} */
	static AddState = function(_state) {
		if (!AddUniqueState(states, _state)) {
			StateError("EnterState", $"Added State {_state.GetId()} is not unique!");
		}
		if (_state.IsAtomicState()) {
			if (!AddUniqueState(atomicStates, _state)) {
				StateError("EnterState", $"Added Atomic State {_state.GetId()} is not unique!");
			}
		}
	}
	
	/** Remove a state from this container.
	 * @arg {Struct.EnterableState} _state The state to exit
	 * @return {Undefined} */
	static RemoveState = function(_state) {
		if (!ArrayRemove(states, _state)) {
			StateError("ExitState", $"State {_state.GetId()} does not exist!");
		}
		ArrayRemove(atomicStates, _state);
	}
	
	/** Removes all active states from this container.
	 * @return {Undefined} */
	static Clear = function() {
		ArrayClear(states);
		ArrayClear(atomicStates);
	}
	
	/** Returns `true` if the specified state is in this container.
	 * @arg {Struct.EnterableState} _state The state to check
	 * @return {Bool} */
	static HasState = function(_state) {
		return array_contains(states, _state);
	}
	
	/** Returns the single top level `FinalState` in which the machine terminated, or `undefined` otherwise.
	 * @return {Struct.FinalState} */
	static GetTopLevelFinalState = function() {
		if (array_length(atomicStates) == 1) {
			var _es = atomicStates[0];
			if (StateIsFinal(_es) && (!is_undefined(_es.GetParent()))) {
				return _es;
			}
		}
	}
	
	/** Returns `true` if this container has reached a top level final state AND the machine has been terminated.
	 * @return {Bool} */
	static IsFinal = function() {
		return (!is_undefined(GetTopLevelFinalState()));
	}	
}