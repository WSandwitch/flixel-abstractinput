package flixel.input;

import flash.display.InteractiveObject;
import flixel.input.gamepad.FlxGamepad;

import flixel.FlxG;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

import flixel.system.macros.FlxMacroUtil;

/**
 * abstract input allow you to set custom actions 
 * and bind to them buttons of keyboard, mouse, gamepad 
 * and gamepad axis (positiv and negativ directions)
 * @author Yarikov Denis
 */

 typedef KeyType = Int;
 
class AbstractInputManager{
	
	public var ids:Array<AbstractInputID> = [];
	public var actions:Map<KeyType, Null<AbstractInputAction>> = new Map<KeyType, AbstractInputAction>();
	
	public var key_ids:Map<FlxKey, AbstractInputKeyboardID> = new Map<FlxKey, AbstractInputKeyboardID>();
	public var mouse_ids:Map<MouseID, AbstractInputMouseID> = new Map<MouseID, AbstractInputMouseID>();
	public var gamepad_key_ids:Map<FlxGamepadInputID, AbstractInputGamepadKeyID> = new Map<FlxGamepadInputID, AbstractInputGamepadKeyID>();
	public var gamepad_axis_ids:Map<GamepadAxisID, AbstractInputGamepadAxisID> = new Map<GamepadAxisID, AbstractInputGamepadAxisID>();

	public function new(){
		
	}
	
	public function addAction(name:KeyType):AbstractInputAction{
		if (!actions.exists(name))
			actions[name] = new AbstractInputAction(this, name);
		return actions[name];
	}
	
	public function getAction(name:KeyType):Null<AbstractInputAction>{
		if (!actions.exists(name))
			return null;
		return actions[name];
	}
	
	public function removeAction(name:KeyType):Bool{
		if (!actions.exists(name))
			return false;
		for (id in ids)
			id.actions.remove(name);
		return actions.remove(name);
	}
	
	/**
	 * Get value of the action
	 * 
	 * @param name	id of action
	 * @return value in 0..1, for buttons 1 or 0
	 */
	public function value(name:KeyType):Float{
		if (!actions.exists(name))
			return 0;
		return actions.get(name).value;
	}
	
	/**
	 * Check if action was pressed
	 * 
	 * @param	name id of action
	 * @return true/false
	 */
	
	public function justPressed(name:KeyType):Bool{
		if (!actions.exists(name))
			return false;
		return actions.get(name).justPressed;
	}
	
	/**
	 * Check if action was released
	 * 
	 * @param	name id of action
	 * @return true/false
	 */
	
	public function justReleased(name:KeyType):Bool{
		if (!actions.exists(name))
			return false;
		return actions.get(name).justReleased;
	}
	
	/**
	 * Check if any of actions was fired
	 * 
	 * @param names	ids of action
	 * @return true/false
	 */
	
	public function anyChanged(names:Array<KeyType>):Bool{
		for (name in names)
			if (justReleased(name) || justPressed(name))
				return true;
		return false;
	}
	
	/**
	 * Check if action is firing
	 * 
	 * @param name	id of action
	 * @return true/false
	 */
	
	public function pressed(name:KeyType):Bool{
		if (!actions.exists(name))
			return false;
		return actions.get(name).pressed;
	}
	
	/**
	 * Update values of actions
	 * 
	 * @return nothing
	 */
	
	public function update(){
		for(action in actions){
			action.justPressed = false;
			action.justReleased = false;
			action.pressed = false;
			action.value = 0;
		}
		for (id in ids){
			id.update();
		}
	}
	
	/**
	 * Get action by source id
	 * 
	 * @param	id id of abstract input source
	 * @return AbstractInputAction of source or null
	 */
	
	public function getActionBySource(id:AbstractInputID):Null<AbstractInputAction>{
		try{
			switch(id.type){
				case KEY:
					var cid:AbstractInputKeyboardID = cast id;
					return getAction(key_ids.get(cid.key).actions[0]);
				case MOUSE:
					var cid:AbstractInputMouseID = cast id;
					return getAction(mouse_ids.get(cid.key).actions[0]);
				case GAMEPADKEY:
					var cid:AbstractInputGamepadKeyID = cast id;
					return getAction(gamepad_key_ids.get(cid.key).actions[0]);
				case GAMEPADAXIS:
					var cid:AbstractInputGamepadAxisID = cast id;
					return getAction(gamepad_axis_ids.get(cid.key).actions[0]);
				default:
					
			}
		}catch(e:Dynamic){}
		return null;
	}
	
