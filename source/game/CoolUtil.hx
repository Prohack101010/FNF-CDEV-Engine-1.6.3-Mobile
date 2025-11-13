package game;

import lime.utils.Assets;
import flixel.util.FlxSave;

using StringTools;

#if cpp
@:cppFileCode('#include <thread>')
#end
class CoolUtil
{
	public static var defaultDifficulties:Array<String> = ['easy', 'normal+', 'hard']; //dumb
	public static var songDifficulties:Array<String> = [];
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL+", "HARD"];
	public static var diffFormat:Array<String> = ['-easy', '', '-hard'];

	public static function difficultyString():String
	{
		return difficultyArray[meta.states.PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		#if sys
		var formatted:Array<String> = path.split(':');
		path = formatted[formatted.length-1];
		if(FileSystem.exists(path)) daList = File.getContent(path);
		else #end if(Assets.exists(path)) daList = Assets.getText(path);

		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	inline public static function getSavePath(folder:String = 'ShadowMario'):String {
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}

	public static function showPopUp(message:String, title:String):Void
	{
		#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else
		FlxG.stage.window.alert(message, title);
		#end
	}

	#if cpp
	@:functionCode('
		return std::thread::hardware_concurrency();
	')
	#end
	public static function getCPUThreadsCount():Int
	{
		return 1;
	}
}
