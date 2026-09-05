//feather ignore all

/** InputDictionary: Contains the complete collection of available verb definitions. New verb definitions should `NEVER` be added to a dictionary at runtime or the system will not recognize them.
 * @return {Struct.InputDictionary} */
function InputDictionary() constructor {
	
	//Add verbs here
	enum Input_Verb {
		up,
		down,
		left,
		right,
		confirm,
		cancel,
		pause, 
	}
	verbs[Input_Verb.up] 		= new InputVerb(Input_Verb.up, "Up", [vk_up, "W"], [-gp_axislv, gp_padu]);
	verbs[Input_Verb.down]		= new InputVerb(Input_Verb.down, "Down", [vk_down, "S"], [gp_axislv, gp_padd]);
	verbs[Input_Verb.left] 		= new InputVerb(Input_Verb.left, "Left", [vk_left, "A"], [-gp_axislh, gp_padl]);
	verbs[Input_Verb.right]		= new InputVerb(Input_Verb.right, "Right", [vk_right, "D"], [gp_axislh, gp_padr]);
	verbs[Input_Verb.confirm]	= new InputVerb(Input_Verb.confirm, "Accept", vk_space, gp_face1);
	verbs[Input_Verb.cancel]	= new InputVerb(Input_Verb.left, "Cancel", [vk_escape, vk_backspace], gp_face2);
	verbs[Input_Verb.pause]		= new InputVerb(Input_Verb.left, "Pause", vk_escape, gp_start);
	
	//Add clusters here
	enum Input_Cluster {
		move
	}	
	clusters[Input_Cluster.move] = new InputCluster(Input_Cluster.move, Input_Verb.up, Input_Verb.down, Input_Verb.left, Input_Verb.right);
}