	/**
	 * Remove source from all actions
	 * 
	 * @param	id id of abstract input source
	 * @return nothing
	 */
	
	public function removeSource(id:AbstractInputID){
		switch(id.type){
			case KEY:
				var cid:AbstractInputKeyboardID = cast id;
				key_ids.remove(cid.key);
			case MOUSE:
				var cid:AbstractInputMouseID = cast id;
				mouse_ids.remove(cid.key);
			case GAMEPADKEY:
				var cid:AbstractInputGamepadKeyID = cast id;
				gamepad_key_ids.remove(cid.key);
			case GAMEPADAXIS:
				var cid:AbstractInputGamepadAxisID = cast id;
				gamepad_axis_ids.remove(cid.key);
			default:
				return;
		}
		ids.remove(id);
	}
	
	/**
	 * Get abstract sources of action
	 * 
	 * @param	name id of action
	 * @return array of abstract input source ids
	 */
	
	public function getSources(name:KeyType):Array<AbstractInputID>{
		var a:Array<AbstractInputID> = [];
		for (s in ids){
			if (s.actions.indexOf(name) >= 0)
			 a.push(s);
		}
		return a;
	}

	/**
	 * Remove sourses of action
	 * 
	 * @param	name id of action
	 * @return nothing
	 */
	public function clearSources(name:KeyType){
		var ss:Array<AbstractInputID> = getSources(name);
		for (s in ss){
			removeSource(s);
		}
	}

	/**
	 * remove all actions
	 * 
	 * @return nothing
	 */
	public function clear(){
		while (ids.length>0){
			removeSource(ids[0]);
		}				
	}

	private static var _axis_schema:Map<FlxGamepadInputID, Array<GamepadAxisID>> = [
		FlxGamepadInputID.LEFT_TRIGGER=> [LEFT_TRIGGER_PLUS, LEFT_TRIGGER_MINUS],
		FlxGamepadInputID.RIGHT_TRIGGER=> [RIGHT_TRIGGER_PLUS, RIGHT_TRIGGER_MINUS],
		FlxGamepadInputID.POINTER_X=> [POINTER_X_PLUS, POINTER_X_MINUS],
		FlxGamepadInputID.POINTER_Y=> [POINTER_Y_PLUS, POINTER_Y_MINUS]
	];

	private static var _axis_xy_schema:Map<FlxGamepadInputID, Array<GamepadAxisID>> = [
		FlxGamepadInputID.LEFT_ANALOG_STICK=> [LEFT_STICK_X_PLUS, LEFT_STICK_X_MINUS, LEFT_STICK_Y_PLUS, LEFT_STICK_Y_MINUS],
		FlxGamepadInputID.RIGHT_ANALOG_STICK=> [RIGHT_STICK_X_PLUS, RIGHT_STICK_X_MINUS, RIGHT_STICK_Y_PLUS, RIGHT_STICK_Y_MINUS]
	];


