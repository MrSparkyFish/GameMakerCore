//feather ignore all
 
#macro DEFAULT_TIMESOURCE_ID 		"$$TimeSource$$"
#macro TIME_GET_TIMER_SECONDS  		get_timer()*ONE_MILLION



//Various state of Timer
enum TimerState {
	stopped,						//Timer has been stopped. Starting the timer again causes a restart
	paused,							//Timer has been paused. Starting the timer again causes it to continue from where it left off
	active							//Timer is active. Starting the timer again does nothing.
}