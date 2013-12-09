package;

import flash.Lib;
import flixel.FlxGame;
import flixel.FlxG;

class GameClass extends FlxGame
{
    public function new() {
        var stageWidth: Int = Lib.current.stage.stageWidth;
        var stageHeight: Int = Lib.current.stage.stageHeight;

        var ratioX: Float = stageWidth / 960;
        var ratioY: Float = stageHeight / 640;
        var ratio: Float = Math.min(ratioX, ratioY);

        var fps: Int = 30;

        #if !FLX_NO_DEBUG
        FlxG.debugger.visualDebug = true;
        #end
        super(960, 640, MenuState, ratio, fps, fps, true);
    }
}
