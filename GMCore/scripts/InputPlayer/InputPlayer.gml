//feather ignore all

/** InputPlayer: Represents the player at the system level. This is where `InputSystem` stores the data for a specific player. 
 * @return {Struct.InputPlayer} */
function InputPlayer() constructor {
	
	
	#region Private
		
		
		enum Input_PlayerFlags {
			blocked,															//The Player is being blocked from detecting input
			ghost,																//The Player is blocked from detecting input, but still reports a connection to the system					
			anyInput															//The Player has a verb with input value.
		}
		
		//Player states
		enum Input_PlayerConnectionStatus {
			connected,															//Player is connected in the system
			newlyConnected,														//Player was connected to the system in the current frame
			disconnected,														//Player is not connected to the system
			newlyDisconnected,													//Player was disconnected from the system in the current frame	
		}
		
		///@ignore
		static inputSystem = InputSystem.singleton;								//Reference to the main input system. It executes primary logic related to input detection and assignment.
		///@ignore
		flags = new BitMask();													//Tracks our system related flag states.
		
		//Devices
		///@ignore
		device = undefined;														//The device this Player uses for input detection (ie: Gamepad, kbm, etc).
		///@ignore
		deviceType = Input_DeviceType.none;										//Cache the device type.
		///@ignore
		inactivePeriod = 500;													//Determines how long the player has to go with no input to be considered inactive
		///@ignore
		lastInputTime = -inactivePeriod;										//Timestamp of the last detected input from this Player
		///@ignore
		lastGamepadType = Input_GamepadType.none;								//Last connected gamepad type for this player
		///@ignore
		status = Input_PlayerConnectionStatus.disconnected;						//Specific connection status of this Players device to the system.
		
		//Verbs and Clusters
		///@ignore
		static verbCount = inputSystem.VerbGetCount();							//Verb count
		///@ignore
		dictionary = new InputDictionary();										//Considering using a dictionary instead of going back to the input system every time. Should make exporting/importing easier too if we set the dictionary to be a descendant of Configurable().
		///@ignore
		verbs = dictionary.verbs;												//Array of verbs definitions we have defined.
		///@ignore
		consumedVerbs = [];														//Array of verbs that have been consumed by this player
		///@ignore
		rawInput = array_create(verbCount, 0);									//Array of raw input values collected by the device
		///@ignore
		clampedInput = array_create(verbCount, 0);								//Array of normalized input values collected by the device 
		///@ignore
		static clusterCount = inputSystem.ClusterGetCount();					//Cluster count
		///@ignore
		clusters = dictionary.clusters;											//Array of cluster definitions we have defined.
		///@ignore
		clusterPositions = array_create_ext(clusterCount, ClusterFindPosition);	//Array of cluster positions so we can avoid floating positions in the system.
		
		
		
		//These threshold arrays allows hotswap thresholds to be set on a per Player basis
		///@ignore
		minThreshold = array_create(Input_ClusterThresholdType.none, INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD);		//Array of minimum hotswap thresholds per cluster type
		///@ignore
		maxThreshold = array_create(Input_ClusterThresholdType.none, INPUT_GAMEPAD_THUMBSTICK_MAX_THRESHOLD);		//Array of maximum hotswap thresholds per cluster type	
		///@ignore
		minTriggerThreshold = INPUT_GAMEPAD_TRIGGER_MIN_THRESHOLD;													//Max trigger threshold for input value
		///@ignore
		maxTriggerThreshold = INPUT_GAMEPAD_TRIGGER_MAX_THRESHOLD;													//Min trigger threshold for input value
		
		
		
		
		/** Returns the expected thumbstick threshold type based on the gamepad bindings set for the specific verb
		 * @ignore
		 * @arg {Struct.InputVerb} _verb Verb used to calculate threshold type value
		 * @return {Real} */
		static FindClusterThresholdValue = function(_verb) {
			var _type = 0;
			var _binding;
			var _gamepadBindings = _verb.BindingsGetGamepad();
			
			var i = 0; repeat(array_length(_gamepadBindings)) {
				_binding = _gamepadBindings[i++];
				
				if (!is_undefined(_binding)) {
					
					_binding = abs(_binding);
					if (_binding == gp_axislh || _binding == gp_axislv) {
						_type |= 1;
					}
					
					else if (_binding == gp_axisrh || _binding == gp_axisrv) {
						_type |= 2;
					}
				}
			}			
			
			return _type;
		}
		
		/** Internal logic that calculates and returns the position of the specified `InputCluster`
		 * @ignore
		 * @arg {Struct.InputCluster} _cluster The cluster to find the position for. Also accepts values from `Enum.Input_Cluster`.
		 * @return {Struct.Vector2} */
		static ClusterFindPosition = function(_cluster) {
			_cluster = (is_numeric(_cluster)) ? clusters[_cluster] : _cluster;
			var _verbU = GetVerb(_cluster.VerbIndexUp());
			var _verbD = GetVerb(_cluster.VerbIndexDown());
			var _verbR = GetVerb(_cluster.VerbIndexRight());
			var _verbL = GetVerb(_cluster.VerbIndexLeft());
			
			var _x = _verbR.GetValueRaw() - _verbL.GetValueRaw();
			var _y = _verbD.GetValueRaw() - _verbU.GetValueRaw();
			
			return new Vector2(_x, _y);
		}
	#endregion
	
	
	
	#region Basics
		
		/** Returns the specified `InputVerb` defined by this player.
		 * @arg {Enum.Input_Verb} _verb The verb to return
		 * @return {Struct.InputVerb} */
		static GetVerb = function(_verb) {
			return verbs[_verb];
		}
		
		/** Returns a copy of the position of the specified cluster
		 * @arg {Enum.Input_Cluster} _cluster The cluster to get the position of
		 * @return {Struct.Vector2} */
		static GetClusterPosition = function(_cluster) {
			return clusterPositions[_cluster].Clone();
		}
		
		/** Returns the gamepad type for the gamepad that was last being used by this player. The return value will be a member of `Enum.Input_GamepatType`. 
		 * @return {Real} */
		static GetLastGamepadType = function() {
			return lastGamepadType;
		}
		
		/** Returns the cache of raw input values for this player
		 * @return {Array<Real>} */
		static GetRawInputCache = function() {
			return rawInput;
		}
		
		/** Returns the cache of clamped input values for this player
		 * @return {Array<Real>} */		
		static GetClampedInputCache = function() {
			return clampedInput;
		}
		
		/** Caches a raw input value for the specified verb. The value will be injected into the verb during the next update loop.
		 * @arg {Enum.Input_Verb} _verb The verb to cache the value for
		 * @return {Undefined} */
		static CacheRawInputValue = function(_verb, _value) {
			rawInput[_verb] = _value;
		}
		
		/** Caches a clamped input value for the specified verb. The value will be injected into the verb during the next update loop.
		 * @arg {Enum.Input_Verb} _verb The verb to cache the value for
		 * @return {Undefined} */
		static CacheClampedInputValue = function(_verb, _value) {
			clampedInput[_verb] = _value;
		}
		
		/** Returns true if this Player has it's input set as blocked. Blocked players do not read input.
		 * @return {Bool} */
		static IsBlocked = function() {
			return flags.IsBitActive(Input_PlayerFlags.blocked);
		}
		
		/** Set true to block input from this Player, or false to unblock it. A blocked Player will stop reading input. Release events will still fire as normal for all buttons being held down at the time that input is blocked.
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetBlocked = function(_bool) {
			flags.SetBitState(Input_PlayerFlags.blocked, _bool);
		}
		
		/** Returns true if the Player is set as ghost. A Player set as ghost cannot collect input from their device, however, they still report their device as connected.
		 * @return {Bool} */
		static IsGhost = function() {
			return flags.IsBitActive(Input_PlayerFlags.ghost);
		}
		
		/** Set the ghost state of this `InputSystemPlayer`. A Player set as ghost cannot collect input from their device, however, they still report their device as connected.
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetGhost = function(_bool) {
			flags.SetBitState(Input_PlayerFlags.ghost, _bool);
		}
		
		/** Returns `true` if this `InputSystemPlayer` is inactive. A Player is considered inactive if the period between its last reported input and the current time exceeds the `_inactivePeriod` window.
		 * @arg {Real} [_inactivePeriod] Optionally supply an inactivity period to use instead of using the default configured value (milli-seconds)
		 * @return {Bool} */ 
		static IsInactive = function(_inactivePeriod = inactivePeriod) {
			var _timeDiff = current_time - lastInputTime;
			return (_timeDiff > _inactivePeriod);
		}
		
		/** Sets the device for this player.
		 * @arg {Struct.InputDevice} _device The device to set
		 * @return {Undefined} */
		static SetDevice = function(_device) {
			//Update last input time to avoid device thrashing when being assigned a device without previously having one
			if (!HasDevice()) {
				lastInputTime = current_time;
			}
			//Virtual buttons must be reset for touch devices to accurately read touch input
			else if (UsesTouch()) {
				inputSystem.VirtualButtonResetAll();
			}
			
			
			//Assign our new device and update connection status for it. Here, we set device type to `none` which
			//helps us speed up the process since removing a device doesn't require as much logic as setting a device.
			device = _device;
			deviceType = Input_DeviceType.none;
			UpdateConnectionStatus();
			
			
			//Each device can only have one owner, so if we're actually setting a device, as opposed to removing it, we need
			//to update/reassign device ownership from its previous player to this player.
			if (!is_undefined(device)) {
				deviceType = device.GetType();
				
				//Generic devices are the only exception to the 1 device per player rule since its the device failsafe.
				if (!UsesGeneric()) {
					
					//Remove the device from the previous owner
					var _lastOwner = device.GetOwner();
					if (!is_undefined(_lastOwner)) {
						//Dont use the system to initiate removing the device because it would trigger a playerDeviceChanged event.  
						//If we're already coming from the inputSystem then it may cause an infinite event loop depending on the functions subscribed to that event.
						_lastOwner.SetDevice(undefined);
					}
					_device.SetOwner(self);
				}
				
				//Update our gamepad type
				if (UsesGamepad()) { 
					lastGamepadType = device.GetGamepadType();
				}
				
				//Lastly, make sure the device isn't in a rebinding state.
				inputSystem.DeviceDisableRebinding(device);
			}
		}
		
		/** Returns the players assigned `InputDevice`. Returns `undefined` if no device has been assigned to this Player.
		 * @return {Struct.InputDevice} */
		static GetDevice = function() { 
			return device;
		}
		
		/** Returns the type of `InputDevice` used by this player
		 * @return {Undefined} */
		static GetDeviceType = function() {
			return deviceType;
		}
		
		/** Returns if any input has been detected from this `InputSystemPlayer`.
		 * @return {Bool} */
		static GetAnyInput = function() {
			return flags.IsBitActive(Input_PlayerFlags.anyInput);
		}
		
		/** Set the anyinput state of this `InputSystemPlayer`
		 * @arg {Bool} _bool
		 * @return {Undefined} */
		static SetAnyInput = function(_bool) {
			flags.SetBitState(Input_PlayerFlags.anyInput, _bool);
		}
		
		/** Returns the specific connection status of this Player which will be one of the `Enum.Input_PlayerConnectionStatus` values
		 * @return {Real} */
		static GetConnectionStatus = function() {
			return status;
		}		
		
		/** Set a new minimum threshold value for hotswapping off of gamepad control stick input.
		 * @arg {Enum.Input_HotSwapType} _thresholdType The hotswap type to set the value for
		 * @arg {Real} _value Should be between 0 and 1.
		 * @return {Undefined} */
		static SetMinimumThresholdType = function(_thresholdType, _value) {
			if (_thresholdType == Input_ClusterThresholdType.both) {
				var i = 0; repeat(array_length(minThreshold)) {
					minThreshold[i++] = clamp(_value, 0, 1);
				}
			}
			else {
				minThreshold[_thresholdType] = clamp(_value, 0, 1);
				minThreshold[Input_ClusterThresholdType.both] = 0.5*(minThreshold[Input_ClusterThresholdType.left] + minThreshold[Input_ClusterThresholdType.right]);
			}
		}
		
		/** Returns the minimum hotswap threshold for the specified cluster type
		 * @arg {Enum.Input_ClusterThresholdType} _type 
		 * @return {Real} */
		static GetMinimumStickThreshold = function(_type) {
			return minThreshold[_type];
		}	
		
		/** Returns the maximum hotswap threshold for the specified cluster type
		 * @arg {Enum.Input_ClusterThresholdType} _type 
		 * @return {Real} */
		static GetMaximumStickThreshold = function(_type) {
			return maxThreshold[_type];
		}	
		
		/** Set a new maximum threshold value for hotswapping off of gamepad control stick input.
		 * @arg {Enum.Input_HotSwapType} _thresholdType The hotswap type to set the value for
		 * @arg {Real} _value Should be between 0 and 1.
		 * @return {Undefined} */
		static SetMaximumStickThreshold = function(_thresholdType, _value) {
			if (_thresholdType == Input_ClusterThresholdType.both) {
				var i = 0; repeat(array_length(maxThreshold)) {
					maxThreshold[i++] = clamp(_value, 0, 1);
				}
			}
			else {
				maxThreshold[_thresholdType] = clamp(_value, 0, 1);
				maxThreshold[Input_ClusterThresholdType.both] = 0.5*(maxThreshold[Input_ClusterThresholdType.left] + maxThreshold[Input_ClusterThresholdType.right]);
			}
		}	
		
		/** Returns the minimum threshold value for hotswapping off of gamepad trigger input
		 * @return {Real} */
		static GetMinimumTriggerThreshold = function() {
			return minTriggerThreshold;
		}
		
		/** Sets the minimum threshold value for hotswapping off of gamepad trigger input.
		 * @arg {Real} _value The value to set. Default value is 0.05 (`INPUT_GAMEPAD_TRIGGER_MIN_THRESHOLD`)
		 * @return {Undefined} */
		static SetMinimumTriggerThreshold = function(_value = INPUT_GAMEPAD_TRIGGER_MIN_THRESHOLD) {
			minTriggerThreshold = _value;
		}
		
		/** Returns the maximum threshold value for hotswapping off of gamepad trigger input.
		 * @return {Real} */		
		static GetMaximumTriggerThreshold = function() {
			return maxTriggerThreshold
		}
		
		/** Sets the minimum trheshold value for hotswapping off of gamepad trigger input.
		 * @arg {Real} _value The value to set. Default value is 0.9 (`INPUT_GAMEPAD_TRIGGER_MAX_THRESHOLD`)
		 * @return {Undefined} */
		static SetMaximumTriggerThreshold = function(_value = INPUT_GAMEPAD_TRIGGER_MAX_THRESHOLD) {
			maxTriggerThreshold = _value;
		}
	#endregion
	
	
	#region Player Bindings
		/** Searches for all verbs that are bound to the specified button. If no verbs are found, an empty array is returned instead.
		 * @arg {Constant.InputButton} _button The button to search for
		 * @arg {Bool} [_forGamepad] `[=false]`Set to `true` if you're looking for a gamepad button. Otherwise verbs will search through their kbm bindings.
		 * @arg {Array} [_resultBag] `[=undefined]` Optionally provide an array where results should be stored.
		 * @return {Array<StructInputBindingCapture>} */
		static FindVerbsBoundTo = function(_button, _forGamepad = false, _resultBag = undefined) {
			_resultBag ??= [];
			
			var i = 0; repeat(verbCount) {
				var  _verb = GetVerb(i);
				var _index = _verb.FindBindingPosition(_button, _forGamepad);
				
				if (_index > -1) {
					var _collision = new InputBindingCapture(i, _button, _index, _forGamepad);
					array_push(_resultBag, _collision);
				}
				i++;
			}
			return _resultBag;
		}
		
	#endregion
	
	
	
	#region Verbs
		
		/** Consume a verb causing it to be immediately deactivated and return a value of 0 until the verb is reactivated. Useful for situations where you want to limit the number of detectable inputs, such as in menu screens.
		 * @arg {Enum.Input_Verb} _verb The verb to consume
		 * @return {Undefined} */
		static VerbConsume = function(_verb) {
			array_push(consumedVerbs, verbs[_verb]);
		}
		
		/** Invokes `VerbConsume` on all verb definitions held by this Player
		 * @return {Undefined} */
		static VerbConsumeAll = function() {
			var i = 0; repeat (verbCount) {
				VerbConsume(i++);
			}
		}
		
		/** Sets the raw and clamped values of all this players verbs to 0.
		 * @return {Undefined} */
		static VerbResetValueAll = function() {
			var i = 0; repeat (verbCount) {
				verbs[i++].ValueReset();
			}
		}
		
		/** Updates thumbstick thresholds for this players cluster definitions.
		 * @return {Undefined} */
		static ClusterUpdateThresholds = function() {
			var _type = 0;
			var _cluster;
			
			var i = 0; repeat(clusterCount) {
				_cluster = clusters[i++];
				
				_type |= FindClusterThresholdValue(verbs[_cluster.VerbIndexUp()]);
				_type |= FindClusterThresholdValue(verbs[_cluster.VerbIndexDown()]);
				_type |= FindClusterThresholdValue(verbs[_cluster.VerbIndexLeft()]);
				_type |= FindClusterThresholdValue(verbs[_cluster.VerbIndexRight()]);
				if (_type <= 1) {
					_cluster.ThresholdSetType(Input_ClusterThresholdType.left);
				}
				else if (_type == 2) {
					_cluster.ThresholdSetType(Input_ClusterThresholdType.right);
				}
				else {
					_cluster.ThresholdSetType(Input_ClusterThresholdType.both);
				}
			}
		}	
	#endregion			
	
	
	#region Devices and Connection
		/* 
		 * A Device represents the physical controller used by this `InputSystemPlayer` and is required by the Player for it to collect player input. Note that the 
		 * device itself isn't doing input collection, the Player is doing the collecting, the device just tells the Player what the button layout is, what is mapped to 
		 * each button, etc.
		 * 
		 * An InputPlayer can only use 1 device at a time, but is automatically assigned a device for each device type. Fundamentally, there are 3 different 
		 * types of devices: Gamepads, Keyboard and Mouse (KBM), and Touch Screen.
		 * 
		 */
		
		/** Returns `true` if this Player has any assigned device
		 * @ignore
		 * @return {Bool} */
		static HasDevice = function() {
			return (deviceType != Input_DeviceType.none);
		}
		
		/** Returns `true` if this player uses gamepad controls
		 * @return {Bool} */ 
		static UsesGamepad = function() {
			return (deviceType == Input_DeviceType.gamepad);
		}
		
		/** Returns `true` if the assigned device is an instance of `InputDeviceGeneric`
		 * @return {Bool} */
		static UsesGeneric = function() {
			return (deviceType == Input_DeviceType.generic);
		}
		
		/** Returns `true` if the assigned device is an instance of `InputDeviceKBM`
		 * @return {Bool} */
		static UsesKbm = function() {
			return (deviceType == Input_DeviceType.kbm);
		}
		
		/** Returns `true` if the assigned device is an instance of `InputDeviceTouch`
		 * @return {Bool} */
		static UsesTouch = function() {
			return (deviceType == Input_DeviceType.touch);
		}
		
		/** Updates this `InputSystemPlayers` state according to the condition of its device. Returns `true` if the device is connected.
		 * @return {Bool} */
		static UpdateConnectionStatus = function() {
			var _connected = (IsGhost() || inputSystem.DeviceIsConnected(device));
			
			//Changing the state to one of the connected states
			if (_connected) {
				
				if (status == Input_PlayerConnectionStatus.newlyDisconnected || status == Input_PlayerConnectionStatus.disconnected) {
					status = Input_PlayerConnectionStatus.newlyConnected;
				}
				else {
					status = Input_PlayerConnectionStatus.connected;
				}
				
			}
			//Change to disconnected
			else {
				
				if (status == Input_PlayerConnectionStatus.newlyConnected || status == Input_PlayerConnectionStatus.connected) {
					status = Input_PlayerConnectionStatus.newlyDisconnected;
				}
				
				else {
					status = Input_PlayerConnectionStatus.disconnected;
				}
			}
			return _connected;
		}	
		
		/** Returns `true` if this Player is using a device that is connected to the `InputSystem`
		 * @return {Bool} */
		static IsConnected = function() {
			var _newCon = (status == Input_PlayerConnectionStatus.newlyConnected);
			var _con = (status == Input_PlayerConnectionStatus.connected);
			return (_newCon || _con);
		}
	#endregion	
	
	#region Events
		
		/** Runs an update on the verbs owned by this Player.
		 * @return {Undefined} */
		static Update = function() {
			
			//Update Consumed Verbs//
			var _consumedVerb;
			var i = array_length(consumedVerbs) - 1; 
			while(i >= 0) {
				//Clearing consumed verbs
				_consumedVerb = consumedVerbs[--i];
				if (_consumedVerb.IsHeld()) {
					_consumedVerb.Clear();
					array_delete(consumedVerbs, i, 1);
				}
			}
			
			//Update Clusters//
			i = 0; repeat(clusterCount) {
				var _cluster = clusters[i];
				
				//Calculating cluster values from its position
				var _clusterPosition = ClusterFindPosition(_cluster);
				var _magnitude = _clusterPosition.Magnitude();
				
				//If the cluster has any magnitude, then we need to correct its position
				//Otherwise the raw position can be added to save on some math calls
				if (_magnitude > 0) {
					
					//Factoring in cluster threshold types
					_clusterPosition.Normalize();
					_magnitude = _clusterPosition.Magnitude();
					
					//If using a gamepad then apply thumbstick thresholds. Ignores if a thumbstick was actually used and only checks if it thinks it was used.
					//Potentailly problematic in unanticipated cases
					if (GetDeviceType() == Input_DeviceType.gamepad) {
						
						var _thresholdType = _cluster.ThresholdGetType();
						
						var _min = minThreshold[_thresholdType];
						var _max = maxThreshold[_thresholdType];
						
						var _coef = MathLinear(_magnitude, _min, _max);
						_clusterPosition = _clusterPosition.Multiply(_coef);
					}
					
					
					//Adjust position if we have bias for positional correction
					//Distance from the biasAngle will influence our affinity to make a correction
					//where farther distance has less affinity and the bias factor influences the strength of that correction.
					var _bias = _cluster.AxisBias();
					if (_bias > 0) {
						
						var _biasAngle = (_cluster.UsesDiagonalBias()) ? 45 : 90;					//The angle we are biased to
						var _angle = _clusterPosition.Direction();									//Current position angle relative to 0
						var _finalAngle = 0;														//The angle we should be at after applying bias
						var _rotation = 0;															//How much rotation we need to apply to reach our correction.
						
						
						//At max bias, our position is rotated to be on the biasAngle exactly. 
						if (_bias >= 1) {
							_rotation = _angle - _biasAngle;
						}
						//Otherwise finalize direction using bias
						else {
							
							//Introduce our bias to our interpolation variables
							var _a = _bias * 0.5;
							var _b = 1 - _a;
							
							//Interpolate and account for rotational sign using _norm value
							var _norm = (_angle%_biasAngle)/_biasAngle;								
							var _mod = MathSmoothstep(_a, _b, _norm);		
							
							//Calculate our final rotation to apply in order to correct the cluster position.
							var _mult = (_angle div _biasAngle) + _mod;								
							_rotation = _angle - (_biasAngle * _mult);								
						}
						
						_clusterPosition = _clusterPosition.Rotate(_finalAngle);
					}
					clusterPositions[i++] = _clusterPosition;
				}
			}
			
			//Flag will be set by our InputSystem PlayerUpdate event which occurs after we turned it off at the start of this method.
			if (GetAnyInput()) {
				lastInputTime = current_time;
			}
		}		
	#endregion	
}	