	/**
	 * Get first pressed source, forces to return null if source preset in cancel array
	 * example:
	 * AbstractInputManager.firstPressed([],[],[MouseID.MOUSE_LEFT],[],[],[],[],[]); //example
	 * 
	 * TRIGGERS don't work yet
	 * @param	keys_ignore ids of keyboard buttons that will be ignored, null for all
	 * @param	keys_cancel ids of keyboard buttons that will cancel checking, null for all
	 * @param	mouse_ignore ids of mouse buttons that will be ignored, null for all
	 * @param	mouse_cancel ids of mouse buttons that will cancel checking, null for all
	 * @param	gkeys_ignore ids of gamepad buttons that will be ignored, null for all
	 * @param	gkeys_cancel ids of gamepad buttons that will cancel checking, null for all
	 * @param	gaxis_ignore ids of gamepad axis that will be ignored, null for all
	 * @param	gaxis_cancel ids of gamepad axis that will cancel checking, null for all
	 * @param	any_gamepad if true, source key will be chaked on any gamepad in future, else only on what was pressed
	 * @param	treshhold treshhold of axis values to trigger
	 * 
	 * @return AbstractInputKeyboardID, AbstractInputMouseID, AbstractInputGamepadKeyID or AbstractInputGamepadAxisID
	 */
	public static function firstPressed(
		?keys_ignore:Array<FlxKey>, 
		?keys_cancel:Array<FlxKey>, 
		?mouse_ignore:Array<MouseID>, 
		?mouse_cancel:Array<MouseID>, 
		?gkeys_ignore:Array<FlxGamepadInputID>, 
		?gkeys_cancel:Array<FlxGamepadInputID>, 
		?gaxis_ignore:Array<GamepadAxisID>, 
		?gaxis_cancel:Array<GamepadAxisID>, 
		any_gamepad:Bool=true,
		treshhold:Float = 0.1
	):Null<AbstractInputID>{
	#if !FLX_NO_KEYBOARD
		if (keys_ignore != null){
			var key:FlxKey = FlxG.keys.firstJustPressed();
			if (keys_cancel==null || keys_cancel != null && keys_cancel.indexOf(key)!=-1)
				return null;
			if (key != FlxKey.NONE && key != FlxKey.ANY && keys_ignore.indexOf(key)==-1)
				return new AbstractInputKeyboardID(null, key);
		}
	#end
	#if !FLX_NO_MOUSE
		if (mouse_ignore != null){
			if (FlxG.mouse.justPressed){
				if (mouse_cancel == null || mouse_cancel != null && mouse_cancel.indexOf(MOUSE_LEFT) !=-1)
					return null;
				if (mouse_ignore.indexOf(MOUSE_LEFT)==-1)
					return new AbstractInputMouseID(null, MOUSE_LEFT);
			}
			if (FlxG.mouse.justPressedRight){
				if (mouse_cancel == null || mouse_cancel != null && mouse_cancel.indexOf(MOUSE_RIGHT) !=-1)
					return null;
				if (mouse_ignore.indexOf(MOUSE_RIGHT)==-1)
					return new AbstractInputMouseID(null, MOUSE_RIGHT);
			}
			if (FlxG.mouse.justPressedMiddle){
				if (mouse_cancel == null || mouse_cancel != null && mouse_cancel.indexOf(MOUSE_MIDDLE) !=-1)
					return null;
				if (mouse_ignore.indexOf(MOUSE_MIDDLE)==-1)
					return new AbstractInputMouseID(null, MOUSE_MIDDLE);
			}
			if (FlxG.mouse.wheel != 0){
				if (FlxG.mouse.wheel>0){
					if (mouse_cancel == null || mouse_cancel != null && mouse_cancel.indexOf(MOUSE_WEEL_UP) !=-1)
						return null;
					if (mouse_ignore.indexOf(MOUSE_WEEL_UP)==-1)
						return new AbstractInputMouseID(null, MOUSE_WEEL_UP);
				}else{
					if (mouse_cancel == null || mouse_cancel != null && mouse_cancel.indexOf(MOUSE_WEEL_DOWN) !=-1)
						return null;
					if (mouse_ignore.indexOf(MOUSE_WEEL_DOWN)==-1)
						return new AbstractInputMouseID(null, MOUSE_WEEL_DOWN);
				}
			}
		}
	#end
	#if !FLX_NO_GAMEPAD
		var gamepads:Array<FlxGamepad> = FlxG.gamepads.getActiveGamepads();
		for(gamepad in gamepads)
			if (gamepad != null){
				if (gkeys_ignore != null){
					var gkey:FlxGamepadInputID = gamepad.firstJustPressedID();
					if (gkeys_cancel != null && gkeys_cancel.indexOf(gkey)!=-1)
						return null;
					if (gkey != -1 && gkeys_ignore.indexOf(gkey)==-1)
						return new AbstractInputGamepadKeyID(null, gkey, any_gamepad?null:gamepad.id);
				}
				if (gaxis_ignore != null){
					var axis:Float;
					for (ai in [FlxGamepadInputID.POINTER_X, FlxGamepadInputID.POINTER_Y]){//, FlxGamepadInputID.LEFT_TRIGGER, FlxGamepadInputID.RIGHT_TRIGGER]){					
						var schema:Array<GamepadAxisID> = _axis_schema[ai];
						var axis:Float = gamepad.getAxis(ai);
						if (Math.abs(axis) > treshhold){
							if (axis>0){
								if (gaxis_cancel != null && gaxis_cancel.indexOf(schema[0])!=-1)
									return null;
								if (gaxis_ignore.indexOf(schema[0])==-1)
									return new AbstractInputGamepadAxisID(null, schema[0], any_gamepad?null:gamepad.id, treshhold);
							}else{
								if (gaxis_cancel != null && gaxis_cancel.indexOf(schema[1])!=-1)
									return null;
								if (gaxis_ignore.indexOf(schema[1])==-1)
									return new AbstractInputGamepadAxisID(null, schema[1], any_gamepad?null:gamepad.id, treshhold);
							}
						}
					}
					for (ai in [FlxGamepadInputID.LEFT_ANALOG_STICK, FlxGamepadInputID.RIGHT_ANALOG_STICK]){					
						var schema:Array<GamepadAxisID> = _axis_xy_schema[ai];
						var axis:Float = gamepad.getXAxis(ai);
						if (Math.abs(axis) > treshhold){
							if (axis>0){
								if (gaxis_cancel != null && gaxis_cancel.indexOf(schema[0])!=-1)
									return null;
								if (gaxis_ignore.indexOf(schema[0])==-1)
									return new AbstractInputGamepadAxisID(null, schema[0], any_gamepad?null:gamepad.id, treshhold);
							}else{
								if (gaxis_cancel != null && gaxis_cancel.indexOf(schema[1])!=-1)
									return null;
								if (gaxis_ignore.indexOf(schema[1])==-1)
									return new AbstractInputGamepadAxisID(null, schema[1], any_gamepad?null:gamepad.id, treshhold);
							}
						}
						axis = gamepad.getYAxis(ai);
						if (Math.abs(axis) > treshhold){
							if (axis>0){
								if (gaxis_cancel != null && gaxis_cancel.indexOf(schema[2])!=-1)
									return null;
								if (gaxis_ignore.indexOf(schema[2])==-1)
									return new AbstractInputGamepadAxisID(null, schema[2], any_gamepad?null:gamepad.id, treshhold);
							}else{
								if (gaxis_cancel != null && gaxis_cancel.indexOf(schema[3])!=-1)
									return null;
								if (gaxis_ignore.indexOf(schema[3])==-1)
									return new AbstractInputGamepadAxisID(null, schema[3], any_gamepad?null:gamepad.id, treshhold);
							}
						}
					}
				}
			}
	#end
		return null;
	}
}

