/** GamepadGUID: Stores vendor/product information about a particular gamepad.
 * @arg {String} _guid The gamepad guid to unpack and store
 * @return {Struct.InputGamepadGUID} */
function InputGamepadGUID(_guid = undefined) constructor {
	
	
	//Expected GUID pattern:
	// 
	//  **** 0000 **** 0000 **** 0000 **** XXXX
	//  N1   N2   N3   N4   N5   N6   N7   N8
	//
	// N1: Bus (OS driver)
	// N3: Vendor ID
	// N5: Product ID
	// N7: Revision
	// N8: Driver hint (SDL)
	//
	//If instead of the expected VID + PID + REV pattern, GUID is used to encode device
	//description, N3 onwards contains encoded description instead of indicated values.
	//On Android platform, GUID description encoding begins at N1 and will not mismatch		
	
	
	#region Internal
		///@ignore
		static empty = "00000000000000000000000000000000";						//Blank GUID for comparison
		///@ignore
		guid = _guid ?? empty;													//Full GUID
		///@ignore
		vendor = "0000";														//Holds the parsed vendor info
		///@ignore
		product = "0000";														//Holds the parsed product info
		///@ignore
		driver = "0000";														//Holds the parsed driver info
		
		
		
		//Parsing the GUID for vendor, product, and driver info
		if (guid == empty) {
			if (INPUT_LOG_WARNING) {
				LogWarning($"GamepadGUID::Instantiation -> Guid [{guid}] is empty!");
			}
		}
		
		else {
			var n6 = string_copy(guid, 21, 4);
			var n4 = string_copy(guid, 13, 4);
			var n1 = string_copy(guid, 1, 4);	
			
			//Check for empty N4 indicating this is not a description encoded guid
			if (n4 == "0000") {
			
				//Confirm N6 is also empty
				if (n6 != "0000") {
					LogWarning($"GamepadGUID::Instantiation -> Guid [{guid}] does not fit expected pattern. Vendor and product ID cannot be extracted.");
					return self;
				}
				
				
				//Check if N1 is what we expect. Some situations may cause this to vary from the expected
				if (n1 != "0300" && n1 != "0500") {
					LogWarning($"GamepadGUID::Instantiation -> Guid driver ID [{n1}] doesn't match expected value of 0300 or 0500");
				}
				
				//Set vendor and product id values
				vendor = string_copy(guid, 9, 4);
				product = string_copy(guid, 17, 4);
				driver = n1;
			}
		}
		
	#endregion
	
	
	
	/** Returns the vendor ID of this `GamepadGUID`
	 * @return {String} */ 
	static GetVendorID = function() {
		return vendor;
	}
	
	/** Returns the product ID string of this `GamepadGUID`
	 * @return {String} */
	static GetProductID = function() {
		return product
	}
	
	/** Returns the driver ID string of this `GamepadGUID`
	 * @return {String} */
	static GetDriverID = function() {
		return driver;
	}
	
	/** Returns the packed GUID string used to derive the vendor, product, and driver IDs.
	 * @return {String} */
	static GetGUID = function() {
		return guid;
	}
	
}