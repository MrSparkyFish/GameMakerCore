//feather ignore all
 
/** MulticastAction: Abstract template class for creating your own event types. Allows you to add and remove callback functions and to specify 
 * data that will be passed to each callback. Call `Broadcast()` to invoke each function stored in the action.
 * @return {Struct.MulticastAction} */
function MulticastAction() constructor {
	
	#region Internal
		///@ignore Empty payload array so we don't have to allocate memory for each multi-cast action that doesn't use data.
		static emptyPayload = [];		
		
		///@ignore List of functions to invoke during Execute()
		actions = [];		
		
		/** Creates a new action using the supplied data and adds it to this `MulticastAction`
		 * @ignore
		 * @arg {Function} _function The function/method to invoke
		 * @arg {Struct|Id.Instance} _context The scope the callback should be executed in
		 * @arg {Array<Any>} _payload An array of prebake data to attach to the end of the execution data
		 * @return {Struct.Action} */
		static AddInternal = function(_function, _context, _payload) {
			var action = new Action();
			action.BindStatic(_context, _function, _payload);
			array_push(actions, action);
			return action;
		}
		
	#endregion
	
	/** Add a function to this `MulticastAction`. Returns the method variable of the added function.
	 * ***
	 * Functions added this way must be context independent or must have already been converted into a method variable. Using this method to add 
	 * a context dependent function will result in the game crashing when the action is fired.
	 * ***
	 * The callback function must accept the following parameters:
	 * * `{Parameters Not Required}`
	 * ***
	 * The callback function must return `undefined`
	 * @arg {Function} _callback The callback function to add
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Struct.Action} */
	static Add = function(_callback, _payload = undefined) {
		return AddInternal(_callback, undefined, _payload);
	}
	
	/** Add a function to this `MulticastAction` specifying the scope in which it should be called. Returns the method variable of the added function.
	 * ***
	 * This method should be used to add context dependent functions such as static methods declared in constructors or script functions that can 
	 * only be called from specific instances or structs.
	 * ***
	 * The callback function must accept the following parameters:
	 * * `{Parameters Not Required}`
	 * ***
	 * The callback function must return `undefined`
	 * @arg {Struct|Id.Instance} _context The scope the function should be called in.
	 * @arg {Function} _callback The callback function to add.
	 * @arg {Array<Any>} [_payload] Optional array of prebake data that will be attached to the end of the broadcasted data when passed to your callback.
	 * @return {Struct.Action} */
	static AddStatic = function(_context, _callback, _payload = undefined) {
		return AddInternal(_callback, _context, _payload);
	}
	
	/** Invoke each callback action one at a time and passing any relevant data.
	 * @arg {Array<Any>} [data] Optional array of data to broadcast. Prebaked data is attached to the end of this array.
	 * @return {Undefined} */
	static Broadcast = function(data = undefined) {
		var _len = array_length(actions);
		for (var i = 0; i < _len; i++) {
			actions[i].Execute(data);
		}
	}	
	
	/** Returns the index of the first callback action that is bound to the specified context. Returns `-1` if no callback is bound to the specified context.
	 * @arg {Struct|Id.Instance} _context The context to look for
	 * @return {Real} */
	static FindCallbackForContext = function(_context) {
		var _len = array_length(actions);
		for (var i = 0; i < _len; i++) {
			if (_context == GetCallbackContext(i)) {
				return i;
			}
		}
		return -1;
	}	
	
	/** Populates an array with all the callback functions held by this `MulticastAction`.
	 * @arg {Array<Struct.Action>} _outActions The array to populate beginning at index 0. This array is automatically resized.
	 * @return {Array<Struct.Action>} */
	static GetActions = function(_outActions = []) {
		var _len = GetCount();
		array_resize(_outActions, _len);
		array_copy(_outActions, 0, actions, 0, _len);
		return _outActions;
	}
	
	/** Returns the context set for the callback at the specified index. Will throw an error if the index is out of bounds.
	 * @arg {Real} _index The index of the callback to get the context for
	 * @return {Struct|Id.Instance|Undefined} */
	static GetCallbackContext = function(_index) {
		return actions[_index].GetContext();
	}
	
	/** Returns the number of callback functions in this multicast action
	 * @return {Real} */
	static GetCount = function() {
		return array_length(actions);
	}
	
	/** Removes the first copy of the specified method variable from this `MulticastAction`
	 * @arg {Struct.Action} _action The action delegate to remove
	 * @return {Undefined} */
	static Remove = function(_action) {
		ArrayRemove(actions, _action);
	}
	
	/** Removes the callback action at the specified index. Doesn't check if the index is in bounds.
	 * @arg {Real} _index The index of the callback to remove
	 * @return {Undfined} */
	static RemoveByIndex = function(_index) {
		array_delete(actions, _index, 1);
	}
	
	/** Removes the callback action at the specified index. Checks that the provided index is in bounds.
	 * @arg {Real} _index The index of the callback to remove
	 * @return {Undfined} */	
	static RemoveByIndexSafe = function(_index) {
		var actions = actions;
		if (ArrayIsIndexInBounds(actions, _index)) {
			array_delete(actions, _index, 1);
		}
	}
	
	/** Removes all copies of the specified action from this `MulticastAction` and returns how many were removed.
	 * @arg {Struct.Action} _action The function to remove
	 * @return {Real} */
	static RemoveAllCopies = function(_action) {
		var actions = actions;
		return ArrayFilterValue(actions, _action);
	}
	
	/** Removes all actions bound to the specified object and returns how many were removed
	 * @arg {Struct} object The object to remove actions for
	 * @return {Undefined} */
	static RemoveByBoundObject = function(object) {
		var len = array_length(actions);
		var count = 0;
		for (var i = 0; i < len; i++) {
			if (GetCallbackContext(i) == object) {
				RemoveByIndex(i);
				count++;
			}
		}
		return count;
	}
	
	/** Remove all actions from this `MulticastAction`
	 * @return {Undefined} */
	static Clear = function() {
		actions = [];
	}
	
	/** Returns `true` if at least one callback action is bound to this `MulticastAction`
	 * @return {Bool} */
	static IsBound = function() {
		return (array_length(actions) > 0);
	}
	
	/** Returns `true` if this `MulticastAction` has at least one action that is bound to the specified object
	 * @arg {Struct} object The object to check
	 * @return {Bool} */
	static IsBoundToObject = function(object) {
		var len = array_length(actions);
		for (var i = 0; i < len; i++) {
			if (GetCallbackContext(i) == object) {
				return true;
			}
		}
		return false;
	}
	
	/** Returns a copy of this `MulticastAction`
	 * @return {Struct.MulticastAction} */
	static Clone = function() {
		var copy = new MulticastAction();
		copy.actions = actions;
		return copy;
	}
}