package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends State {
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create(): Void {
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;

        var text: FlxText = new FlxText(50, 200, 600, "MenuState\nPress space to begin!");
        text.color = 0xFFFFFF;
        text.size = 40;
        add(text);

		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy(): Void {
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(): Void	{
        if (FlxG.keyboard.justReleased("SPACE")) {
            switchState(new PlayState());
        }

        if (FlxG.keyboard.justReleased("SPACE")) {
            switchState(new PlayState());
        }

        for (touch in FlxG.touches.list) {
            if (touch.justPressed) {
                switchState(new PlayState());
            }
        }

		super.update();
	}
}
