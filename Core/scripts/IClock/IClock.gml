//feather ignore all
 
/** IClock: Represents an object with a `Tick()` method
 * @return {Struct.IClock} */
function IClock() {
	
	/** Ticks this `IClock` to incrementally change the time it displays. 
	 * @return {Undefined} */
	Tick = function() {
		ThrowMethodNotImplemented("Tick", self);
	}
}