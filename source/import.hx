#if !macro
import game.Paths;
import game.cdev.CDevConfig;

// Flixel //
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.FlxSubState;
import flixel.FlxObject;
//import shaders.flixel.system.FlxShader;
import haxe.ds.StringMap;

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

// Mobile Controls //
import mobile.objects.Hitbox;
import mobile.objects.MobilePad;
import mobile.objects.MobileButton;
import mobile.objects.BackButton; //Touch Shit
import mobile.objects.SpriteButton; //Button with Sprite lol
import mobile.input.MobileInputID;
import mobile.backend.MobileData;
import mobile.input.MobileInputManager;
import mobile.backend.TouchUtil;
import mobile.backend.PsychJNI;
import mobile.backend.TouchFunctions;
import mobile.backend.StorageUtil;
import mobile.states.CopyState;
//import mobile.substates.MobileExtraControl;

import meta.states.PlayState;
import meta.states.MusicBeatState;
import meta.substates.MusicBeatSubstate;

// Android //
#if android
import android.callback.CallBack as AndroidCallBack;
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
#end

using StringTools;
#end