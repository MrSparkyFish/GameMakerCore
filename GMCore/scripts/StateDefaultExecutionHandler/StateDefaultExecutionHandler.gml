//feather ignore all


/** StateDefaultExecutionHandler: Concrete implementation of `IStateEventHandler` that provides the default logic for executing events and 
 * transitions for a `StateMachine`
 * ***
 * Implements: `IStateEventHandler``
 * @return {Struct.StateDefaultExecutionHandler} */
function StateDefaultExecutionHandler() constructor {
	Implement(IStateEventHandler);
	
	/** Adds to the execution data all the ancestor states that must be entered during the specified execution.
	 * @arg {Struct.CapturedHistoryContainer} _oldHistories The container of previously recorded histories. We may be entering them as a result of entering certain states.
	 * @arg {Struct.StateEventExecutionData} _executionData The data we populate
	 * @arg {Struct.TransitionTarget} _tTarget The target to get ancestors for
	 * @arg {Struct.TransitionTarget} [_ancestor] Optional ancestor to stop at (non-inclusive).
	 * @return {Undefined} */
	static AddAncestorStatesToEnter = function(_oldHistories, _executionData, _tTarget, _ancestor = undefined) {
		var _enterSet = _executionData.GetEnterSet();
		
		//Loop through the ancestors of the target. Ancestors are ordered backwards
		var _anc;
		for (var i = _tTarget.GetNumberOfAncestors() - 1; i > -1; i--) {
			_anc = _tTarget.GetAncestor(i);
			
			//Stop if this ancestor is the indicated ancestor and don't include it (it will be undefined if we're at the root which would mess up the entering states)
			if (_anc == _ancestor) {
				break;
			}
			
			//Add the ancestor as a state that we should be entering during the execution.
			_executionData.AddStateToEnter(_anc);
			
			//If the ancestor is parallel, we need to add all its regions as well
			if (StateIsParallel(_anc)) {
				var _children = _anc.GetChildren();
				var _child;
				for (var j = 0; j < array_length(_children); j++) {
					_child = _children[j];
					
					//Only bother adding the parallel child if its not already being included.
					if (!StateContainsDescendant(_enterSet, _child)) {
						AddDescendantStatesToEnter(_oldHistories, _executionData, _child);
					}
				}
			}
		}
	}
	
	/** Adds all the descendants then all the ancestors of each of the specified transition targets to the entry set of the specified execution data. 
	 * @ignore
	 * @arg {Array<Struct.TransitionTarget>} _targets The array of targets to get ancestors and descendants from
	 * @arg {Struct.CapturedHistoryContainer} _oldHistories The container of previously recorded histories. We may be entering them as a result of entering certain states.
	 * @arg {Struct.StateEventExecutionData} _executionData The data we populate
	 * @arg {Struct.TransitionTarget} [_ancestor] The optional ancestor to stop at (non-inclusive).
	 * @return {Undefined} */
	static AddDescendantAndAncestorStatesToEnter = function(_targets, _oldHistories, _executionData, _ancestor) {
		var _target;
		for (var i = 0; i < array_length(_targets); i++) {
			_target = _targets[i];
			AddDescendantStatesToEnter(_oldHistories, _executionData, _target);
			AddAncestorStatesToEnter(_oldHistories, _executionData, _target, _ancestor);
		}
	}	
	
	/** Populates the execution data with all the descendant states that must also be entered when entering the specified target.
	 * @arg {Struct.CapturedHistoryContainer} _oldHistories The container of previously recorded histories. We may be entering them as a result of entering certain states.
	 * @arg {Struct.StateEventExecutionData} _executionData The data we populate
	 * @arg {Struct.TransitionTarget} _tTarget The target to get descendants from
	 * @return {Undefined} */
	static AddDescendantStatesToEnter = function(_oldHistories, _executionData, _tTarget) {
		
		//If tTarget is a history state then we're actually entering its last recorded set of active states
		var _history = _tTarget; //Setting a new var for type casting
		if (StateIsHistory(_history)) {
			var _lastConfig = _executionData.GetHistoryCaptures().GetHistory(_history);
			
			//If it hasn't been able to record anything, then just use the systems last recorded config for that state (which may be nothing)
			if (is_undefined(_lastConfig)) {
				_lastConfig = _oldHistories.GetHistory(_history);
				
				if (is_undefined(_lastConfig)) {
					_lastConfig = [];
					_oldHistories.SetHistory(_history, _lastConfig);
				}
			}
			
			//If there isn't a recorded config for the history then we need to take its default transition. Mark it for later
			if (ArrayIsEmpty(_lastConfig)) {
				_executionData.AddDefaultHistoryTransition(_history);
				
				//Since it's default transition is being taken the targets of the transition must also be included in this execution.
				var _hTargets = _history.GetTransition().GetTargets();
				AddDescendantAndAncestorStatesToEnter(_hTargets, _oldHistories, _executionData, _tTarget.GetParent());
			}
			
			//If there is a recorded history, then we treat the recorded states must be included in this execution.
			else {
				AddDescendantAndAncestorStatesToEnter(_lastConfig, _oldHistories, _executionData, _tTarget.GetParent());
			}
		}
		
		//If the tTarget isn't a history state then we have to determine which substates, if any, are also being entered so we can include those in the execution as well.
		else {
			
			//Make sure the target of the transition is being included in this execution.
			var _enterableState = _tTarget;
			_executionData.AddStateToEnter(_enterableState);		
			
			//Helper vars for type-casting.
			var _state = _enterableState;
			var _parallelState = _enterableState;			
			
			
			//All substates of a parallel state must be included in the execution
			if (StateIsParallel(_parallelState)) {
				var _child;
				var _children = _parallelState.GetChildren();
				for (var i = 0; i < array_length(_children); i++) {
					_child = _children[i];
					AddDescendantStatesToEnter(_oldHistories, _executionData, _child);
				}
			}
			
			//Only the initial substate of a compound state needs to be included
			else if (StateIsState(_state) && _state.IsCompoundState()) {
				//Since the target isn't atomic then it will for sure have a descendant that needs to be included in this execution
				//meaning we must guarentee the target is entered which we can do by also adding it to the default entry list.
				 _executionData.AddDefaultStateToEnter(_enterableState);
				
				//Now we can start including the descendants and ancestors of it's initial transition's targets.
				var _targets = _state.GetInitial().GetTransition().GetTargets();
				AddDescendantAndAncestorStatesToEnter(_targets, _oldHistories, _executionData, _tTarget);
			}
		}
	}	
	
	/** Populates the specified execution data with the information necessary for executing a transition event.
	 * @arg {Struct.StateExecutionContext} _executionContext The component leading the execution
	 * @arg {Struct.StateEventExecutionData} _executionData The data that should be populated for the execution
	 * @return {Undefined} */
	static BuildExecution = function(_executionContext, _executionData) {
		//Populating our execution data with the states we need to exit/enter
		var _machineContext = _executionContext.GetStateMachineContext();
		var _activeStates = _machineContext.GetActiveStates();
		var _atomicStates = _machineContext.GetAtomicStates();
		var _oldHistories = _machineContext.GetHistoryCaptures();
		var _exitSet = _executionData.GetExitSet();
		var _enterSet = _executionData.GetEnterSet();
		var _transitionList = _executionData.GetTransitionList();
		var _newHistories = _executionData.GetHistoryCaptures();
		
		//Figuring out what states from the active configuration need to be exited.
		if (!ArrayIsEmpty(_activeStates)) {
			
			//Populate the exit set with the states that need to be exited.
			FindExitSet(_transitionList, _activeStates, _exitSet);
			
			//Now that we know which states are for sure being exited we can record their histories if any.
			RecordHistory(_exitSet, _newHistories, _atomicStates, _activeStates);
		}
		
		
		//Figure out what states need to be entered.
		FindEnterSet(_oldHistories, _executionData, _transitionList);
		
		
		
		//If we have states that we need to exit then we need to calculate atomicStates - exitSet + enterSet
		//This ensures that targets of external vs internal transition types are entered/exited correctly
		var _states = _enterSet;//Create another var to account for GM's automatic type casting.
		if (!ArrayIsEmpty(_exitSet)) {
			//Start with atomic states
			_states = variable_clone(_atomicStates, 0);	
			
			//Remove any exiting states from the atomic states (so we don't exit a state just so we can enter it which can occur with internal transitions)
			ArrayFilterValues(_states, _exitSet);
			
			//Then include our enter set
			ArrayAddAll(_states, _enterSet);			
		}
		
		//Validate that the final set of states is a legal active state configuration
		if (_machineContext.ShouldVerifyLegalStateConfiguration() && (!IsLegalStateConfiguration(_states))) {
			StateError("BuildExecution", $"Illegal state machine configuration detected!", self);
		}
	}
	
	/** Enter all required states specified by the event execution data
	 * @arg {Struct.StateExecutionContext} _executionContext The execution context for all events.
	 * @arg {Struct.StateEventExecutionData} _data The execution data specific to this execution
	 * @arg {Array<Struct.TransitionalState>} _statesToInvoke List of states with active task runners.
	 * @return {Undefined} */	
	static EnterStates = function(_executionContext, _data, _statesToInvoke) {
		var _enterSet = _data.GetEnterSet();
		var _machineContext = _executionContext.GetStateMachineContext();
		
		//Early return if there's no states to enter
		if (ArrayIsEmpty(_enterSet)) {
			return;
		}
		
		//Make sure our states are in order. Need to enter parent states first.
		ArraySortAscendingOrder(_enterSet);
		
		//Entering each state
		var _state, _compound, _final, _transitional;
		for (var i = 0; i < array_length(_enterSet); i++) {
			_state = _enterSet[i];
			_transitional = _state;
			
			//Add the state to the active configuration
			_machineContext.GetStateConfiguration().AddState(_state);
			
			//Check if it has active TaskRunners
			if (StateIsTransitional(_transitional) && !(_transitional.GetTasks().IsEmpty())) {
				ArrayPushUnique(_statesToInvoke, _transitional);
			}
			
			//Execute the states enter delegate
			ExecuteCallback(_state.GetOnEnter(), _executionContext);
			if (_state.GetRaiseOnEnter()) {
				var event = new Event();
				event.SetEventTag(Tag_RequestTag($"{EVENT_ENTER_STATE}.{_state.GetId()}"));
				event.SetEventType(EventType.change);
				_executionContext.AddEvent(new Event(event));
			}
			
			//Notify observers of the SSC events
			var _onStateEntered = _executionContext.GetOnStateEntered();
			_onStateEntered.Broadcast(_state);
			
			//If this state was entered by default, then we might have an "initial" transition that needs to be triggered next.
			_compound = _state;
			if (StateIsState(_compound) && array_contains(_data.GetDefaultEnterSet(), _state) && (!is_undefined(_compound.GetInitial().GetTransition()))) {
				ExecuteCallback(_compound.GetInitial().GetTransition().GetOnTransition());
			}
			
			//If entering a transitional state, check if it has a marked history transition that needs to be executed.
			if (StateIsTransitional(_transitional)) {
				//Execute the transition if one is found.
				var _historyTransition = _data.GetDefaultHistoryTransitions(_transitional);
				if (!is_undefined(_historyTransition)) {
					_historyTransition.GetOnTransition().Execute();
				}
				
			}
			
			//If entering a final state, stop the machine and trigger the done event to indicate the task is complete
			_final = _state;
			if (StateIsFinal(_final)) {
				
				//At the root level of the machine so have it stop running.
				if (is_undefined(_final.GetParent())) {
					_executionContext.StopRunning();
				}
				
				//Trigger the event "Event.Done.[ParentId]" 
				else {
					var _parent = _final.GetParent();
					
					//Trigger the done event for the parent of the final state
					var event = new Event();
					event.SetEventTag(Tag_RequestTag($"{EVENT_DONE_STATE}.{_parent.GetId()}"));
					event.SetEventType(EventType.change);
					_executionContext.AddEvent(event);
					
					//If the parent is a substate of a parallel
					if (_parent.IsRegion()) {
						var _pParallel = _parent.GetParent();
						//Then we have to check if the parent was the last substate that the parallel was waiting for.
						if (IsInFinalState(_pParallel, _machineContext.GetActiveStates())) {
							//If the parallel is also final, trigger a final event for it as well
							var event = new Event();
							event.SetEventTag(Tag_RequestTag($"{EVENT_DONE_STATE}.{_pParallel.GetId()}"));
							event.SetEventType(EventType.change);
							_executionContext.AddEvent(event);
						}
					}
				}
			}
		}
	}
	
	/** Executes all transitions specified by the event execution data
	 * @arg {Struct.StateExecutionContext} _executionContext
	 * @arg {Struct.StateEventExecutionData} _data
	 * @return {Undefined} */
	static ExecuteTransitions = function(_executionContext, _data) {
		var _transition, _targets, _source;
		var _transitions = _data.GetTransitionList();
		var _event = _data.GetEvent();
		
		//Loop though each transition that needs to be taken during this execution.
		for (var i = 0; i < array_length(_transitions); i++) {
			_transition = _transitions[i];
			_source = _transition.GetParent();
			_targets = _transition.GetTargets();
			
			//Fire the transition's Action
			ExecuteCallback(_transition.GetOnTransition(), _executionContext);
			
			//Transition notification procedure for targetless transitions
			if (ArrayIsEmpty(_targets)) {
				//Notify all subscribers
				var _onTransitionTaken = _executionContext.GetOnTransitionTaken();
				_onTransitionTaken.Broadcast(_source, _source, _transition, _event);
			}
			
			//Transition notification procedure for external transition
			else {
				//Need to run the procedure once for each posible target.
				for (var j = 0; j < array_length(_targets); j++) {
					var _onTransitionTaken = _executionContext.GetOnTransitionTaken();
					_onTransitionTaken.Broadcast(_source, _targets[j], _transition, _event);					
				}
			}
		}
	}
	
	/** Execute the specified action using the provided contextual data
	 * 
	 * @arg {Struct.Callback} _callback The `Callback` to execute
	 * @arg {Struct.StateExecutionContext} _executionContext The execution context to pass to the action as a function parameter.
	 * @return {Undefined} */
	static ExecuteCallback = function(_callback, _executionContext) {
		_callback.Execute([_executionContext]);
	}
	
	/** Exit all states defined by the event execution data.
	 * @arg {Struct.StateExecutionContext} _executionContext Data relevant to the executing machine
	 * @arg {Struct.StateEventExecutionData} _executionData Data relevant to this specific execution
	 * @arg {Array<Struct.TransitionalState>} _statesToInvoke The list of states with invocable `Task` objects
	 * @return {Undefined} */
	static ExitStates = function(_executionContext, _executionData, _statesToInvoke) {
		var _exitSet = _executionData.GetExitSet();								//Set of states to exit
		var _machineContext = _executionContext.GetStateMachineContext();		//The context representing our state machine
		
		//Early return if there's no states to exit
		if (ArrayIsEmpty(_exitSet)) {
			return;
		}
		
		//Child states are exited before their parent state
		var _statesToExit = _exitSet;
		ArraySortDescendingOrder(_statesToExit);
		
		//Preserve the history recordings we took by moving them from the execution data to the SSC
		//This is done here rather than when they're recorded because history should only be set when the state is actually exited.
		//Also execute each state's on exit delegate then remove the state from the configuration
		var _transitional, _history, _histories, _state;
		var _len = array_length(_exitSet);
		for (var i = 0; i < _len; i++) {
			_state = _exitSet[i];
			_transitional = _state;
			
			//Grabbing the histories for each state in the exit set and moving their recordings to the SSC 
			if (StateIsTransitional(_transitional) && _transitional.HasHistory()) {
				_histories = _transitional.GetHistory();
				for (var j = 0; j < array_length(_histories); j++) {
					_history = _histories[j];
					_machineContext.SetRecordedHistory(_history, _executionData.GetHistoryCaptures().GetHistory(_history));
				}
			}
			
			//Execute the states onExit action
			ExecuteCallback(_state.GetOnExit(), _executionContext);
			if (_state.GetRaiseOnExit()) {
				var event = new Event();
				event.SetEventTag(Tag_RequestTag($"{EVENT_EXIT_STATE}.{_state.GetId()}"));
				event.SetEventType(EventType.change);
				_executionContext.AddEvent(event);
			}
			
			//Publish a notification to subscribers on exit delegate
			var _onExited = _executionContext.GetOnStateExited();
			_onExited.Broadcast(_state);
			
			//Remove the state from the update loop
			if(StateIsTransitional(_transitional) && !ArrayRemove(_statesToInvoke, _transitional)) {
				//Check if tasks are active in this state
				var _tasks = _transitional.GetTasks().ToArray();
				for (var k = 0; k < array_length(_tasks); k++) {
					_executionContext.CancelTaskRunner(_tasks[k]);
				}
			}			
			
			//Remove the now exited state from the configuration
			_machineContext.GetStateConfiguration().RemoveState(_state);
		}
	}
	
	/** The final step in event execution used to clean up any data. If the machine is still running, this method should do 
	 * nothing. Otherwise, this step should first exit all remaining active states and cancel any activities before handling 
	 * any `donedata` for the last final state.
	 * @arg {Struct.StateExecutionContext} _executionContext The context we need to exit states and cancel activities for
	 * @return {Undefined} */
	static FinalStep = function(_executionContext) {
		//Final step can only be executed if we the machine is no longer in a running state
		if (_executionContext.IsRunning()) {
			return;
		}
		
		var _machineContext = _executionContext.GetStateMachineContext();
		var _activeStates = _machineContext.GetActiveStates();
		ArraySortDescendingOrder(_activeStates);
		
		var _es, _final, _payload;
		var _len = array_length(_activeStates);
		for (var i = 0; i < _len; i++) {
			//Publish the state's exit actions
			_es = _activeStates[i];
			
			//Execute the state's exit action
			ExecuteCallback(_es.GetOnExit());
			
			//Have publishers notify their subscribers of the state being exited.
			var _onExited = _machineContext.GetOnStateExited();
			_onExited.Broadcast(_es);
			
			//Actually exit the state (final states can stay)
			_final = _es;
			if (!(StateIsFinal(_final) && is_undefined(_es.GetParent()))) {
				_machineContext.GetStateConfiguration().RemoveState(_es);
			}
			
			else {
				//TODO: Handle doneData
				// ReturnDoneEvent(doneData) ?
			}
		}
	}		
	
	/** Finds and stores the set of all states that need to be entered during this execution. The set is stored with the rest of the provided execution data.
	 * @arg {Struct.CapturedHistoryContainer} _oldHistories The container of previously recorded histories. We may be entering them as a result of entering certain states.
	 * @arg {Struct.StateEventExecutionData} _executionData The data used for the current execution.
	 * @arg {Array<Struct.SimpleTransition>} _transitionList The transitions that will be used to enter states
	 * @return {Undefined} */
	static FindEnterSet = function(_oldHistories, _executionData, _transitionList) {
		var _historyTargets = [];
		var _entrySet = [];
		
		//Grabbing all enterable states for each transition target
		var _simpleTransition, _targetList, _tTarget;
		for (var i = 0; i < array_length(_transitionList); i++) {
			_simpleTransition = _transitionList[i];
			_targetList = _simpleTransition.GetTargets();
			
			//Figuring out which array each target should be added to
			//At this point, each target must either be history or enterable (state/parallel/final).
			var j = 0; repeat(array_length(_targetList)) {
				_tTarget = _targetList[j++];
				
				//Adding the target to its proper array. This tells us how it needs to be entered later.
				if (is_instanceof(_tTarget, EnterableState)) {
					array_push(_entrySet, _tTarget);
				}
				else {
					array_push(_historyTargets, _tTarget);
				}
			}
		}
		
		//Note: For the below for loops, we get the array length each check because the array sizes are changing as the loops execute.
		var _ancestor, _transition, _targets;
		
		//The order in which states are entered matters.
		//Add all the descendants of the states in our enter set
		for (var i = 0; i < array_length(_entrySet); i++) {
			AddDescendantStatesToEnter(_oldHistories, _executionData, _entrySet[i]);
		}
		//Then we want all the descendants of the history states next
		for (var i = 0; i < array_length(_historyTargets); i++) {
			AddDescendantStatesToEnter(_oldHistories, _executionData, _historyTargets[i]);
		}
		//Then we want all the ancestors of the targets of the transition.
		for (var i = 0; i < array_length(_transitionList); i++) {
			_transition = _transitionList[i];
			_ancestor = _transition.GetTransitionDomain();
			_targets = _transition.GetTargets();
			for (var j = 0; j < array_length(_targets); j++) {
				AddAncestorStatesToEnter(_oldHistories, _executionData, _targets[j], _ancestor);
			}
		}
		
	}
	
	/** Returns an array, or populates an existing array, with all the states that will be exited when the specified transition is taken.
	 * @arg {Array<Struct.SimpleTransition>} _transitionList The list of transitions being taken. Used to determine which states need to be exited.
	 * @arg {Array<Struct.EnterableState>} _activeStates The list of all currently active states. Exiting states are grabbed from here.
	 * @arg {Array<Struct.EnterableState>} [_exitSet] The array to add the exiting states to. One is created if not provided.
	 * @return {Array<Struct.EnterableState>} */	
	static FindExitSet = function(_transitionList, _activeStates, _exitSet = []) {
		//Loop through each transition in the list to figure out what state owns them and if that state needs to be exited.
		var _transition;
		for (var i = 0; i < array_length(_transitionList); i++) {
			_transition = _transitionList[i];
			
			//Get the states being targeted by the transition
			var _targets = _transition.GetTargets();
			
			//Only do work if the transition actually has a target (no targets = self transition, so no states are exited).
			if (!ArrayIsEmpty(_targets)) {
				//The states we need to exit are all the state in-between the transition's domain and the transition's source.
				var _domain = _transition.GetTransitionDomain();
				
				//If we have no domain, it means that we're at the machine level (since we already know we have at least 1 target) 
				//so we have to exit ALL active states in order to get to the domain level.
				if (is_undefined(_domain)) {
					ArrayAddAll(_exitSet, _activeStates);
				}
				
				//Otherwise the states we need to exit are all the descendant states that are between the domain and the transitions source
				else {
					var _state;
					for (var i = 0; i < array_length(_activeStates); i++) {
						_state = _activeStates[i];
						if (_state.IsDescendantOf(_domain)) {
							array_push(_exitSet, _state);
						}
					}
				}
			}
		}
		
		return _exitSet;
	}
	
	/** If the `StateMachine` isn't running, then this method should do nothing. If the specified event is a cancel event, the machine should stop 
	 * running. Otherwise, the event must be set in the `StateSystemContext` and processing the event begins. This method is the primary event 
	 * execution method that is used to handle incoming (external) events.
	 * ***
	 * If the event leads to any transitions, a `TransitionStep` is performed to process them, followed by a `MacroStep` to stabilize the machine. 
	 * If the machine is no longer running after the event is handled, then `FinalStep()` should be called for cleanup before returning.
	 * @arg {Struct.Event} _event The event that we need to handle.
	 * @arg {Struct.StateExecutionContext} _executionContext Data that we can use to handle the event.
	 * @return {Undefined} */
	static HandleEvent = function(_event, _executionContext) {
		//Stop running and early exit if we're told to cancel all event handling.
		if (_event.GetEventType() == EventType.cancel) {
			_executionContext.StopRunning();
			return;
		}
		
		//Otherwise try to process the event
		else if (_executionContext.IsRunning()) {
			SetCurrentEventExecution(_executionContext, _event, false);
			var _data = new StateEventExecutionData(_event);
			var _transitions = _data.GetTransitionList();
			
			//Populate the data with all the transitions that the machine needs to take in response to the event
			SelectTransitions(_executionContext, _data);
			
			//Handling each transition
			if (!ArrayIsEmpty(_transitions)) {
				
				//Processes each transition stored in the execution data one-by-one and collect any states that raise internal events
				var _statesToInvoke = [];//Holds any collected states that need resolving via MacroStep()
				TransitionStep(_executionContext, _data, _statesToInvoke);
				
				//Running status may have changed after TransitionStep. 
				if (_executionContext.IsRunning()) {
					//Process collected states
					MacroStep(_executionContext, _statesToInvoke); 
				}
			}			
		}
		
		
		//Perform cleanup. Does nothing if no cleanup is necessary
		FinalStep(_executionContext);
	}
	
	/** (Re)Initializes the `StateMachine` and destroys any existing states. This step completes the transition of a `StateMachine` into its
	 * initial state as described by its `StateChart`. A `MacroStep` should be called to stabilize the machine before returning. If the machine
	 * is no longer running after transitioning to its initial state, then `FinalStep()` should be called for cleanup before returning.
	 * @arg {Struct.StateExecutionContext} _executionContext Data that we can use to handle the event.	 
	 * @return {Undefined} */
	static InitStep = function(_executionContext) {
		//re(initialize) execution context so we have a fresh start to the execution cycle
		_executionContext.Initialize();
		
		//Execute the machine's "initialize" action
		_executionContext.GetStateChart().GetOnInitialized().Execute();
		
		//The context must enter its initial active state(s)
		var _statesToInvoke = [];//holds internal events we need to resolve via macrostep
		var _data = new StateEventExecutionData(undefined);
		_data.AddTransition(_executionContext.GetStateChart().GetInitialTransition());
		TransitionStep(_executionContext, _data, _statesToInvoke);
		
		//Resolve any internal conflicts
		if (_executionContext.IsRunning()) {
			MacroStep(_executionContext, _statesToInvoke);
		}
		
		//Run cleanup. Does nothing if no cleanup is required.
		FinalStep(_executionContext);
	}
	
	/** Returns `true` if the specified active state configuration is in a final state.
	 * @arg {Struct.EnterableState} _es The state to check
	 * @arg {Array<Struct.EnterableState} _activeStates The current active state configuration of the machine
	 * @return {Bool} */
	static IsInFinalState = function(_es, _activeStates) {
		var _state = _es;
		var _parallel = _es;
		if (StateIsState(_state)) {
			var _child;
			var _children = _parallel.GetChildren();
			var _len = array_length(_children);
			for (var i = 0; i < _len; i++) {
				_child = _children[i]; 
				if (StateIsFinal(_child) && array_contains(_activeStates, _child)) {
					return true;
				}
			}
		}
		
		else if (StateIsParallel(_parallel)) {
			var _children = _parallel.GetChildren();
			var _len = array_length(_children);
			for (var i = 0; i < _len; i++) {
				if (!IsInFinalState(_children[i], _activeStates)) {
					return false;
				}
			}
			return true;
		}
		return false;
	}
	
	/** Tell task runners of the specified list of states to begin their tasks
	 * @arg {Struct.StateExecutionContext} _executionContext
	 * @arg {Array<Struct.TransitionalState>} _statesToInvoke
	 * @return {Undefined} */
	static InvokeTasks = function(_executionContext, _statesToInvoke) {
		for (var i = 0, _state, _tasks; i < array_length(_statesToInvoke); i++) {
			_state = _statesToInvoke[i];
			_tasks = _state.GetTasks().ToArray();
			
			for (var j = 0, _task; j < array_length(_tasks); j++) {
				_task = _tasks[j];
				_task.Execute(_executionContext);
			}
		}
	}
	
	/** Returns `true` if the specified set of states is one that can be assigned to the state machine
	 * @arg {Array<Struct.EnterableState>} _states The states to check
	 * @return {Bool} */
	static IsLegalStateConfiguration = function(_states) {
		/* For Every active state, we add 1. Each parallel state should reach a count
		 * equal to the number of children it has and contribute 1 to its parent. Each 
		 * state in the array should reach a cound of exactly 1. We essentailly sum up 
		 * the tree starting with a given set of states (active configuration)
		 */
		
		var _legal = true;					//Assuming true
		var _counts = ds_map_create();		//Holds the counts of all states
		var _machineCount = [];				//Holds the current number of state machines detected. Should only ever have 1 entry
		
		
		//Evaluating the counts for each state
		var _enterable, _parent, _pId, _cCount;
		for (var i = 0; i < array_length(_states); i++) {
			_enterable = _states[i];
			_parent = _enterable.GetParent();
			
			//Finding the count for the state. 
			//The count will skip the root state and terminate on other states when we reach the root
			while(!is_undefined(_parent)) {
				_counts[? _parent] ??= [];
				
				ArrayPushUnique(_counts[? _parent], _enterable);
				
				//Set enterable to the parent. It must eventually reach the machine level (=undefined) before the loop ends.
				_enterable = _parent;
				_parent = _enterable.GetParent();
			}
			
			//Top level contribution
			ArrayPushUnique(_machineCount, _enterable);			
		}
		
		//Validate number of root states. Should only be 1
		if (array_length(_machineCount) > 1) {
			var _message = ExceptionMessage("IsLegalStateConfiguration", "Detected multiple root states!");
			LogError(_message);
			_legal = false;
		}
		
		//Validate the child counts for each state 
		else {
			var _names = ds_map_keys_to_array(_counts);
			for (var i = 0; i < array_length(_names); i++) {
				//Getting the count for the current state
				_enterable = _names[i];
				_cCount = array_length(_counts[? _enterable]);
				
				//If the current state is parallel, then the count is invalid if its less than the number of child states
				var _parallel = _enterable;
				if (StateIsParallel(_parallel)) {
					if (_cCount < array_length(_parallel.GetChildren())) {
						_legal = false;
						var _message = ExceptionMessage("IsLegalStateConfiguration", $"Not all region states are active for parallel state {_parallel.GetId()}");
						LogError(_message);
					}
				}
				
				else {
					if (_cCount > 1) {
						_legal = false;
						var _message = ExceptionMessage("IsLegalStateConfiguration", $"Multiple substates are active for compound state {_enterable.GetId()}");
						LogError(_message);
					}
				}
			}
		}
		//free the map
		ds_map_destroy(_counts);
		return _legal;
	}
	
	/** Some states may require additional post-transition processing in order for the machine to continue receiving events. This method is called to 
	 * handle the post-processing for those states.
	 * @arg {Struct.StateExecutionContext} _executionContext Data that we can use to process internal events and return the machine to a neutral running state.
	 * @arg {Array<Struct.TransitionalState>} _statesToInvoke The list of states with active ITaskRunners
	 * @return {Undefined} */
	static MacroStep = function(_executionContext, _statesToInvoke) {
		do {
			//Tells us when we're done processing all internal events
			var _macroStepDone = false;
			
			do {
				//Attempt to execute all eventless transitions
				var _data = new StateEventExecutionData();
				SelectTransitions(_executionContext, _data);
				
				//If there were no eventless transitions to execute, then check if there are transitions for internal events
				if (ArrayIsEmpty(_data.GetTransitionList())) {
					var _event = _executionContext.NextInternalEvent();
					if (!is_undefined(_event)) {
						if (_event.GetEventType() == EventType.cancel) {
							_executionContext.StopRunning();
						}
						else {
							_data = new StateEventExecutionData(_event);
							SelectTransitions(_executionContext, _data);
						}
					}
				}
				
				//If we were unable to find any transitions at all, then we're done with macrostep
				if (ArrayIsEmpty(_data.GetTransitionList())) {
					_macroStepDone = true;
				}
				//Process any transitions we found
				else {
					TransitionStep(_executionContext, _data, _statesToInvoke);
				}
				
			} until (_macroStepDone || !_executionContext.IsRunning());	//Stop looping if the macro step is done or the machine can no longer run.
			
			//After processing transitions, we execute the tasks for the state (which eventually calls `ITaskRunner.Run()` to actually run the async task logic).
			if (_executionContext.IsRunning() && !ArrayIsEmpty(_statesToInvoke)) {
				InvokeTasks(_executionContext, _statesToInvoke);
				ArrayClear(_statesToInvoke);
			}
			
		} until (!_executionContext.IsRunning() || !_executionContext.HasPendingInternalEvent()); //Stop looping if the machine cannot run or we have no more internal events to run.
	}
	
	
	/** Capture state configurations for any history states in the exit set of our execution.
	 * @arg {Array<Struct.EnterableState>} _exitSet The list of states being exited. We check each on for history that needs to be recorded
	 * @arg {Struct.CapturedHistoryContainer} _newHistories The container where new history recordings are being kept.
	 * @arg {Array<Struct.EnterableState>} _atomicStates The list of all active atomic states. These are the states recorded for deep histories
	 * @arg {Array<Struct.ActiveState>} _activeStates The list of all the active states. These are used to help record shallow histories.
	 * @return {Undefined} */
	static RecordHistory = function(_exitSet, _newHistories, _atomicStates, _activeStates) {
		//History is recorded for all exiting states that have a history substate
		var _exitState, _transitState;
		
		//Loop through each transitional state so we can record history.
		for (var i = 0; i < array_length(_exitSet); i++) {
			_exitState = _exitSet[i];
			_transitState = _exitState;
			
			//Only do work if the current state has at least 1 history substate
			if (StateIsTransitional(_transitState) && _transitState.HasHistory()) {
				var _history;
				var _histories = _transitState.GetHistory();
				var _deep = undefined;
				var _shallow = undefined;
				
				//Record once for each history substate that the state has
				for (var j = 0; j < array_length(_histories); j++) {
					_history = _histories[j];
					
					//If the history is deep we record the deepest active atomic states.
					if (_history.IsDeep()) {
						
						//Make sure we're only recording for this state once.
						if (is_undefined(_deep)) {
							//We can only target the descendants of my parent
							for (var k = 0; k < array_length(_atomicStates); k++) {
								var _atomic = _atomicStates[k];
								if (_atomic.IsDescendantOf(_exitState)) {
									array_push(_deep, _atomic);
								}
							}				
							
							//Make sure the recorded states are unique.		
							array_unique_ext(_deep);						
						}
						
						//Add the recorded states to the histories
						_newHistories.SetHistory(_history, _deep);
					}
					
					//For shallow history we only need to record the most immediate children that are active
					else {
						if (is_undefined(_shallow)) {
							//We can find immediate children that are active by taking the intersection of the states immediate children and all active states.
							_shallow = array_intersection(_activeStates, _transitState.GetChildren());
						}
						_newHistories.SetHistory(_history, _shallow);
					}						
				}
			}
		}
	}
	
	/** Removes conflicting optimally enabled transitions from the execution data. *Depcrecated since it was merged into the same call as SelectTransitions()*
	 * @arg {Array<Struct.EnterableState>} _activeStates Current list of all active states. This list is used to help resolve transition source conflicts.
	 * @arg {Array<Struct.StateTransition>} _selectedTransitions This is the array where we store the transitions that pass the filters and should be taken by the machine.
	 * @arg {Array<Struct.StateTransition>} _enabledTransitions This is the list of all transitions that can potentially be taken by the machine.
	 * @return {Undefined} */
	static RemoveConflictingTransitions = function(_activeStates, _selectedTransitions, _enabledTransitions) {
		//Lastly, we need to remove any transitions that may conflict with each other.
		var _filteredTransitions = [];		//Transitions that we want to "keep". T2 transitions
		var _preemptedTransitions = [];		//Transitions that we compare the above "keep" transitions against (to see if there's a conflict to resolve). T3 transitions.
		var _exitSets = ds_map_create();	//Cache our transition exit sets so we don't have to keep calculating them.
		
		
		//For each found enabledTransition T1, we test it against all T2 transitions (transitions selected for filteredTransitions)
		//A conflict occurs if T1 and T2 have any overlap between the states they need to exit (can't double exit a state)
		var _t1, _t2, _t3, _t1Preempted, _hasConflict;
		for (var i = 0; i < array_length(_enabledTransitions); i++) {
			_t1 = _enabledTransitions[i];
			_t1Preempted = false;
			
			//Checking if T1 has a conflict with any of the T2's
			for (var j = 0; j < array_length(_filteredTransitions); j++) {
				_t2 = _filteredTransitions[j];
				
				//Calculate the exit set for each transition as we visit them.
				_exitSets[? _t1] ??= FindExitSet(_t1, _activeStates);
				_exitSets[? _t2] ??= FindExitSet(_t2, _activeStates);
				
				
				//Try to resolve conflict if detected.
				if (ArrayContainsAnyValue(_exitSets[? _t1], _exitSets[? _t2])) {
					//If T1's source state is a descendent of T2's, then T2 is the problem transition.
					//There might still be more problematic T2's, so for now we just add it to preemptedTransitions so we can remove all the problematic T2's at the same time.
					if (_t1.GetParent().IsDescendantOf(_t2.GetParent())) {
						array_push(_preemptedTransitions, _t2);
					}
					
					//Otherwise T2 has prio. There's nothing more to do since in this case T2 is already in filtered transitions.
					else {
						//Since T1 was the problem, there's no need to keep testing it against the T2's, break and move to the next T1
						_t1Preempted = true;
						break;
					}
				}
			}
			
			//If T1 was the problem transition then we won't be selecting it for keeps. Remove it from the map.
			if (_t1Preempted) {
				ds_map_delete(_exitSets, _t1);
			}
			
			//If T1 wasn't the problem transition then we select it for keeps and leave its exit set intact. It will become a T2 during the next iteration.
			else {
				//Remove all the T2's that were problematic for T1. We don't need to test against those ones anymore (since T1 is going to become a T2).
				for (var k = 0; k < array_length(_preemptedTransitions); k++) {
					_t3 = _preemptedTransitions[k];
					ArrayRemove(_filteredTransitions, _t3);
					ds_map_delete(_exitSets, _t3);
				}
				
				//Add T1 to the array of T2's.
				array_push(_filteredTransitions, _t1);
			}
		}
		
		//Map is no longer needed.
		ds_map_destroy(_exitSets);
		
		//Populate our transition list with the filtered results
		array_copy(_selectedTransitions, 0, _filteredTransitions, 0, array_length(_filteredTransitions));
	}
	
	/** Selects all the transitions that should be taken in response to an event. Transitions are selected from the list of available transitions for the 
	 * current set of active states.
	 * @arg {Struct.StateExecutionContext} _executionContext Context that can be used to find enabled transitions
	 * @arg {Struct.StateEventExecutionData} _data Data that we populate with our found enabled transitions
	 * @return {Undefined} */
	static SelectTransitions = function(_executionContext, _data) {
		//Set up vars for collection transitions
		var _enabledTransitions = [];	//This array will contain all the transitions that are enabled by the event and current active states
		var _visited = [];				//Tracks the states we've already visited so we don't waste time evaluating them again.
		var _enterableState;			//Holds the state we're currently filtering transitions for
		var _event = _data.GetEvent();	//The event triggering the transition selection
		var _activeStates = _executionContext.GetStateMachineContext().GetActiveStates(); 	//Active states provide the list of transitions we can choose from.
		var _selectedTransitions = _data.GetTransitionList(); 								//Final list of transitions that we will use.
		
		
		//Make sure the array is empty so we aren't overlapping transitions.
		ArrayClear(_selectedTransitions);
		
		//Make sure the state configuration is sorted properly
		ArraySortAscendingOrder(_activeStates);
		
		
		//Getting each active state's outgoing transitions and seeing which ones are optimally enabled
		var _stateTransitions, _transition;
		for (var i = 0; i < array_length(_activeStates); i++) {
			_enterableState = _activeStates[i];
			
			//We only want the transitions and actions for atomic states
			if (_enterableState.IsAtomicState()) {
				var _final = _enterableState;//new var for typecasting
				
				//Final states do not have transitions so use the final's parent as the atomic state instead.
				if (StateIsFinal(_final)) {
					_enterableState = _final.GetParent();
					
					//A final state must always have a parent so if it didn't have one, something bad happened
					if (is_undefined(_enterableState)) {
						StateError("SelectTransitions", $"Invalid State Configuration. Encountered a final state with no parent!", self);
					}
				}
				
				
				//If this state doesn't have transitions, then we skip it.
				var _state = _enterableState;
				if (!StateIsTransitional(_state)) {
					LogWarning(ExceptionMessage("Select Transitions", "Non-transitional state detected. Skipping to next state in configuration"));
					continue;
				}
				
				var _current = _state;
				var _ancestorIndex = _state.GetNumberOfAncestors() - 1;
				var _transitionMatched = false;
				
				//Try to find an enabled transition for the current state. If we can't find one, search each of its ancestors until one is found.
				//We search here rather than defining a TransitionalState method that recursively checks parents so that we can avoid checking the same state more than once. 
				do {
					//Check each transition for ones that are enabled 
					_stateTransitions = _current.GetTransitions();
					
					for (var j = 0; j < array_length(_stateTransitions); j++) {
						_transition = _stateTransitions[j];
						
						//A transition is enabled if it can be triggered by the current event AND its condition is true
						if (_transition.IsEnabled(_event)) {
							_transitionMatched = true;
							array_push(_enabledTransitions, _transition);
							break;
						}
					}
					_current = ((!_transitionMatched) && (_ancestorIndex > -1)) ? _state.GetAncestor(_ancestorIndex--) : undefined;
				} 
				until (!(!_transitionMatched && !is_undefined(_current) && ArrayPushUnique(_visited, _current)));
			}
		}
		
		
		//Lastly, we need to remove any transitions that may conflict with each other.
		RemoveConflictingTransitions(_activeStates, _selectedTransitions, _enabledTransitions);
	}	
	
	/** Stores the provided event in the `StateSystemContext` as `EventInfo`
	 * @arg {Struct.StateExecutionContext} _executionContext The data used to handle the event
	 * @arg {Struct.Event} _event The event being handled
	 * @arg {Bool} _internal True if this is an internal event
	 * @return {Undefined} */
	static SetCurrentEventExecution = function(_executionContext, _event, _internal) {
		//Early exit if invalid event
		if (is_undefined(_event)) {
			return;
		}
		
		var systemContext = _executionContext.GetStateMachineContext();
		var eventId = _event.GetEventTag();
		var data = _event.GetEventPayload();
		var type = _event.GetEventType();
		var specifier;
		if (type == EventType.error) {
			specifier = EVENT_TYPE_SPECIFIER_PLATFORM;
		}
		else if (_internal) {
			specifier = EVENT_TYPE_SPECIFIER_INTERNAL;
		}
		else {
			specifier = EVENT_TYPE_SPECIFIER_EXTERNAL;
		}
		
		//id source is the name of the StateChart where the transitions that respond to events are defined.
		var sendId = _executionContext.GetStateChart().GetName();
		var eventInfo = new EventInfo(eventId, data, type, specifier, sendId);
	}	
	
	/** Transition the specified state system from one state to the next using the provided execution data and context. Collects states that require 
	 * additional post-processing due to the transitioning process.
	 * @arg {Struct.StateExecutionContext} _executionContext The context of the event execution
	 * @arg {Struct.StateEventExecutionData} _executionData Data relevant to the current execution
	 * @arg {Array<Struct.EnterableState>} _statesToInvoke Array of states with an active `ITaskRunner`.
	 * @return {Undefined} */
	static TransitionStep = function(_executionContext, _data, _statesToInvoke) {
		BuildExecution(_executionContext, _data);
		ExitStates(_executionContext, _data, _statesToInvoke);
		ExecuteTransitions(_executionContext, _data);
		EnterStates(_executionContext, _data, _statesToInvoke);
		_data.Clear();
	}
	
	
}