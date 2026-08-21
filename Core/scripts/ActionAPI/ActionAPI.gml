//feather ignore all


#macro ACTION_LOG_WARNING true
#macro ACTION_LOG_ERROR true;

 
/** Throw an Action delegate related error.
 * @arg {String} _func name of the function throwing the error
 * @arg {String} _description Description of the error
 * @arg {Struct|Id.Instance} [_scope] Optional scopoe if `self` doesn't suffice
 * @return {Undefined} */
function ActionError(_func, _description, _scope = undefined) {
	var _title = "Action Error!"
	var _message = ExceptionMessage(_scope, _func, _description);
	ThrowException(_title, _message, _scope);
}

/** Helper function to execute actions from built-in functions such as `array_foreach`.
 * @arg {Struct.Action} action The action to execute.
 * @arg {Array<Any>} [params] Optional array of data to pass to the execute call
 * @return {Any} */
function Action_Execute(action, params = undefined) {
	return action.Execute(params);
}
