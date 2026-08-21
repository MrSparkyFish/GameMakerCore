if (launchGameWIthRandomSeed) {
	randomize();
}


if (launchGameInFullscreen) {
	window_set_fullscreen(true);
}


//Decide what room we should transition to first.
if (debug_mode && launchTestEnvironment) {
	room_goto(rmUnitTest);
}
else if (debug_mode && launchDeveloperRoom) {
	//Give our player control over the game
	//instance_create_depth(0, 0, 0, oPlayerController);
	room_goto(DevRoom);
}
else {
	//Launch the first room
	if (room_exists(launchGameRoom)) {
		room_goto(launchGameRoom);
	} 
}