package;

import flash.Lib;
import flixel.FlxGame;

class GameClass extends FlxGame
{
    public function new() {
        var stageWidth: Int = Lib.current.stage.stageWidth;
        var stageHeight: Int = Lib.current.stage.stageHeight;

        var ratioX: Float = stageWidth / 480;
        var ratioY: Float = stageHeight / 320;
        var ratio: Float = Math.min(ratioX, ratioY);

        var fps: Int = 60;

        super(480, 320, MenuState, 1, fps, fps);
    }
}
