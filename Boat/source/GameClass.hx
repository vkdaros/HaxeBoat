package;

import flash.Lib;
import flixel.FlxGame;

class GameClass extends FlxGame
{
    public function new() {
        var stageWidth: Int = Lib.current.stage.stageWidth;
        var stageHeight: Int = Lib.current.stage.stageHeight;

        var ratioX: Float = stageWidth / 960;
        var ratioY: Float = stageHeight / 640;
        var ratio: Float = Math.min(ratioX, ratioY);

        var fps: Int = 60;

        super(960, 640, MenuState, ratio, fps, fps);
    }
}
