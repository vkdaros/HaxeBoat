package;

import flash.events.Event;
import flash.events.KeyboardEvent;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxArrayUtil;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.animation.FlxAnimationController;
import flixel.system.FlxSound;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends State {
    private static var MAX_LEVELS: Int = 10;
    private var seaLevel: Int;

    private var background: FlxSprite;
    private var boat: Sprite;
    private var submarines: FlxGroup;
    private var barrels: FlxGroup;
    private var explosions: FlxGroup;
    private var bombs: FlxGroup;
    private var lives: Int;
    private var livesText: FlxText;
    private var level: Int;
    private var levelText: FlxText;

    private var deepExplosionSound: FlxSound;

    private static var BOAT_SHOOTTIME: Float = 0.3;
    private var BOAT_MAX_VELOCITY: Float;
    private var BOAT_ACCELERATION: Float;
    private var BOAT_DRAG: Float;
    private var boatCanShoot: Bool;
    private var boatShootTimer: FlxTimer;

    private static var BARREL_RESTORETIME: Float = 1.1;
    private static var BARREL_SLOTS: Int = 3;
    private var BARREL_VELOCITY: Float;
    private var BOMB_VELOCITY: Float;
    private var barrelIcons: Array<Sprite>;
    private var availableBarrels: Int;
    private var barrelRestoreTimer: FlxTimer;

	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create(): Void {
        seaLevel = Math.floor(FlxG.height * 201 / 640);
        BOAT_MAX_VELOCITY = (100 / 960) * FlxG.width;
        BOAT_ACCELERATION = (100 / 960) * FlxG.width;
        BOAT_DRAG = (20 / 960) * FlxG.width;
        BARREL_VELOCITY = (100 / 640) * FlxG.height;
        BOMB_VELOCITY = (-100 / 640) * FlxG.height;

		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;

        // Load sound
        deepExplosionSound = new FlxSound();
        deepExplosionSound.loadEmbedded("assets/sounds/underwater_explosion.ogg");

        // add background
        background = new Sprite(0, 0, "background.png");
        add(background);

        // setup boat
        boat = new Sprite(FlxG.width / 2, seaLevel, "boat.png");
        boat.setAnchor(boat.width / 2, 0.9 * boat.height);
        boat.drag.x = BOAT_DRAG;
        boat.maxVelocity.x = BOAT_MAX_VELOCITY;
        add(boat);
        boatCanShoot = true;
        boatShootTimer = null;

        // setup submarines
        createSubmarines();

        // bombs
        bombs = new FlxGroup();
        for (i in 0...30) {
            var bomb: Sprite = new Sprite(0, 0, "bomb.png");
            bomb.setAnchor(bomb.width / 2, bomb.width / 2);
            bomb.kill();
            bombs.add(bomb);
        }
        add(bombs);

        // create the barrels
        barrels = new FlxGroup();
        for (i in 0...30) {
            var barrel: Sprite;
            barrel = new Sprite(0, 0, "barrel.png");
            barrel.setAnchor(barrel.width / 2, 0);
            barrel.kill();
            barrels.add(barrel);
        }
        add(barrels);

        // setup the explosions
        explosions = new FlxGroup();
        for (i in 0...30) {
            var explosion: Sprite;
            explosion = new Sprite(0, 0, "explosion.png", 128, 128);
            explosion.setAnchor(explosion.width / 2, explosion.height / 2);

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
        lives = 2;
        livesText = new FlxText(10, 10, 180, "Lives: " + lives, 20);
        add(livesText);

        level = 0;
        levelText = new FlxText(FlxG.width - 180, 10, 170, "Level: " + level,
                                20);
        levelText.alignment = "right";
        add(levelText);
        levelUp();

        barrelIcons = new Array<Sprite>();
        FlxArrayUtil.setLength(barrelIcons, BARREL_SLOTS);
        for (i in 0...BARREL_SLOTS) {
            var x: Float = FlxG.width / 2 + (i - BARREL_SLOTS / 2) * 30;
            var icon: Sprite = new Sprite(x, 10, "barrel.png");
            icon.setAnchor(icon.width / 2, -icon.height / 2);
            icon.angle = -45;
            barrelIcons[i] = icon;
            add(icon);
        }
        availableBarrels = BARREL_SLOTS;
        barrelRestoreTimer = null;

        // one!!
		super.create();
	}

    private function createSubmarines(): Void {
        submarines = new FlxGroup();
        for (i in 0...MAX_LEVELS) {
            var submarine: Sprite = new Submarine(createBombAt);
            submarines.add(submarine);
            submarine.kill();
        }
        add(submarines);
    }

    // Revives n submarines to start a new match.
    private function startSubmarines(n: Int): Void {
        if (n < 0) {
            // Error!
            n = 0;
        }
        for (i in 0...n) {
            var submarine: Submarine = cast(submarines.getFirstDead(),
                                            Submarine);
            submarine.revive();
            submarine.resetAll();
        }
    }

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage
     * collection.
	 */
	override public function destroy(): Void {
        if (boatShootTimer != null) {
            boatShootTimer.abort();
        }
        if (barrelRestoreTimer != null) {
            barrelRestoreTimer.abort();
        }
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(): Void {
        var speed: Float = 5;
        var dt: Float = FlxG.elapsed;

        // boat movement
        handleBoatMovement();

        // update barrels
        for (b in barrels.members) {
            var barrel: Sprite = cast b;
            if (barrel.alive) {
                if (barrel.y > FlxG.height + barrel.height) {
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
                if (submarines.countLiving() <= 0) {
                    levelUp();
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
                if (bomb.getY() - bomb.getAnchor().y < seaLevel) {
                    bomb.kill();
                }
                else if (bomb.overlaps(boat)) {
                    createExplosionAt(bomb.getX(), bomb.getY());
                    bomb.kill();
                    lives--;
                    if (lives <= 0) {
                        // Call end game.
                        switchState(new LoseState());
                    }
                }
            }
        }

        livesText.text = "Lives: " + lives;

        // done
		super.update();
        lockBoatWithinArena();
	}

    private function throwBarrel(x: Float, y: Float): Void {
        if (barrels.countDead() > 0 && boatCanShoot && availableBarrels > 0) {
            var barrel: Sprite = cast(barrels.getFirstDead(), Sprite);
            barrel.velocity.y = BARREL_VELOCITY;
            barrel.setPosition(x, y);
            barrel.revive();
            disableBoatShoot();
            barrelIcons[--availableBarrels].visible = false;
            if (barrelRestoreTimer != null) {
                barrelRestoreTimer.reset();
            }
            else {
                barrelRestoreTimer = FlxTimer.start(BARREL_RESTORETIME, 
                                                    restoreBarrel);
            }
        }
    }

    private function restoreBarrel(timer: FlxTimer): Void {
        barrelIcons[availableBarrels++].visible = true;
        barrelRestoreTimer = null;
        if (availableBarrels < BARREL_SLOTS) {
                barrelRestoreTimer = FlxTimer.start(BARREL_RESTORETIME, 
                                                    restoreBarrel);
        }
    }

    private function handleBoatMovement(): Void {
        boat.acceleration.x = 0;

        if (FlxG.keyboard.pressed("LEFT")) {
            boat.acceleration.x = -BOAT_ACCELERATION;
        }
        if (FlxG.keyboard.pressed("RIGHT")) {
            boat.acceleration.x = BOAT_ACCELERATION;
        }
        if (FlxG.keyboard.pressed("SPACE")) {
            throwBarrel(boat.getX(), boat.getY());
        }

        for (touch in FlxG.touches.list) {
            if (touch.pressed) {
                var margin: Float;
                margin = 0.3;
                if (touch.x < FlxG.width * margin) {
                    boat.acceleration.x = -BOAT_ACCELERATION;
                }
                else if (touch.x > FlxG.width * (1 - margin)) {
                    boat.acceleration.x = BOAT_ACCELERATION;
                }
                else {
                    throwBarrel(boat.getX(), boat.getY());
                }
            }
        }
    }

    private function lockBoatWithinArena(): Void {
        if (boat.getX() - boat.getAnchor().x < 0) {
            boat.setX(boat.getAnchor().x);
            boat.acceleration.x = 0;
            boat.velocity.x = 0;
        }
        else if (boat.getX() - boat.getAnchor().x + boat.width > FlxG.width) {
            boat.setX(FlxG.width + boat.getAnchor().x - boat.width);
            boat.acceleration.x = 0;
            boat.velocity.x = 0;
        }
    }

    /**
     * Creates a new explosion sprite
     */
    private function createExplosionAt(x: Float, y: Float): Sprite {
        deepExplosionSound.play();
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
            bomb.velocity.y = BOMB_VELOCITY;
            return bomb;
        }
        else {
            return null; // this should never happen...
        }
    }

    private function levelUp(): Void {
        if (++level > MAX_LEVELS) {
            // Winner.
            switchState(new WinState());
        }
        lives++;
        levelText.text = "Level: " + level;
        startSubmarines(level);
    }

    private function enableBoatShoot(timer: FlxTimer): Void {
        boatCanShoot = true;
    }

    private function disableBoatShoot(): Void {
        boatCanShoot = false;
        boatShootTimer = FlxTimer.start(BOAT_SHOOTTIME, enableBoatShoot);
    }

    override public function onBackButton(event: KeyboardEvent): Void {
        // Get ESCAPE from keyboard or BACK from android.
        if (event.keyCode == 27) {
            switchState(new MenuState());
            #if android
            event.stopImmediatePropagation();
            #end
        }
    }
}
