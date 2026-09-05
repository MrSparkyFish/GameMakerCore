//feather ignore all
 
/** ISortable: Represents the interface for objects that can sorted in an array.
 * @return {Struct.ISortable} */
function ISortable() {
	
	/** Return's the order value of this `ISortable`.
	 * @return {Real} */
	GetElementOrder = function() {
		ThrowMethodNotImplemented("GetOrder", self);
	}
	
}