//feather ignore all
/**
 * @return {} */
function InputVerbGroupDictionary() constructor {
    //Whether verbs should be blocked if *any* of their verb groups are inactive. If you set this macro
    //to `false` then a verb will only be blocked if *all* of its verb groups are inactive.
    #macro INPUT_VERB_GROUP_INACTIVE_ON_ANY  false
    
	
    enum Input_VerbGroup {
        //Add your own verb groups here!
		//Don't forget to also add it to the below array
    }
    
    //If you add a verb group in the `INPUT_VERB_GROUP` enum then you should also add it to the array here.
    //
    // N.B. Any verb not in at least one verb group will be considered as being in every verb group for
    //      the purposes of finding binding collisions.
    
	
	//Verbs should ONLY BE ADDED using the syntax below. The system needs them to be ordered during initializing, and
	//this method ensures the verbs stay in enum order regardless of the order you actually added them. 
	//This makes it easier on yourself when you need to add or remove verb groups later on.
	
	//	verbGroups[Input_VerbGroup.exampleGroup] = [Input_Verb.verbA, Input_Verb.verbB, Input_Verb.verbC, Input_Verb.etc]);	
	verbGroups = [];
	
	
	/** Simple getter that allows the system to initialize your group definitions while simulataneaously cleaning up loose memory.
	 * @return {Array<Array<Real>>} */
	static GetVerbGroups = function() {
		//Since the array is only needed once, we cache it then destroy the array handle by setting -1 to clean up the memory (the handle destruction goes through on the next frame)
		//Otherwise the array will stick around for the duration of the game and never be used.
		//The cached array will be destroyed automatically sinces its assigned a local variables.
		var _groups = verbGroups;
		verbGroups = -1;
		return _groups;
	}
}