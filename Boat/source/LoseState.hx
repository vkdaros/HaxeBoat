package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class LoseState extends State {
    private var text: FlxText;

	override public function create(): Void {
		FlxG.cameras.bgColor = 0xff131c1b;
        text = new FlxText(FlxG.width / 2 - 140, FlxG.height/2 - 40, 280,
                           "Game Over");
        text.color = 0xff8888;
        text.size = 40;
        add(text);

		super.create();
	}

	override public function destroy(): Void {
        text.destroy();
        text = null;

		super.destroy();
	}

	override public function update(): Void {
        if (FlxG.keyboard.justPressed("SPACE")) {
            switchState(new PlayState());
        }

        for (touch in FlxG.touches.list) {
            if (touch.pressed) {
                switchState(new PlayState());
            }
        }

		super.update();
	}
}
