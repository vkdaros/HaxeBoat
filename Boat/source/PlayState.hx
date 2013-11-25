package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState {
    private var boat: FlxSprite;

	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create(): Void {
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

        boat = new FlxSprite(200, 100, 'assets/images/boat.png');
        add(boat);
        add(new FlxText(0,0,100,"PlayState - Press ESC to comeback to menu."));

		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage
     * collection.
	 */
	override public function destroy(): Void {
        boat.destroy();
        boat = null;

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(): Void {
        if (FlxG.keyboard.justReleased("ESCAPE")) {
            FlxG.switchState(new MenuState());
        }

        if (FlxG.keyboard.pressed("LEFT")) {
            boat.x--;
        }
        if (FlxG.keyboard.pressed("RIGHT")) {
            boat.x++;
        }

        for (touch in FlxG.touches.list) {
            if (touch.pressed) {
                var margin: Float;
                margin = 0.2;
                if (touch.x < FlxG.width * margin) {
                    boat.x--;
                }
                else if (touch.x > FlxG.width * (1 - margin)) {
                    boat.x++;
                }
            }
        }

		super.update();
	}
}
