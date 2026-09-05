//feather ignore all

#macro STATE_WILD_TRANSITION_NAME "*"
#macro EVENT_ENTER_STATE "Event.Enter.State"
#macro EVENT_EXIT_STATE "Event.Exit.State"
#macro EVENT_DONE_STATE "Event.Done.State"

/** Throws a state related error
 * @arg {String} _func Name of the function that threw the error
 * @arg {String} _desc Description of the error
 * @arg {Struct|Id.Instance} [_origin] Optional scope if the 'self' keyword isn't sufficient.
 * @return {Undefined} */
function StateError(_func, _desc, _origin = undefined) {
	_origin ??= self;
	var _m = "State Error!";
	var _lm = ExceptionMessage(_origin, _func, _desc);
	ThrowException(_m, _lm);
}

/** Returns the singleton `StateChartManager`
 * @return {Undefined} */
function StateGetChartManager() {
	static singleton = new StateChartManager();
	return singleton;
}

/** Get the machine that corresponds to the specified machine name
 * @arg {String} _machineName The name of the machine to get
 * @return {Struct.StateChart} */
function StateGetChart(_machineName) {
	return StateGetChartManager().GetMachineModel(_machineName);
}

/** Add a machine to the state system.
 * @arg {Struct.StateChart} _machine The machine to add
 * @arg {String} _machineName The name to give the machine
 * @return {Undefined} */
function StateSetChart(_machine, _machineName) {
	StateGetChartManager().AddMachineModel(_machine, _machineName);
}

/** Returns `true` if the specified transition target is a history state.
 * @arg {Struct.HistoryState} _target The `TransitionTarget` to check (typcasts to the type specified by this parameter)
 * @return {Bool} */
function StateIsHistory(_target) {
	return (is_instanceof(_target, HistoryState));
}

/** Returns `true` if the specified transition target is a parallel state
 * @arg {Struct.ParallelState} _target The `TransitionTarget` to check (typcasts to the type specified by this parameter)
 * @return {Bool} */
function StateIsParallel(_target) {
	return (is_instanceof(_target, ParallelState));
}

/** Returns `true` if the specified state is a compound state.
 * @arg {Struct.State} _target The `TransitionTarget` to check (typcasts to the type specified by this parameter). 
 * @return {Bool} */
function StateIsState(_target) {
	return (is_instanceof(_target, State));
}

/** Returns `true` if the specified transition target is a final state
 * @arg {Struct.FinalState} _target The `TransitionTarget` to check (typcasts to the type specified by this parameter)
 * @return {Bool} */
function StateIsFinal(_target) {
	return (is_instanceof(_target, FinalState));
}

/** Returns `true` if the specified transition target is a transitional state
 * @arg {Struct.TransitionalState} _target The `TransitionTarget` to check (typcasts to the type specified by this parameter)
 * @return {Bool} */
function StateIsTransitional(_target) {
	return (is_instanceof(_target, TransitionalState));
}

/** Returns `true` if the specified transition target is an enterable state
 * @arg {Struct.EnterableState} _target The `TransitionTarget` to check (typcasts to the type specified by this parameter)
 * @return {Bool} */
function StateIsEnterable(_target) {
	return (is_instanceof(_target, EnterableState));
}

/** Returns `true` if the a member of the specified states is a descendant of the provided state.
 * @arg {Array<Struct.EnterableState>} _states The list of states to check
 * @arg {Struct.EnterableState>} _state The state to check as the parent
 * @return {Bool} */
function StateContainsDescendant(_states, _state) {
	var _len = array_length(_states);
	for (var i = 0; i < _len; i++) {
		if (_states[i].IsDescendantOf(_state)) {
			return true;
		}
	}
	return false;	
}