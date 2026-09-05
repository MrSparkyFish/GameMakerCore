//feather ignore all
 
/** StateChartManager: Singleton object that stores and manages state charts. This object is required to ensure transition ID's targeted by 
 * transitions are correctly replaced with the TransitionTargets they refer to. It's what enables you to set up a transition's target using only the 
 * target's ID.
 * @return {Struct.StateChartManager} */
function StateChartManager() constructor {
	
	static machines = {};
	
	
	/** Add a `StateChart` model to the system.
	 * @arg {Struct.StateChart} _stateMachine The state machine to add
	 * @return {Undefined} */
	static AddMachineModel = function(_stateMachine, _machineName = undefined) {
		
		_machineName ??= instanceof(_stateMachine);
		_stateMachine.SetName(_machineName);
		
		//Add the machine to the list of available machines.
		machines[$ _machineName] = _stateMachine;
		
		//Update its model so that it's transitions actually target something.
		UpdateMachineModel(_stateMachine);
	}
	
	/** Returns the `StateChart` associated with the specified name or `undefined` if the machine doesn't exist
	 * @arg {String} _machineName The name of the machine to get.
	 * @return {Struct.StateChart} */
	static GetMachineModel = function(_machineName) {
		return machines[$ _machineName];
	}
	
	/** Maps the correct `TransitionTarget` instance to the targeted id for by all `SimpleTransition` objects related to the specified `StateChart`. 
	 * Performs error checking and ensures each transition has valid target for its targeted ID(s).
	 * @arg {Struct.StateChart} _stateMachine The machine to update
	 * @return {Undefined} */
	static UpdateMachineModel = function(_stateMachine) {
		InitializeDocumentOrder(_stateMachine.GetChildren(), 1);
		
		var _initial = _stateMachine.GetInitial();
		var _initialTransition = new SimpleTransition();
		
		//Update the machine's initial transition so that it will be able to enter its first state
		if (!is_undefined(_initial)) { 
			_initialTransition.SetNext(_initial);
			UpdateTransition(_initialTransition, _stateMachine);
			
			//If no target was set for the transition, then something went wrong
			if (ArrayIsEmpty(_initialTransition.GetTargets())) {
				StateError("UpdateMachineModel", $"InitialState transition target not found for StateChart [name: {_stateMachine.GetName()}]");
			}
		}
		
		//If an `InitialState` wasnt specified, use the first state that was added to the machine
		else {
			array_push(_initialTransition.GetTargets(), _stateMachine.GetFirstChild());
		}
		
		//Set the transition so the machine can enter the first state when registered to an SSC
		_stateMachine.SetInitialTransition(_initialTransition);
		
		
		//Map target references to the targeted ID's for the transitions assigned to the states of this machine.
		var _states = _stateMachine.GetChildren();
		var _len = array_length(_states);
		var _es = undefined;
		for (var i = 0; i < _len; i++) {
			var _es = _states[i];
			
			if (StateIsState(_es)) {
				UpdateState(_es, _stateMachine);
			}
			
			else if (StateIsParallel(_es)) {
				UpdateParallel(_es, _stateMachine);
			}
		}
		
		
		//Lastly, initialize the observableID's
		var _obsId = 1;
		_stateMachine.GetInitialTransition().SetObservableId(_obsId);
		InitializeObservables(_states, ++_obsId);
	}
	
	/** Initializes all State module classes that are implementing `ISortable` (`EnterableState` or `Transition`) by iterating them in document order and
	 * setting their document order values. Returns the next order value to be used.
	 * @arg {Array<Struct.EnterableState>} _states The list of child states of a parent `TransitionalState` or the machine itself.
	 * @arg {Real} _nextOrder The next order value to be used.
	 * @return {Real} */ 
	static InitializeDocumentOrder = function(_states, _nextOrder) {
		var _state, _transition;
		var _len = array_length(_states);
		for (var i = 0; i < _len; i++) {
			//Set the document order for the state
			_state = _states[i];
			_state.SetElementOrder(_nextOrder++);
			
			//We also need to set the document order for the States transitions if any.
			if (StateIsTransitional(_state)) {
				var _transitions = _state.GetTransitions();
				var _count = array_length(_transitions);
				for (var j = 0; j < _count; j++) {
					_transitions[j].SetElementOrder(_nextOrder++);
				}
				_nextOrder = InitializeDocumentOrder(_state.GetChildren(), _nextOrder);
			}
		}
		return _nextOrder;
	}
	
	/** 
	 * Initializes all IObservables in the by iterating them in document order and seeding them with a unique observable ID. Returns the next 
	 * observable id that can be assigned. 
	 * @arg {Array<Struct.EnterableState>} _states The list of states (or the machine itself) 
	 * @arg {Real} _nextObservableId The next observable ID to assign.
	 * @return {Real} */
	static InitializeObservables = function(_states, _nextObservableId) {
		var _ts;
		var _len = array_length(_states);
		for (var i = 0; i < _len; i++) {
			_ts = _states[i];
			
			if (StateIsTransitional(_ts)) {
				var _state = _ts;
				
				if (StateIsState(_state)) {
					var _init = _state.GetInitial();
					if (!is_undefined(_init)) {
						var _initTrans = _init.GetTransition();
						_initTrans.SetObservableId(_nextObservableId++);
					}
				}
				
				var _transitions = _ts.GetTransitions();
				var _transitionCount = array_length(_transitions);
				for (var j = 0; j < _transitionCount; j++) {
					_transitions[j].SetObservableId(_nextObservableId++);
				}
				
				var _histories = _ts.GetHistory();
				var _historyCount = array_length(_histories);
				for (var k = 0; k < _historyCount; k++) {
					var _history = _histories[k];
					_history.SetObservableId(_nextObservableId++);
					
					var _hTransition = _history.GetTransition();
					if (!is_undefined(_hTransition)) {
						_hTransition.SetObservableId(_nextObservableId++);
					}
				}
				_nextObservableId = InitializeObservables(_ts.GetChildren(), _nextObservableId);
			}
		}
		return _nextObservableId;
	}
	
	/** Maps the target ID's for all transitions related to this `State` to their corresponding `TransitionTarget` instances.
	 * @arg {Struct.State} _state The state to update
	 * @arg {Struct.StateChart} _machine The machine that the state belongs to
	 * @return {Undefined} */
	static UpdateState = function(_state, _machine) {
		//Setting the transition targets for the transitions of this State
		
		var _children = _state.GetChildren();
		if (_state.IsCompoundState()) {
			//Initialize the next/initial 
			var _initial = _state.GetInitial();
			if (is_undefined(_initial)) {
				_state.SetFirst(_children[0].GetId());
				_initial = _state.GetInitial();
			}
			
			//Set the transition targets for the InitialState
			var _initialTransition = _initial.GetTransition();
			UpdateTransition(_initialTransition, _machine);
			
			//Error if somting wong
			var _initialStates = _initialTransition.GetTargets();
			if (ArrayIsEmpty(_initialStates)) {
				StateError("UpdateState", $"Initial transition for state id {_state.GetId()} does not specify a target");
			}
			
			//The initial state of a compound `State` must be a descendant of it.
			else {
				var _len = array_length(_initialStates);
				for (var i = 0; i < _len; i++) {
					var tt = _state;
					if (!_initialStates[i].IsDescendantOf(tt)) {
						StateError("UpdateState", $"State {_initialStates[i].GetId()} should be a descendant of State {_state.GetId()}");
					}
				}
			}
		}
		
		//If the state isn't compound then it's considered atomic and it's `InitialState` should be undefined. If its not, then the state wasn't setup properly.
		else if (!is_undefined(_state.GetInitial())) {
			StateError("UpdateState", $"Unsupported initial state for state with ID {_state.GetId()}");
		}
		
		
		//Update the transitions for all the HistoryStates assigned to this State
		var _histories = _state.GetHistory();
		if (!ArrayIsEmpty(_histories) && _state.IsAtomicState()) {
			//A state cannot be atomic if it has any type of substate
			StateError("UpdateState", $"History substates detected for atomic state id {_state.GetId()}");
		} 
		//Actually update now that error checking is done
		var _len = array_length(_histories);
		for (var i = 0; i < _len; i++) {
			UpdateHistory(_histories[i], _machine, _state);
		}
		
		//Update all transitions that are assigned to this State
		var _transitions = _state.GetTransitions();
		_len = array_length(_transitions);
		for (var i = 0; i < _len; i++) {
			UpdateTransition(_transitions[i], _machine);
		}
		
		//Finally, update all the substates assigned to this state
		_len = array_length(_children);
		var _child = undefined;
		for (var i = 0; i < _len; i++) {
			_child = _children[i];
			
			//Update the state child
			if (StateIsState(_child)) {
				UpdateState(_child, _machine);
			}
			//Update the parallel child
			else if (StateIsParallel(_child)) {
				UpdateParallel(_child, _machine);
			}
		}
	}
	
	/** Maps the target ID's for all transitions related to this `ParallelState` to their corresponding `TransitionTarget` instances.
	 * @arg {Struct.ParallelState} _parallel The parallel to update
	 * @arg {Struct.StateChart} _machine The global map of transition targets keyed by their ID's
	 * @return {Undefined} */
	static UpdateParallel = function(_parallel, _machine) {
		
		//Setting the transition targets that correspond to the transitions of this parallel
		var _children = _parallel.GetChildren();
		var _len = array_length(_children);
		var _es, _s, _ps;
		for (var i = 0; i < _len; i++) {
			_es = _children[i];
			
			_s = _es;
			_ps = _es;
			
			//Update substates of type `State`
			if (StateIsState(_s)) {
				UpdateState(_s, _machine);
			}
			
			//Update substates of type `ParallelState`
			else if (StateIsParallel(_ps)) {
				UpdateParallel(_ps, _machine);
			}
		}
		
		//Update all the transitions of this ParallelState
		var _transitions = _parallel.GetTransitions();
		var _tLen = array_length(_transitions);
		for (var j = 0; j < _tLen; j++) {
			UpdateTransition(_transitions[j], _machine);
		}
		
		//Update all the histories for this state
		var _histories = _parallel.GetHistory();
		var _hLen = array_length(_histories);
		for (var k = 0; k < _hLen; k++) {
			UpdateHistory(_histories[k], _machine);
		}
		
	}
	
	/** Maps the target ID's for all transitions related to this `HistoryState` to their corresponding `TransitionTarget` instances.
	 * @arg {Struct.HistoryState} _hisotyr The history state to update
	 * @arg {Struct.StateChart} _machine The global map of transition targets keyed by their ID's
	 * @arg {Struct.TransitionalState} _parent The parent for the history
	 * @return {Undefined} */
	static UpdateHistory = function(_history, _machine, _parent) {
		var _transition = _history.GetTransition();
		
		if (is_undefined(_transition) || is_undefined(_transition.GetNext())) {
			StateError("UpdateHistory", $"HistoryState {_history.GetId()} has no default transition!");
		}
		
		else {
			UpdateTransition(_transition, _machine);
			
			var _historyStates = _transition.GetTargets();
			var _len = array_length(_historyStates);
			if (_len == 0) {
				StateError("UpdateHistory", $"HistoryState {_history.GetId()} for parent state {_parent.GetId()} does not exist"); 
			}
			
			var _historyState = undefined;
			for (var i = 0; i < _len; i++) {
				_historyState = _historyStates[i];
				
				//Is shallow history
				if (!_history.IsDeep()) {
					if (!array_contains(_parent.GetChildren(), _historyState)) {
						StateError("UpdateHistory", $"Shallow HistoryState {_history.GetId()} for state {_parent.GetId()} is invalid.");
					}
				}
				
				//Is Deep history
				else {
					if (!_historyState.IsDescendantOf(_parent)) {
						StateError("UpdateHistory", $"Deep HistoryState {_history.GetId()} for state {_parent.GetId()} is invalid.");
					}
				}
			}
		}
	}
	
	/** Sets the target ID(s) of the specified `SimpleTransition` to the correct `TransitionTarget` instances.
	 * @arg {Struct.SimpleTransition} _transition The transition to update
	 * @arg {Struct.StateChart} _machine The machine of with the available transition targets
	 * @return {Undefined} */
	static UpdateTransition = function(_transition, _machine) {
		
		var _next = _transition.GetNext();
		
		//Self transition
		if (is_undefined(_next)) {
			return;
		}
		
		
		var _targets = _transition.GetTargets();
		if (ArrayIsEmpty(_targets)) {
			
			var _ids = string_split(_next, ".", true);
			var _len = array_length(_ids);
			for (var i = 0; i < _len; i++) {
				var _target = _machine.GetTarget(_ids[i]);
				
				if (is_undefined(_target)) {
					StateError("UpdateTransition", $"State {_ids[i]} is not found!");
				}
				
				array_push(_targets, _target);
			}
			
			//The transition has more than one target, so verify the root is parallel and that there's no conflicting targets
			if (array_length(_targets) > 1) {
				var _isLegal = VerifyTransitionTargets(_targets);
				if (!_isLegal) {
					StateError("UpdateTransition", $"Illegal target configuration for a transition targeting state {_next}");
				}
			}
		}
	}
	
	/** Returns `true` if all targets of a transition meet the required criteria (for the case where a transition has to target multiple states at once due to 
	 * the way `ParallelState` objects work).
	 * * No target is an ancestor of any other target on the list
	 * * A full legal state configuration results when all ancestors and default initial descendants have been added
	 * * They all must share the same least common parallel ancestor
	 * @arg {Array<Struct.TransitionTarget>} _transitionTargets The targets to verify
	 * @return {Bool} */
	static VerifyTransitionTargets = function(_transitionTargets) {
		var _len = array_length(_transitionTargets);
		
		//Guaranteed no conflicts
		if (_len < 2) {
			return true;
		}
		
		var _tt, _count, _ancestorCount;
		var _first = undefined;
		for (var i = 0; i < _len; i++) {
			_tt = _transitionTargets[i];
			
			if (is_undefined(_first)) {
				_first = _tt;
				_count = _tt.GetNumberOfAncestors();
				continue;
			}
			
			//Find least common ancestor
			for (var k = min(_count, _tt.GetNumberOfAncestors()); (k > 0) && (_first.GetAncestor(_count - 1) != _tt.GetAncestor(_count - 1)); i--) {
				
				//No common ancestor
				if (k == 0) {
					return false;
				}
			}
			
			//Ensure no target is an ancestor of any other target in the list
			var _target = undefined;
			for (var j = 0; j < _len; j++) {
				_target = _transitionTargets[j];
				
				if ((_target != _tt) && _target.IsDescendantOf(_tt) || _tt.IsDescendantOf(_target)) {
					return false;
				}
			}
		}
		
		//If a transition is targeting multiple states then the least common ancestor must be a parallel
		return (!is_undefined(_first) && (_count > 0) && StateIsParallel(_first.GetAncestor(_count - 1)));
	}
}