////////////////////////////////////////////////////////////////

class AbstractInputAction{
	
	public var manager:AbstractInputManager;
	
	public var name:KeyType;
	public var justPressed:Bool;
	public var justReleased:Bool;
	public var pressed:Bool;
	public var value:Float;
	
	
	public function new(manager:AbstractInputManager, name:KeyType){
		this.manager = manager;
		this.name = name;
	}
	
	public function addKey(key:FlxKey){
		if (!manager.key_ids.exists(key)){
			manager.ids.push(manager.key_ids[key] = new AbstractInputKeyboardID(manager, key));
		}
		manager.key_ids[key].addAction(name);
	}

	public function removeKey(key:FlxKey){

		if (manager.key_ids.exists(key)){
			var key_id = manager.key_ids[key];
			key_id.removeAction(name);
			if (key_id.actions.length == 0)
				manager.ids.remove(key_id);
		}
	}
	
	public function addMouseKey(key:MouseID){
		if (!manager.mouse_ids.exists(key)){
			var action = new AbstractInputMouseID(manager, key);
			manager.mouse_ids.set(key, action);
			manager.ids.push(action);
		}
		manager.mouse_ids.get(key).addAction(name);
	}
	
	public function removeMouseKey(key:MouseID){
		if (manager.mouse_ids.exists(key)){
			var key_id = manager.mouse_ids.get(key);
			key_id.removeAction(name);
			if (key_id.actions.length == 0)
				manager.ids.remove(key_id);
		}
	}
	
	public function addGamepadKey(key:FlxGamepadInputID, ?id:Int){
		if (!manager.gamepad_key_ids.exists(key)){
			var action = new AbstractInputGamepadKeyID(manager, key, id);
			manager.gamepad_key_ids.set(key, action);
			manager.ids.push(action);
		}
		manager.gamepad_key_ids.get(key).addAction(name);
	}
	
	public function removeGamepadKey(key:FlxGamepadInputID){
		if (manager.gamepad_key_ids.exists(key)){
			var key_id = manager.gamepad_key_ids.get(key);
			key_id.removeAction(name);
			if (key_id.actions.length == 0)
				manager.ids.remove(key_id);
		}
	}
	
