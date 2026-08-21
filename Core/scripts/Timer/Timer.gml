//feather ignore all

/** Represents a callback function that executes after the specified amount of time has passed. 
 * ***
 * *Deprecated: Use `GC_TimeSource()` and built in `time_source` functions*
 * ***
 * Implements: `IClock`
 * @deprecated
 * @return {Struct.Timer} */
function Timer() constructor {
	Implement(IClock);
	
	
	#region Internal
		///@ignore
		timeSource = undefined;
		
		///@ignore Remaining time on the timer (in FPS).
		duration = 0;				
		
		///@ignore How long the timer will run for (in FPS).
		startDuration = 1;												
		
		///@ignore The onExpired that this timer executes when it expires
		onExpired = new MulticastAction();
		
		///@ignore
		state = TimerState.stopped;
		
		/** Internal helper that only cancels the timer's time source
		 * @ignore
		 * @return {Undefined} */
		static CancelTimer = function() {
			if (!is_undefined(timeSource)) {
				call_cancel(timeSource);
				timeSource = undefined;
			}
		}
		
		/** Sets the value of the Timer's duration property (in FPS).
		 * @ignore Should only be called locally
		 * @arg {Real} _duration The value to set;
		 * @return {Undefined} */
		static SetDuration = function(_duration) {
			INLINE;
			duration = clamp(_duration, 1, GetStartingDuration());
		}	
		
		/** Sets the value of the Timer's starting duration (in FPS)
		 * @ignore Should only be called locally
		 * @arg {Real} _startDuration The value to set
		 * @return {Undefined} */
		static SetStartingDuration = function(_startDuration) {
			INLINE;
			startDuration = max(1, _startDuration);
		}				
		
		/** Returns how much time is left on this timer (in seconds)
		 * @return {Real} */
		static GetDuration = function() {
			INLINE;
			return duration;
		}
		
		/** Returns the remaining duration of this timer (in seconds)
		 * @return {Real} */
		static GetDurationInSeconds = function() {
			INLINE;
			return Time_ConvertFPSToSeconds(GetDuration());
		}	
		
		/** Returns the initial starting duration of this Timer (in frames).
		 * @return {Real} */
		static GetStartingDuration = function() {
			INLINE;
			return startDuration;
		}
		
		/** Returns the starting duration of this Timer (in seconds).
		 * @return {Real} */
		static GetStartingDurationInSeconds = function() {
			INLINE;
			return Time_ConvertFPSToSeconds(GetStartingDuration());
		}			
		
		/** Use this method to tell the Timer how long it should run for (in frames).
		 * @arg {Real} _time The amount of time to set in (in frames).
		 * @return {Undefined} */
		static SetTimer = function(_time) {
			INLINE;
			SetStartingDuration(_time);
			SetDuration(_time);
		}
		
		/** Set the duration of this timer in seconds
		 * @arg {Real} _seconds The amount of time to set (in seconds).
		 * @return {Undefined} */
		static SetTimerInSeconds = function(_seconds) {
			INLINE;
			SetTimer(Time_ConvertSecondsToFPS(_seconds));
		}
		
		/** Returns the current state of this timer
		 * @return {Constant.TimerState} */
		static GetTimerState = function() {
			INLINE;
			return state;
		}
		
		/** Returns `true` if the Timer is in its running state; otherwise returns `false`.
		 * @return {Bool} */
		static IsActive = function() {
			INLINE;
			return (state == TimerState.active);
		}
		
		/** Returns the `MulticastAction` that will execute when the timer expires.
		 * @return {Struct.MulticastAction} */
		static GetOnExpired = function() {
			INLINE;
			return onExpired;
		}
		
	#endregion
	
	
	#region Primary Methods
		
		/** Reset the duration of this timer to the starting duration
		 * @return {Undefined} */
		static Reset = function() {
			SetDuration(startDuration);
		}
		
		/** Starts/Resumes this timer.
		 * @return {Undefined} */
		static Start = function() {
			//Reset Duration if we've previously be stopped. 
			if (state == TimerState.stopped) {
				Reset();
			}
			
			//Starting our time source.
			if (is_undefined(timeSource)) {
				timeSource = call_later(1, time_source_units_frames, Tick, true);
			}
			state = TimerState.active;
		}
		
		/** Pauses this timer. Call `Start()` to continue this `Timer` from where it left off.
		 * @return {Undefined} */
		static Pause = function() {
			CancelTimer();
			state = TimerState.paused;
		}
		
		/** Stops ticking this timer and removes any remaining duration.
		 * @return {Undefined} */
		static Stop = function() {
			CancelTimer();
			state = TimerState.stopped;
		}
		
		/** Decrements the duration of this Timer and automatically expires it when duration hits 0
		 * @return {Undefined} */
		static Tick = function() {
			duration--;
			if (duration <= 0) {
				Stop();
				GetOnExpired().Broadcast();	
			}
		}
		
		/** Stops this timer, then broadcasts the bound expire action. Useful if you need to manually expire this timer before its scheduled expire time.
		 * @return {Undefined} */
		static Expire = function() {
			Stop();
			GetOnExpired().Broadcast();			
		}		
	#endregion
}


