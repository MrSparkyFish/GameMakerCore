//feather ignore all

//To indicate a NULL value when `undefined` would not work.
#macro NULL 		"$$Null$$" 

//Put this inside of a function to inline it.
#macro INLINE 		gml_pragma("forceinline")

//Constant for getting fps
#macro GAMESPEED_FPS 	game_get_speed(gamespeed_fps)

//Constant for getting mps
#macro GAMESPEED_MPS 	game_get_speed(gamespeed_microseconds)

//Defines collision for movement functions such as `move_and_collide`.
#macro COLLISION [layer_tilemap_get_id(layer_get_id("Collision"))]


/** Does nothing. This is a placeholder function so we don't have to create a new function signature everytime we need an empty func.
 * @return {Undefined} */
function ReturnUndefined() {}