	public function addGamepadAxis(key:GamepadAxisID, ?id:Int){
		if (!manager.gamepad_axis_ids.exists(key)){
			var action = new AbstractInputGamepadAxisID(manager, key, id);
			manager.gamepad_axis_ids.set(key, action);
			manager.ids.push(action);
		}
		manager.gamepad_axis_ids.get(key).addAction(name);
	}
	
	public function removeGamepadAxis(key:GamepadAxisID){
		if (manager.gamepad_axis_ids.exists(key)){
			var key_id = manager.gamepad_axis_ids.get(key);
			key_id.removeAction(name);
			if (key_id.actions.length == 0)
				manager.ids.remove(key_id);
		}
	}
	
	public function addAbstractId(id:AbstractInputID){
		if (id.manager != null && id.manager != manager){
			trace("you must not use AbstractInputID from another manager");
			return;
		}
		switch(id.type){
			case KEY:
				var cid:AbstractInputKeyboardID = cast id;
				if (!manager.key_ids.exists(cid.key)){
					manager.key_ids.set(cid.key, cid);
				}
			case MOUSE:
				var cid:AbstractInputMouseID = cast id;
				if (!manager.mouse_ids.exists(cid.key)){
					manager.mouse_ids.set(cid.key, cid);
				}
			case GAMEPADKEY:
				var cid:AbstractInputGamepadKeyID = cast id;
				if (!manager.gamepad_key_ids.exists(cid.key)){
					manager.gamepad_key_ids.set(cid.key, cid);
				}
			case GAMEPADAXIS:
				var cid:AbstractInputGamepadAxisID = cast id;
				if (!manager.gamepad_axis_ids.exists(cid.key)){
					manager.gamepad_axis_ids.set(cid.key, cid);
				}
			default:
				return;
		}
		id.manager = manager;
		id.addAction(name);
		manager.ids.push(id);
	}
	
	public function removeAbstractId(id:AbstractInputID){
		switch(id.type){
			case KEY:
				var cid:AbstractInputKeyboardID = cast id;
				manager.key_ids.remove(cid.key);
				manager.ids.remove(id);
			case MOUSE:
				var cid:AbstractInputMouseID = cast id;
				manager.mouse_ids.remove(cid.key);
				manager.ids.remove(id);
			case GAMEPADKEY:
				var cid:AbstractInputGamepadKeyID = cast id;
				manager.gamepad_key_ids.remove(cid.key);
				manager.ids.remove(id);
			case GAMEPADAXIS:
				var cid:AbstractInputGamepadAxisID = cast id;
				manager.gamepad_axis_ids.remove(cid.key);
				manager.ids.remove(id);
			default:	
				return;
		}
	}
	
	public function assignFirstPressed(
		?keys_ignore:Array<FlxKey>, 
		?keys_cancel:Array<FlxKey>, 
		?mouse_ignore:Array<MouseID>, 
		?mouse_cancel:Array<MouseID>, 
		?gkeys_ignore:Array<FlxGamepadInputID>, 
		?gkeys_cancel:Array<FlxGamepadInputID>, 
		?gaxis_ignore:Array<GamepadAxisID>, 
		?gaxis_cancel:Array<GamepadAxisID>, 
		any_gamepad:Bool=true,
		treshhold:Float = 0.1
	):Null<AbstractInputID>{
		var key:Null<AbstractInputID> = AbstractInputManager.firstPressed(keys_ignore, keys_cancel, mouse_ignore, mouse_cancel, gkeys_ignore, gkeys_cancel, gaxis_ignore, gaxis_cancel, any_gamepad, treshhold);
		if (key != null)
			addAbstractId(key);
		return key;
	}
	
	public function clear(){
		var id = 0;
		while (id<manager.ids.length){
			if (manager.ids[id].actions.indexOf(name)!=-1){
				removeAbstractId(manager.ids[id]);
				id--;
			}	
			id++;
		}				
	}
	
}

////////////////////////////////////////////////////////////////
/**
 * Do not use directly
 */
class AbstractInputGamepadAxisID extends AbstractInputID{

	public var key:GamepadAxisID;
	public var gamepad_id:Null<Int> = null;
	private var _value:Float = 0;
	private var _treshhold:Float = 0;
	
	
	public function new(manager:Null<AbstractInputManager>, key:GamepadAxisID, ?id, treshhold=0.1){
		super(manager);
		this.key = key;
		this.gamepad_id = id;
		this.type = GAMEPADAXIS;
		_treshhold = treshhold;
	}
		
