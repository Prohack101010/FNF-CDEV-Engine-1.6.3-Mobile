package meta.substates;

import openfl.Lib;
import game.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import game.Conductor;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):game.Controls;

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
		//controls.isInSubstate = false;
		removeMobilePad();
		removeMobileControls();

		super.destroy();
	}

	public static function getSubState():MusicBeatSubstate {
		var curSubState:Dynamic = FlxG.state.subState;
		var leState:MusicBeatSubstate = curSubState;
		return leState;
	}

	//Gets the secondary substate (FlxG.state.subState.subState)
	public static function getExtraSubState():MusicBeatSubstate {
		if (FlxG.state.subState != null) {
			if (FlxG.state.subState.subState != null) {
				var curSubState:Dynamic = FlxG.state.subState.subState;
				var leState:MusicBeatSubstate = curSubState;
				return leState;
			}
			else
				return null;
		}
		else
			return null;
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

		super.update(elapsed);
	}

	override function onFocus()
	{
		super.onFocus();
		CDevConfig.setFPS(CDevConfig.saveData.fpscap);
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
			if (Conductor.songPosition + CDevConfig.saveData.offset >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition + CDevConfig.saveData.offset - lastChange.songTime) / Conductor.stepCrochet);
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
