//feather ignore all

/** TimeSource: This object ticks IClock objects. This is a dynamic data resource, therefore its `.CleanUp` method must be called before it is removed or it will cause a memory leak.
 * ***
 * *Was only used by timers, but timers now favor using call_later
 * @deprecated
 * @ignore
 * @return {Struct.TimeSource} */
function TimeSource() constructor {
	Implement(ILockableScope);
	
	//TODO: Time sources need to be able to be saved and loaded.
	
	///@ignore List of all Timers observed by this TimeSource	
	clocks = [];
	
	///@ignore The actual time source tracking time. Using frames to be consistent with GMO alarms
	timeSource = time_source_create(								
		time_source_game, 1, time_source_units_frames, 
		self.Update, [], -1, time_source_expire_after
	);
	
	///@ignore List of clocks waiting to be removed
	pendingRemoves = [];
	
	
	///@ignore List of clocks waiting to be added
	pendingAdds = [];
	
	///@ignore Current lock count
	lockCount = 0;
	
	
	//Track the timesource so we can auto clean it if we ever get removed.
	var ts = timeSource;
	GC_Track(ts, self, CleanUp);	
	
	
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
				
				array_foreach(pendingAdds, AddClock);
				ArrayFilterValues(clocks, pendingRemoves);
				
			}
		}
	}		
	
	/** Stops this `TimeSource` if it isn't already stopped then destroys dynamic resources to clean up memory
	 * @return {Undefined} */
	static CleanUp = function() {
		time_source_stop(timeSource);
		time_source_destroy(timeSource);
	}
	
	/** Determines if the argument timer is being tracked by the TimeSource. Returns true if it is, or false if it isn't.
	 * @arg {Struct.IClock} _clock The timeable object to check for 
	 * @return {Bool} */
	static HasTimer = function(_clock) {
		return array_contains(clocks, _clock);
	}	
	
	
	/** Adds a Clock object to this TimeSource
	 * @arg {Struct.IClock} _clock An object implementing IClock
	 * @return {Undefined} */
	static AddClock = function(_clock) {
		if (lockCount > 0) {
			if (!array_contains(pendingAdds)) {
				array_push(pendingAdds, _clock);
			}
		}
		
		else {
			LockScope();
			{
				//Don't want to double up on timer's
				if (!array_contains(clocks, _clock)) {
					array_push(clocks, _clock);
				}
				
				//Make sure the TimeSource is unpaused
				if (time_source_get_state(timeSource) == time_source_state_paused) {
					time_source_resume(timeSource);
				}	
			}	
			UnlockScope();		
		}
	}
	
	/** Removes an IClock object from this TimeSource
	 * @arg {Struct.IClock} _clock An object implementing IClock
	 * @return {Undefined} */
	static RemoveClock = function(_clock) {
		if (lockCount > 0) {
			array_push(pendingRemoves, _clock)
		}
		else {
			ArrayRemove(clocks, _clock);
		}
	}
	
	/** Notify that the TimeSource has changed. 
	 * @return {Undefined} */
	static Update = function() {
		//Pause the time source if there are no timer objects to track
		if (ArrayIsEmpty(clocks)) {
			var _state = time_source_get_state(timeSource);
			if (_state != time_source_state_paused) {
				time_source_pause(timeSource);
			}
		}
		
		//Tick each timer.
		else {
			//Use a lock to prevent prematurely modifying this time in case a clock tries to modify it during its tick.
			LockScope();
			{
				array_foreach(clocks, Time_TickClock);
			}
			UnlockScope();
		}
	}
}