	override
	public function update(){
	#if !FLX_NO_GAMEPAD
		for (name in actions){
			var action = manager.actions[name];
			if (gamepad_id==null){
				var gamepads = FlxG.gamepads.getActiveGamepads();
				for (gamepad in gamepads){
					proceedGamepad(gamepad, action);
				}
			}else{
				var gamepad = FlxG.gamepads.getByID(gamepad_id);
				if (gamepad != null){ 
					proceedGamepad(gamepad, action);
				}
			}
		}
	#end
	}	
#if !FLX_NO_GAMEPAD
	private function proceedGamepad(gamepad:FlxGamepad, action:AbstractInputAction){
		switch(key){
			case LEFT_STICK_X_PLUS:
				var value = gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case LEFT_STICK_X_MINUS:
				var value = gamepad.getXAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case LEFT_STICK_Y_PLUS:
				var value = gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case LEFT_STICK_Y_MINUS:
				var value = gamepad.getYAxis(FlxGamepadInputID.LEFT_ANALOG_STICK);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case RIGHT_STICK_X_PLUS:
				var value = gamepad.getXAxis(FlxGamepadInputID.RIGHT_ANALOG_STICK);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case RIGHT_STICK_X_MINUS:
				var value = gamepad.getXAxis(FlxGamepadInputID.RIGHT_ANALOG_STICK);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case RIGHT_STICK_Y_PLUS:
				var value = gamepad.getYAxis(FlxGamepadInputID.RIGHT_ANALOG_STICK);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case RIGHT_STICK_Y_MINUS:
				var value = gamepad.getYAxis(FlxGamepadInputID.RIGHT_ANALOG_STICK);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case LEFT_TRIGGER_PLUS:
				
				var value = gamepad.getAxis(FlxGamepadInputID.LEFT_TRIGGER);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case LEFT_TRIGGER_MINUS:
				var value = gamepad.getAxis(FlxGamepadInputID.LEFT_TRIGGER);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case RIGHT_TRIGGER_PLUS:
				var value = gamepad.getAxis(FlxGamepadInputID.RIGHT_TRIGGER);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case RIGHT_TRIGGER_MINUS:
				var value = gamepad.getAxis(FlxGamepadInputID.RIGHT_TRIGGER);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case POINTER_X_PLUS:
				var value = gamepad.getAxis(FlxGamepadInputID.POINTER_X);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case POINTER_X_MINUS:
				var value = gamepad.getAxis(FlxGamepadInputID.POINTER_X);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case POINTER_Y_PLUS:
				var value = gamepad.getAxis(FlxGamepadInputID.POINTER_Y);
				if (value > _treshhold && value > action.value){
					action.pressed = true;
					action.value = value;
				}
			case POINTER_Y_MINUS:
				var value = gamepad.getAxis(FlxGamepadInputID.POINTER_Y);
				if (value < -_treshhold && -value > action.value){
					action.pressed = true;
					action.value = -value;
				}
			case NONE:
		}
		if (_value != action.value){
			if (action.value < _treshhold){
				action.justReleased = true;
			}
			action.justPressed = true; //value has been changed
			_value = action.value;
		}
	}
#end	
	override
	public function toString():String{
		return key.toString();
	}

}

////////////////////////////////////////////////////////////////

class AbstractInputGamepadKeyID extends AbstractInputID{
	
	public var key:FlxGamepadInputID;
	public var gamepad_id:Null<Int> = null;

	public function new(manager:Null<AbstractInputManager>, key:FlxGamepadInputID, ?id:Int){
		super(manager);
		this.key = key;
		this.gamepad_id = id;
		this.type = GAMEPADKEY;
	}
	
	override
	public function update(){
	#if !FLX_NO_GAMEPAD
		for (name in actions){
			var action = manager.actions[name];
			if (gamepad_id==null){
				action.justPressed = action.justPressed || FlxG.gamepads.anyJustPressed(key);
				action.justReleased = action.justReleased || FlxG.gamepads.anyJustReleased(key);
				action.pressed = action.pressed || FlxG.gamepads.anyPressed(key);
			}else{
				var gamepad = FlxG.gamepads.getByID(gamepad_id);
				if (gamepad != null){
					action.justPressed = action.justPressed || gamepad.anyJustPressed([key]);
					action.justReleased = action.justReleased || gamepad.anyJustReleased([key]);
					action.pressed = action.pressed || gamepad.anyPressed([key]);
				}
			}
			if (action.justPressed || action.pressed)
				action.value = 1;
			if (action.justReleased)//TODO:check
				action.value = 0;
		}
	#end
	}
	
