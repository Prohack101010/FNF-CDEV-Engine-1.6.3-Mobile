package meta.states;

import game.cdev.log.GameLog;
import flixel.FlxCamera;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.BaseScaleMode;
import openfl.display.StageScaleMode;
import lime.app.Application;
import openfl.display.Window;
import game.Conductor;
import openfl.Lib;
import flixel.FlxSprite;
import game.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = -1;
	private var curBeat:Int = -1;
	public var controls(get, never):game.Controls;

	// my attempt of preventing repeating beats
	var _highestPassedBeats:Int = -1;
	var passedBeats:Array<Int> = [];
	var _highestPassedSteps:Int = -1;
	var passedSteps:Array<Int> = [];
	var syncingSensitivity:Int = 2;

	inline function get_controls():game.Controls
		return game.cdev.engineutils.PlayerSettings.player1.controls;

	public var mobilePad:MobilePad;
	public var mobilePadCam:FlxCamera;
	public var hitbox:Hitbox;
	public var hitbox_hint:FlxSprite;
	public var hitboxCam:FlxCamera;
	public var mobileBackButton:BackButton;

	public function addBackButton(?xPos:Float = 0, ?yPos:Float = 0, ?color:FlxColor = FlxColor.WHITE, ?confirmCallback:Void->Void = null,
			?restOpacity:Float = 0.3, ?instant:Bool = false):Void
	{
		if (mobileBackButton != null) remove(mobileBackButton);

		if (mobilePadCam == null)
		{
			mobilePadCam = new FlxCamera();
			mobilePadCam.bgColor.alpha = 0;
			FlxG.cameras.add(mobilePadCam, false);
		}

		mobileBackButton = new BackButton(xPos, yPos, color, confirmCallback, restOpacity, instant);
		mobileBackButton.cameras = [mobilePadCam];
		add(mobileBackButton);
	}

	public function addMobilePad(DPad:String, Action:String)
	{
		mobilePad = new MobilePad(DPad, Action);
		add(mobilePad);
	}

	public function removeMobilePad()
	{
		if (mobilePad != null)
		{
			remove(mobilePad);
			mobilePad = FlxDestroyUtil.destroy(mobilePad);
		}

		if(mobilePadCam != null)
		{
			FlxG.cameras.remove(mobilePadCam);
			mobilePadCam = FlxDestroyUtil.destroy(mobilePadCam);
		}
	}

	public function addMobileControls(?mode:String, defaultDrawTarget:Bool = false) {
		if (mode != null || mode != "NONE") hitbox = new Hitbox(mode);
		else hitbox = new Hitbox();

		hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, defaultDrawTarget);
		hitbox.cameras = [hitboxCam];

		if (CDevConfig.saveData.hitboxhint) {
			hitbox_hint = new FlxSprite(0, (CDevConfig.saveData.hitboxLocation == 'Bottom' && CDevConfig.saveData.extraKeys != 0) ? -150 : 0);
			hitbox_hint.loadGraphic(Paths.image('mobile/Hitbox/hitbox_hint', null, true));
			add(hitbox_hint);
			hitbox_hint.cameras = [hitboxCam];
		}

		add(hitbox);
	}

	public function removeMobileControls()
	{
		if (hitbox != null)
		{
			remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}

		if (hitbox_hint != null)
		{
			remove(hitbox_hint);
			hitbox_hint = FlxDestroyUtil.destroy(hitbox_hint);
			hitbox_hint = null;
		}

		if (hitboxCam != null)
		{
			FlxG.cameras.remove(hitboxCam);
			hitboxCam = FlxDestroyUtil.destroy(hitboxCam);
		}
	}

	public function addMobilePadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (mobilePad != null)
		{
			mobilePadCam = new FlxCamera();
			mobilePadCam.bgColor.alpha = 0;
			FlxG.cameras.add(mobilePadCam, defaultDrawTarget);
			mobilePad.cameras = [mobilePadCam];
		}
	}

	override function destroy()
	{
		removeMobilePad();
		removeMobileControls();
		
		super.destroy();
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	override function create()
	{
		//if (transIn != null)
		//	trace('reg ' + transIn.region);

		super.create();
	}

	override function onResize(width:Int, height:Int)
	{
		super.onResize(width, height);
		//FlxG.resizeGame(Application.current.window.width, Application.current.window.height);
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

		//this is awfully ass
		if (Math.abs(curStep - _highestPassedSteps) >= syncingSensitivity){
			if (CDevConfig.saveData.testMode) GameLog.warn("Game desynced! Trying to sync the _highestPassedSteps with curStep...");
			_highestPassedSteps = curStep;
			passedSteps = [];
			for (i in 0..._highestPassedSteps){
				passedSteps[i] = i;
			}
			if (CDevConfig.saveData.testMode) GameLog.warn("Game synced, current values: "  + curStep + " // " + _highestPassedSteps +".");
		}
		super.update(elapsed);
	}

	override function onFocus() {
		super.onFocus();
		CDevConfig.setFPS(CDevConfig.saveData.fpscap);
	}

	private function updateBeat():Void
	{
		var newBeats:Int = Math.floor(curStep / 4);
		if (!passedBeats.contains(newBeats)){
			curBeat = newBeats;
			passedBeats.push(newBeats);
			_highestPassedBeats = getLargerInt(passedBeats);
		}
	}

	function getLargerInt(array:Array<Int>):Int {
		var get:Int = -1000;
		for (i in array){
			if (i > get){
				get = i;
			}
		}
		return get;
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition + Conductor.offset >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}
		var newSteps:Int = lastChange.stepTime + Math.floor((Conductor.songPosition + Conductor.offset - lastChange.songTime) / Conductor.stepCrochet);
		if (!passedSteps.contains(newSteps)){
			curStep = newSteps;
			passedSteps.push(newSteps);
			_highestPassedSteps = getLargerInt(passedSteps);
		}
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