//Timer experiment using time_source_create instead of call_later. Decided to go with call_later version above
//because that give more flexibility for setting duration and is auto cleaned up by GM.
///** Represents a callback function that executes after the specified amount of time has passed. 
 //* ***
 //* Implements: `IClock`
 //* @return {Struct.Timer} */
//function Timer() constructor {
	//Implement(IClock);
	//
	//
	//#region Internal
		//
		/////@ignore The onExpired that this timer executes when it expires
		//onExpired = new MulticastAction();
		//
		////We call tick once every frame rather than just setting duration to the appropriate units because
		////doing it this way enables us to more easily modify the duration which gives more utility to this class
		//timeSource = GC_TimeSource(time_source_game, 1, self.Expire,, -1, time_source_expire_after);
	//#endregion
	//
	//
	//#region Getters/Setters
		//
		///** Returns how much time is left on this timer (in frames)
		 //* @return {Real} */
		//static GetDuration = function() {
			//INLINE;
			//return time_source_get_period(timeSource);
		//}
		//
		///** Returns the initial starting duration of this Timer (in frames).
		 //* @return {Real} */
		//static GetStartingDuration = function() {
			//INLINE;
			//return time_source_get_period(timeSource);
		//}		
		//
		///** Returns the remaining duration of this timer (in seconds)
		 //* @return {Real} */
		//static GetDurationInSeconds = function() {
			//INLINE;
			//return Time_ConvertFPSToSeconds(GetDuration());
		//}		
		//
		///** Returns the starting duration of this Timer (in seconds).
		 //* @return {Real} */
		//static GetStartingDurationInSeconds = function() {
			//INLINE;
			//return Time_ConvertFPSToSeconds(GetStartingDuration());
		//}
		//
		///** Use this method to tell the Timer how long it should run for (in frames).
		 //* @arg {Real} _frames The amount of time to set in (in frames).
		 //* @return {Undefined} */
		//static SetTimer = function(_frames) {
			//INLINE;
			//time_source_reconfigure(timeSource, max(1, _frames), time_source_units_frames, Expire, , -1, time_source_expire_after);
		//}
		//
		///** Use this method to tell the Timer how long it should run for (in seconds).
		 //* @arg {Real} _seconds The amount of time to set (in seconds).
		 //* @return {Undefined} */
		//static SetTimerInSeconds = function(_seconds) {
			//INLINE;
			//SetTimer(Time_ConvertSecondsToFPS(_seconds));
		//}
		//
		///** Returns the current state of this timer
		 //* @return {Constant.TimeSourceState} */
		//static GetTimerState = function() {
			//INLINE;
			//return time_source_get_state(timeSource);
		//}
		//
		///** Returns `true` if the Timer is in its running state; otherwise returns `false`.
		 //* @return {Bool} */
		//static IsActive = function() {
			//INLINE;
			//return (GetTimerState == time_source_state_active);
		//}
		//
		///** Returns the `MulticastAction` that will execute when the timer expires.
		 //* @return {Struct.MulticastAction} */
		//static GetOnExpired = function() {
			//INLINE;
			//return onExpired;
		//}
		//
	//#endregion
	//
	//
	//#region Primary Methods
		//
		//
		///** Reset's this timer's duration and begins ticking down. Expires automatically when duration reaches 0.
		 //* @return {Undefined} */
		//static Start = function() {
			//var state = time_source_get_state(timeSource) 
			//
			////Reset Duration if we've previously be stopped. 
			//if (state == time_source_state_stopped) {
				//time_source_reset(timeSource);
				//time_source_start(timeSource);
			//}
			//
			////If we're paused, just pickup where we left off
			//else if (state == time_source_state_paused) {
				//time_source_resume(timeSource);
			//}
		//}
		//
		///** Pauses this timer. Call `Start()` to continue this `Timer` from where it left off.
		 //* @return {Undefined} */
		//static Pause = function() {
			//time_source_pause(timeSource);
		//}
		//
		///** Stops ticking this timer and removes any remaining duration.
		 //* @return {Undefined} */
		//static Stop = function() {
			//time_source_stop(timeSource);
		//}
		//
		///** Automatically stops this timer, resets its duration, then broadcasts the bound expire action.
		 //* @return {Undefined} */
		//static Expire = function() {
			//Stop();
			//GetOnExpired().Broadcast();			
		//}
	//#endregion
//}