	override
	public function toString():String{
		return "GAMEPAD_"+key.toString();
	}

}

////////////////////////////////////////////////////////////////

class AbstractInputMouseID extends AbstractInputID{
	
	public var key:MouseID;
	
	public function new(manager:Null<AbstractInputManager>, key:MouseID){
		super(manager);
		this.key = key;
		this.type = MOUSE;
	}
	
	override
	public function update(){
	#if !FLX_NO_MOUSE
		for (name in actions){
			var action = manager.actions[name];
			switch(key){
				case MOUSE_LEFT:
					action.justPressed = action.justPressed || FlxG.mouse.justPressed;
					action.justReleased = action.justReleased || FlxG.mouse.justReleased;
					action.pressed = action.pressed || FlxG.mouse.pressed;
				case MOUSE_RIGHT:
					action.justPressed = action.justPressed || FlxG.mouse.justPressedRight;
					action.justReleased = action.justReleased || FlxG.mouse.justReleasedRight;
					action.pressed = action.pressed || FlxG.mouse.pressedRight;
				case MOUSE_MIDDLE:
					action.justPressed = action.justPressed || FlxG.mouse.justPressedMiddle;
					action.justReleased = action.justReleased || FlxG.mouse.justReleasedMiddle;
					action.pressed = action.pressed || FlxG.mouse.pressedMiddle;
				case MOUSE_WEEL_UP: 
					if (FlxG.mouse.wheel > 0 && FlxG.mouse.wheel > action.value){
						action.justPressed = true;
						action.value = FlxG.mouse.wheel;
					}
				case MOUSE_WEEL_DOWN: 
					if (FlxG.mouse.wheel < 0 && -FlxG.mouse.wheel > action.value){
						action.justPressed = true;
						action.value = -FlxG.mouse.wheel;
					}
				case NONE:
			}
			if (action.justPressed || action.pressed)
				action.value = 1;
			if (action.justReleased)//TODO:check
				action.value = 0;
		}
	#end
	} 

	override
	public function toString():String{
		return key.toString();
	}

}

////////////////////////////////////////////////////////////////

class AbstractInputKeyboardID extends AbstractInputID{

	public var key:FlxKey;
	
	public function new(manager:Null<AbstractInputManager>, key:FlxKey){
		super(manager);
		this.key = key;
		this.type = KEY;
	}
	
	override
	public function update(){
	#if !FLX_NO_KEYBOARD
		for (name in actions){
			var action = manager.actions[name];
			action.justPressed = action.justPressed || FlxG.keys.anyJustPressed([key]);
			action.justReleased = action.justReleased || FlxG.keys.anyJustReleased([key]);
			action.pressed = action.pressed || FlxG.keys.anyPressed([key]);
			if (action.justPressed || action.pressed)
				action.value = 1;
			if (action.justReleased)
				action.value = 0;
		}
	#end
	}
	
	override
	public function toString():String{
		return key.toString();
	}

}

////////////////////////////////////////////////////////////////

class AbstractInputID{
	
	public var type:AbstractSource;
	
	public var actions:Array<KeyType>=[];
	public var manager:Null<AbstractInputManager>;

	public function new(manager:Null<AbstractInputManager>){
		this.manager = manager;
	}
	
	public function update(){
		trace("base update");
	}
	
	public function addAction(name:KeyType){
		if (actions.indexOf(name) < 0){
			if (actions.length > 0){
				actions[0] = name; //only 1 action for 1 input
			}else{
				actions.push(name);
			}
		}
	}

	public function removeAction(name:KeyType):Bool{
		return actions.remove(name);
	}
	
	public function toString():String{
		return "";
	}

}

