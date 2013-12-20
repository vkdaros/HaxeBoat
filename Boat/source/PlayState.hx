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
import flixel.system.FlxSound;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends State {
    private static var MAX_LEVELS: Int = 10;
    private var seaLevel: Int;

    private var background: FlxSprite;
    private var boat: Boat;
    private var submarines: FlxGroup;
    private var barrels: FlxGroup;
    private var explosions: FlxGroup;
    private var bombs: FlxGroup;
    private var lives: Int;
    private var livesText: FlxText;
    private var level: Int;
    private var levelText: FlxText;

    private var deepExplosionSound: FlxSound;

    private static var BARREL_RESTORETIME: Float = 1.1;
    private static var BARREL_SLOTS: Int = 3;
    private var barrelIcons: Array<Sprite>;
    private var availableBarrels: Int;
    private var barrelRestoreTimer: FlxTimer;

	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create(): Void {
        seaLevel = Math.floor(FlxG.height * 201 / 640);

        // Load sound
        deepExplosionSound = new FlxSound();
        deepExplosionSound.loadEmbedded("assets/sounds/underwater_explosion.ogg");

        // add background
        background = new Sprite(0, 0, "background.png");
        add(background);

        // setup boat
        boat = new Boat(seaLevel, createBarrelAt);
        add(boat);

        // setup group entities
        createSubmarines();
        createBombs();
        createBarrels();
        createExplosions();

        // setup the HUD
        createHUD();

        // done!!
		super.create();
	}

    private function createSubmarines(): Void {
        submarines = new FlxGroup();
        for (i in 0...MAX_LEVELS) {
            var submarine: Submarine = new Submarine(createBombAt);
            submarine.kill();
            submarines.add(submarine);
        }
        add(submarines);
    }

    private function createBombs(): Void {
        bombs = new FlxGroup();
        for (i in 0...30) {
            var bomb: Bomb = new Bomb(seaLevel);
            bomb.kill();
            bombs.add(bomb);
        }
        add(bombs);
    }

    private function createBarrels(): Void {
        barrels = new FlxGroup();
        for (i in 0...30) {
            var barrel: Barrel = new Barrel();
            barrel.kill();
            barrels.add(barrel);
        }
        add(barrels);
    }

    private function createExplosions(): Void {
        explosions = new FlxGroup();
        for (i in 0...30) {
            var explosion: Explosion = new Explosion(deepExplosionSound);
            explosion.kill();
            explosions.add(explosion);
        }
        add(explosions);
    }

    private function createHUD(): Void {
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
        if (barrelRestoreTimer != null) {
            barrelRestoreTimer.abort();
        }
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(): Void {
        // collision: barrels vs submarines
        for (b in barrels.members) {
            var barrel: Barrel = cast b;
            if (barrel.alive) {
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

        // collision: boat vs bombs
        for (b in bombs.members) {
            var bomb: Bomb = cast b;
            if (bomb.alive && bomb.overlaps(boat)) {
                createExplosionAt(bomb.getX(), bomb.getY());
                bomb.kill();
                if (--lives <= 0) {
                    // You Lose.
                    switchState(new LoseState());
                }
            }
        }

        // HUD
        livesText.text = "Lives: " + lives;
        levelText.text = "Level: " + level;

        // done
		super.update();
        boat.lockWithinArena();
	}

    /**
     * Creates a new barrel at the specified position.
     */
    private function createBarrelAt(x: Float, y: Float): Barrel {
        if (barrels.countDead() > 0 && availableBarrels > 0) {
            // grab a barral and revive it
            var barrel: Barrel = cast barrels.getFirstDead();
            barrel.setPosition(x, y);
            barrel.revive();

            // update HUD & timers
            barrelIcons[--availableBarrels].visible = false;
            if (barrelRestoreTimer != null) {
                barrelRestoreTimer.reset();
            }
            else {
                barrelRestoreTimer = FlxTimer.start(BARREL_RESTORETIME, 
                                                    restoreBarrel);
            }

            // done!
            return barrel;
        }
        else {
            return null; // this should never happen...
        }
    }

    /**
     * Creates a new explosion sprite
     */
    private function createExplosionAt(x: Float, y: Float): Explosion {
        if (explosions.countDead() > 0) {
            var explosion: Explosion = cast explosions.getFirstDead();
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
    private function createBombAt(x: Float, y: Float): Bomb {
        if (bombs.countDead() > 0) {
            var bomb: Bomb = cast bombs.getFirstDead();
            bomb.setPosition(x, y);
            bomb.revive();
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
        startSubmarines(level);
    }

    private function restoreBarrel(timer: FlxTimer): Void {
        barrelIcons[availableBarrels++].visible = true;
        barrelRestoreTimer = null;
        if (availableBarrels < BARREL_SLOTS) {
                barrelRestoreTimer = FlxTimer.start(BARREL_RESTORETIME, 
                                                    restoreBarrel);
        }
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
