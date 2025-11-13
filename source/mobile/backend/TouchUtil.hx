package mobile.backend;

import flixel.FlxObject;
import flixel.input.touch.FlxTouch;
import flixel.FlxBasic;

class TouchUtil {
	public static var pressed(get, never):Bool;
	public static var justPressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var touch(get, never):FlxTouch;
	public static var ticksDeltaSincePress(get, never):Int; //Taken from Funkin' Flixel

	private static function get_ticksDeltaSincePress()
		return FlxG.game.ticks - TouchUtil.touch.justPressedTimeInTicks;

	public static function overlaps(object:FlxObject, ?camera:FlxCamera):Bool {
		for (touch in FlxG.touches.list)
			if (touch.overlaps(object, camera ?? object.camera))
				return true;

		return false;
	}

	public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool {
		if (camera == null)
			for (camera in object.cameras)
				for (touch in FlxG.touches.list)
					@:privateAccess
					if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
						return true;
					else
						@:privateAccess
						if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
							return true;

		return false;
	}

	/**
	 * A helper function to check if the selection is pressed using touch.
	 *
	 * @param object The optional FlxBasic to check for overlap.
	 * @param camera Optional camera for the overlap check. Defaults to all cameras of the object.
	 * @param useOverlapsComplex If true and atleast the object is not null, the function will use complex overlaps method.
	 */
	public static function pressAction(?object:FlxObject, ?camera:FlxCamera, useOverlapsComplex:Bool = true):Bool
	{
		if (TouchUtil.touch == null || (TouchUtil.touch != null && TouchUtil.ticksDeltaSincePress > 200)) return false;

		if (object == null && camera == null)
		{
			return justReleased;
		}
		else if (object != null)
		{
			final overlapsObject:Bool = useOverlapsComplex ? overlapsComplex(cast(object, FlxObject), camera) : overlaps(object, camera);
			return justReleased && overlapsObject;
		}

		return false;
	}

	@:noCompletion
	private static function get_pressed():Bool {
		for (touch in FlxG.touches.list)
			if (touch.pressed)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_justPressed():Bool {
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_justReleased():Bool {
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_released():Bool {
		for (touch in FlxG.touches.list)
			if (touch.released)
				return true;

		return false;
	}

	@:noCompletion
	private static function get_touch():FlxTouch {
		for (touch in FlxG.touches.list)
			if (touch != null)
				return touch;

		return FlxG.touches.getFirst();
	}
}