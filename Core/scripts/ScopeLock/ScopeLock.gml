//feather ignore all
 
/** Abstract base class for defining a lock that prevents certain actions from occuring until the lock is removed.
 * @return {Struct.ScopeLock} */
function ScopeLock() constructor {
	
	///@ignore Count of how many times `LockScope` has been called.
	lockCount = 0;
	
	///@ignore Callback action that will be executed when the lock is removed.
	onUnlockScope = new Action();
	
	/** Places a lock on the current scope. ScopeLock is used as a safety measure to prevent or defer certain logic from executing until 
	 * `UnlockScope()` is called. Most effectively used to handle situations where circular calls to the same function are possible.
	 * @return {Undefiend} */
	static LockScope = function() {
		lockCount++;
	}
	
	/** Removes a a lock placed with `LockScope()`. This method does nothing if the scope isn't currently locked.
	 * @return {Undefined} */
	static UnlockScope = function() {
		if (lockCount > 0) {
			lockCount--;
			if (lockCount == 0) {
				onUnlockScope.Execute();
			}			
		}
	}
	
	/** Returns a generic `Action` delegate that you can use to bind a callback to. This `Action` is executed each time an applied lock is removed.
	 * @return {Struct.Action} */
	static GetOnUnlockScope = function() {
		return onUnlockScope;
	}
}