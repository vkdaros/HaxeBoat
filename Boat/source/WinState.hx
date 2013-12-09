package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class WinState extends FlxState {
    private var text: FlxText;

	override public function create(): Void {
		FlxG.cameras.bgColor = 0xff131c1b;
        text = new FlxText(FlxG.width / 2 - 110, FlxG.height/2 - 40, 220,
                           "You WIN!");
        text.alignment = 'center';
        text.color = 0x88ff88;
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
            FlxG.switchState(new PlayState());
        }

        for (touch in FlxG.touches.list) {
            if (touch.pressed) {
                FlxG.switchState(new PlayState());
            }
        }

		super.update();
	}
}
