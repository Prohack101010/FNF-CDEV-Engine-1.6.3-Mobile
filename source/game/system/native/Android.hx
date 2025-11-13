package game.system.native;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.input.touch.FlxTouch;
#if android
import android.Permissions;
import android.os.Build;
import android.os.Environment;
import android.widget.Toast;
#end
import flash.system.System;
import openfl.Lib;
#if (sys && !ios)
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
 * Helper class for Android targets.
 */
class Android
{
    /**
     * Returns FlxTouch, shortcut to `FlxG.touches.getFirst()`.
     * @return FlxTouch
     */
    public static function touch():FlxTouch {
        return (FlxG.touches.getFirst());
    }

    /**
     * Touch checker for `spr`, then runs `onTouch` function
     * @param spr       Sprite that will be checked
     * @param onTouch   Function that will be runned if Touch = true
     */
    public static function touchJustPressed(spr:FlxSprite, onTouch:Void -> Void) {
        if (Android.touch()!=null){
            var sprPos = spr.getScreenPosition(FlxG.camera);
            var touchX = Android.touch().screenX;
            var touchY = Android.touch().screenY;
            var overlap:Bool = (touchX >= sprPos.x && touchX <= sprPos.x + spr.frameWidth
            && touchY >= sprPos.y && touchY <= sprPos.y + spr.frameHeight);
            if (overlap && Android.touch().justPressed){
                onTouch();
            }
        }
    }

    /**
     * Creates a toast text.
     * @param text Message that will be shown.
     */
    public static function toast(text:String){
        #if android
        Toast.makeText(text, Toast.LENGTH_LONG);
        #end
    }
}