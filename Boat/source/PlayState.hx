package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.animation.FlxAnimationController;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState {
    private var background: FlxSprite;
    private var boat: Sprite;
    private var submarines: FlxGroup;
    private var debugText: FlxText;
    private var barrels: FlxGroup;
    private var explosions: FlxGroup;
    private var bombs: FlxGroup;

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

        // add background
        background = new FlxSprite(0, 0, 'assets/images/background.png');
        add(background);

        // setup boat
        boat = new Sprite(0, 207, 'assets/images/boat.png');
        boat.setAnchor(boat.width/2, boat.height);
        boat.drag.x = 20;
        boat.maxVelocity.x = 100;
        add(boat);

        // setup submarines
        submarines = new FlxGroup();
        for (i in 0...5) {
            var submarine: Sprite = new Submarine(createBombAt);
            submarines.add(submarine);
        }
        add(submarines);

        // bombs
        bombs = new FlxGroup();
        for (i in 0...30) {
            var bomb: Sprite = new Sprite(-99, -99, 'assets/images/bomb.png');
            bomb.setAnchor(bomb.width/2, bomb.width/2);
            bomb.kill();
            bombs.add(bomb);
        }
        add(bombs);

        // create the barrels
        barrels = new FlxGroup();
        for (i in 0...30) {
            var barrel: Sprite;
            barrel = new Sprite(-99, -99, 'assets/images/barrel.png');
            barrel.setAnchor(barrel.width/2, 0);
            barrel.kill();
            barrels.add(barrel);
        }
        add(barrels);

        // setup the explosions
        explosions = new FlxGroup();
        for (i in 0...30) {
            var explosion: Sprite;
            explosion = new Sprite(-999, -999, 'assets/images/explosion.png',
                                   128, 128);
            explosion.setAnchor(explosion.width/2, explosion.height/2);

            var animation: FlxAnimationController;
            animation = explosion.animation;
            animation.add("exploding",
                          [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],
                          20, false);

            explosion.kill();
            explosions.add(explosion);
        }
        add(explosions);

        // HUD stuff
        var text: FlxText;
        text = new FlxText(0, 0, 600,
                           "PlayState - Press ESC to comeback to menu.");
        text.size = 30;
        add(text);

        debugText = new FlxText(0, 200, 600,
                                "x: " + boat.x + " y: " + boat.y);
        debugText.size = 30;
        add(debugText);

        // done!!
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

        for (barrel in barrels.members) {
            barrel.destroy();
        }
        barrels.destroy();
        barrels = null;

        for (submarine in submarines.members) {
            submarine.destroy();
        }
        submarines.destroy();
        submarines = null;

        bombs.destroy();
        bombs = null;

        explosions.destroy();
        explosions = null;

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
        //if (FlxG.keyboard.pressed("SPACE")) {
        if (FlxG.keys.justPressed.SPACE) {
            if (barrels.countDead() > 0) {
                var barrel: Sprite = cast(barrels.getFirstDead(), Sprite);
                barrel.velocity.y = 100;
                barrel.setPosition(boat.getX(), boat.getY());
                barrel.revive();
            }
        }

        // update barrels
        for (b in barrels.members) {
            var barrel: Sprite = cast b;
            if (barrel.alive) {
                if (barrel.y > 650) {
                    barrel.kill();
                }
                for (s in submarines.members) {
                    var submarine: Submarine = cast s;
                    if (submarine.alive && barrel.overlaps(submarine)) {
                        createExplosionAt(barrel.getX(), barrel.getY());
                        barrel.kill();
                        submarine.kill();
                    }
                }
            }
        }
        debugText.text = "dead barrels: " + barrels.countDead();

        // boat movement
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

        // update explosions
        for (e in explosions.members) {
            var explosion: Sprite = cast e;
            if (explosion.alive && explosion.animation.finished) {
                explosion.kill();
            }
        }

        // update bombs
        for (b in bombs.members) {
            var bomb: Sprite = cast b;
            if (bomb.alive) {
                if (bomb.getY() - bomb.getAnchor().y < 200) {
                    bomb.kill();
                }
                else if (bomb.overlaps(boat)) {
                    createExplosionAt(bomb.getX(), bomb.getY());
                    bomb.kill();
                }
            }
        }

        // done
		super.update();
	}



    /**
     * Creates a new explosion sprite
     */
    private function createExplosionAt(x: Float, y: Float): Sprite {
        if (explosions.countDead() > 0) {
            var explosion: Sprite = cast explosions.getFirstDead();
            explosion.animation.play("exploding");
            explosion.setPosition(x, y);
            explosion.revive();
            return explosion;
        }
        else {
            return null; // this should never happen...
        }
    }

    /**
     * Creates a new bomb. Submarines throw bombs.
     */
    private function createBombAt(x: Float, y: Float): Sprite {
        if (bombs.countDead() > 0) {
            var bomb: Sprite = cast bombs.getFirstDead();
            bomb.setPosition(x, y);
            bomb.revive();
            bomb.velocity.y = -100;
            return bomb;
        }
        else {
            return null; // this should never happen...
        }
    }
}
