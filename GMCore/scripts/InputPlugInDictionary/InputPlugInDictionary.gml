//feather ignore all
 
/**
 * @return {} */
function InputPlugInDictionary() constructor {
	
	//Add the constructor functions of the plugins that you want the input system to utilize
	plugIns = [
		new InputPlugIn("InputRumble", "NA", "NA", "NA", InputRumbleSystem),
		new InputPlugIn("InputVerbGroup", "NA", "NA", "NA", InputVerbGroupSystem),
		
	]
	
}