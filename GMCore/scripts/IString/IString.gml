//feather ignore all
 
/** Interface for a `Struct` that can safely be used as a `String`.
 * @return {Struct.IString} */
function IString() {
	
	//All structs are technically an IString, the purpose of this interface is more so to indicate which
	//struct types have overwritten their native `toString()` methods to print something consistent so
	//that they can be used as struct keys. A good example of this is `TagSpecfier`.
	
	
	/** Convert this struct or object into a string.
	 * @return {String} */
	toString = function() {
		ThrowMethodNotImplemented("toString");
	}
	
}