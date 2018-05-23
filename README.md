# flixel-abstractinput

Small library for HaxeFlixel provides another abstraction layer which allows user to **group different input, such as keyboard, mouse and gamepad (axis and buttons) in several abstract actions**, and then check them. 
Actions use Int numbers as ids or names.
For every action you can bind standart input source, for axample keys of keyboard or axis of gamepad, **as more as you need**, but every source can be used **only once**.

Input source can be:
- keyboard keys (FlxKey)
- mouse keys (MouseID)
- gamepad keys (FlxGamepadInputID)
- gamepad axis (GamepadAxisID)

## Actions
Action has standart updateble vars 
- justPressed:Bool
- justReleased:Bool
- pressed:Bool

and the unified 
- value:Float 

**value** can be from 0 to 1 depends on input type. For buttons it can be 0 or 1, for axis it can be 0..1. 

Axis sources are devided for positive and negative directions, bacause of value of **value**.

## Basic usage Example
```haxe
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
	if (actions.anyChanged([GO_UP, GO_DOWN, GO_LEFT, GO_RIGHT])){//check if any of GO_UP, GO_DOWN, GO_LEFT, GO_RIGHT was changed
		if (actions.value(GO_RIGHT) == 1){ 
      //key GO_RIGHT is pressed
    }
 		if (actions.value(GO_LEFT) == 0){ 
      //key GO_LEFT is not pressed
    }

    //if we need to do smth on change in any of this actions
	}
  ```
  
  ## Custom Action ids
  
  You can create your custom enum class for action ids or use Int numbers directly
  
  Code of standart AbstractActionID enum class:
  
 ```haxe 
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
```

**Find issue or have questions?**

**Fill free to contact me.**