@:enum
abstract GamepadAxisID(Int) from Int to Int{
	public static var fromStringMap(default, null):Map<String, GamepadAxisID>
		= FlxMacroUtil.buildMap("AbstractInputManager.GamepadAxisID");
		
	public static var toStringMap(default, null):Map<GamepadAxisID, String>
		= FlxMacroUtil.buildMap("AbstractInputManager.GamepadAxisID", true);
		
	var NONE = -1;
	var LEFT_STICK_X_PLUS = 0;
	var LEFT_STICK_X_MINUS = 1;
	var LEFT_STICK_Y_PLUS = 2;
	var LEFT_STICK_Y_MINUS = 3;
	var LEFT_TRIGGER_PLUS = 4;
	var LEFT_TRIGGER_MINUS = 5;
	var RIGHT_STICK_X_PLUS = 6;
	var RIGHT_STICK_X_MINUS = 7;
	var RIGHT_STICK_Y_PLUS = 8;
	var RIGHT_STICK_Y_MINUS = 9;
	var RIGHT_TRIGGER_PLUS = 10;
	var RIGHT_TRIGGER_MINUS = 11;
	var POINTER_X_PLUS = 12;
	var POINTER_X_MINUS = 13;
	var POINTER_Y_PLUS = 14;
	var POINTER_Y_MINUS = 15;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}
	
	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}

@:enum
abstract MouseID(Int) from Int to Int{
	public static var fromStringMap(default, null):Map<String, MouseID>
		= FlxMacroUtil.buildMap("AbstractInputManager.MouseID");
		
	public static var toStringMap(default, null):Map<MouseID, String>
		= FlxMacroUtil.buildMap("AbstractInputManager.MouseID", true);

	var NONE = -1;	
	var MOUSE_LEFT = 0;
	var MOUSE_RIGHT = 1;
	var MOUSE_MIDDLE = 2;
	var MOUSE_WEEL_UP = 3;
	var MOUSE_WEEL_DOWN = 4;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}
	
	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}

enum AbstractSource{
	KEY;
	MOUSE;
	GAMEPADKEY;
	GAMEPADAXIS;
}



//enum for bindings
@:enum
abstract AbstractActionID(Int) from Int to Int{
	public static var fromStringMap(default, null):Map<String, AbstractActionID>
		= FlxMacroUtil.buildMap("AbstractInputManager.AbstractActionID");
		
	public static var toStringMap(default, null):Map<AbstractActionID, String>
		= FlxMacroUtil.buildMap("AbstractInputManager.AbstractActionID", true);

	var NONE = -1;	
	var GO_UP = 1;
	var GO_DOWN = 2;
	var GO_LEFT = 3;
	var GO_RIGHT = 4;
	var ATTACK = 5;
	var GRENAGE = 6;
	var FLASHLIGHT = 7;
	var JUMP = 8;
	var NEXT_W = 9;
	var PREV_W = 10;
	var SLOT_1 = 11;
	var SLOT_2 = 12;
	var SLOT_3 = 13;
	var SLOT_4 = 14;
	var SLOT_5 = 15;
	var SLOT_6 = 16;
	var SLOT_7 = 17;
	var SLOT_8 = 18;
	var SLOT_9 = 19;
	var USE = 20;
	var USE_ITEM = 21;
	var NEXT_ITEM = 22;
	var PREV_ITEM = 23;
	
	
	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}
	
	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}	
		
}

/* example basic usage
 * 
	//in create
	var actions:AbstractInputManager = new AbstractInputManager();
	var a = actions.addAction(GO_UP);
	a.addKey(FlxKey.W);
	a.addKey(FlxKey.UP);
	a.addGamepadAxis(GamepadAxisID.LEFT_STICK_Y_MINUS);
	a=actions.addAction(GO_DOWN);
	a.addKey(FlxKey.S);
	a.addKey(FlxKey.DOWN);
	a.addGamepadAxis(GamepadAxisID.LEFT_STICK_Y_PLUS);
	a=actions.addAction(GO_LEFT);
	a.addKey(FlxKey.A);
	a.addKey(FlxKey.LEFT);
	a.addGamepadAxis(GamepadAxisID.LEFT_STICK_X_MINUS);
	a=actions.addAction(GO_RIGHT);
	a.addKey(FlxKey.D);
	a.addKey(FlxKey.RIGHT);
	a.addGamepadAxis(GamepadAxisID.LEFT_STICK_X_PLUS);
	a=actions.addAction(ATTACK);
	a.addMouseKey(MouseID.MOUSE_LEFT);
	a.addMouseKey(FlxGamepadInputID.A);
	
	///in update 	
	actions.update();
	if (actions.anyChanged([GO_UP, GO_DOWN, GO_LEFT, GO_RIGHT])){
		//some actions on actions.value(GO_RIGHT) ==1 or other
	}
  
 * */


