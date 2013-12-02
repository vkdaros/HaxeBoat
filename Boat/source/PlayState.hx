package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxMath;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.TweenOptions;


/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState {
    private var background: FlxSprite;
    private var boat: Sprite;
    private var submarine: Sprite;
    private var debugText: FlxText;

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

        background = new FlxSprite(0, 0, 'assets/images/background.png');
        add(background);

        boat = new Sprite(0, 207, 'assets/images/boat.png');
        boat.setAnchor(boat.width/2, boat.height);
        boat.drag.x = 20;
        boat.maxVelocity.x = 100;
        add(boat);

        submarine = new Sprite(800, 400);
        //loadGraphic(image, animated, reversible, width, height)
        submarine.loadGraphic('assets/images/submarine.png', false, true);
        submarine.setAnchor(submarine.width / 2, submarine.height / 2);
        add(submarine);

        var options: TweenOptions;
        options = {
            type: FlxTween.PINGPONG,
            //ease: FlxEase.cubeIn
        };
        var tween: FlxTween;
        tween = FlxTween.linearMotion(submarine, submarine.x, submarine.y,
                                      0, submarine.y, 5.0,
                                      true, options);

        var text: FlxText;
        text = new FlxText(0, 0, 600,
                           "PlayState - Press ESC to comeback to menu.");
        text.size = 30;
        add(text);

        debugText = new FlxText(0, 200, 600,
                                "x: " + boat.x + " y: " + boat.y);
        debugText.size = 30;
        add(debugText);

		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage
     * collection.
	 */
	override public function destroy(): Void {
        background.destroy();
        background = null;

        boat.destroy();
        boat = null;

        submarine.destroy();
        submarine = null;

		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(): Void {
        var speed: Float = 5;
        var dt: Float = FlxG.elapsed;

        if (FlxG.keyboard.justReleased("ESCAPE")) {
            FlxG.switchState(new MenuState());
        }

        debugText.text = "x: " + boat.x + " y: " + boat.y;

        var BOAT_ACCELERATION: Int;
        BOAT_ACCELERATION = 100;
        boat.acceleration.x = 0;
        if (FlxG.keyboard.pressed("LEFT")) {
            boat.acceleration.x = -BOAT_ACCELERATION;
        }
        if (FlxG.keyboard.pressed("RIGHT")) {
            boat.acceleration.x = BOAT_ACCELERATION;
        }

        for (touch in FlxG.touches.list) {
            if (touch.pressed) {
                var margin: Float;
                margin = 0.2;
                if (touch.x < FlxG.width * margin) {
                    boat.acceleration.x = -BOAT_ACCELERATION;
                }
                else if (touch.x > FlxG.width * (1 - margin)) {
                    boat.acceleration.x = BOAT_ACCELERATION;
                }
            }
        }

		super.update();
	}
}
