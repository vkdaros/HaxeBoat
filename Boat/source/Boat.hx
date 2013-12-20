package;

import flixel.FlxG;
import flixel.util.FlxTimer;

class Boat extends Sprite {

    private var DRAG: Float;
    private var VELOCITY: Float;
    private var MAX_VELOCITY: Float;
    private var ACCELERATION: Float;
    private var TOUCH_MARGIN: Float;
    private var SHOOT_TIME: Float;

    private var canShoot: Bool;
    private var shootTimer: FlxTimer;
    private var shoot: Float->Float->Barrel;



    public function new(seaLevel: Float,
                        throwBarrelStrategy: Float->Float->Barrel) {
        super(FlxG.width / 2, seaLevel, "boat.png");
        shoot = throwBarrelStrategy;

        DRAG = (20 / 960) * FlxG.width;
        VELOCITY = (100 / 640) * FlxG.height;
        MAX_VELOCITY = (100 / 960) * FlxG.width;
        ACCELERATION = (100 / 960) * FlxG.width;
        TOUCH_MARGIN = 0.3 * FlxG.width;
        SHOOT_TIME = 0.3;

        setAnchor(width / 2, 0.9 * height);
        drag.x = DRAG;
        maxVelocity.x = MAX_VELOCITY;
        canShoot = true;
        shootTimer = null;
    }

    override public function destroy(): Void {
        if (shootTimer != null) {
            shootTimer.abort();
            shootTimer = null;
        }
        super.destroy();
    }

    override public function update(): Void {
        acceleration.x = 0;

        if (FlxG.keyboard.pressed("LEFT")) {
            acceleration.x = -ACCELERATION;
        }
        if (FlxG.keyboard.pressed("RIGHT")) {
            acceleration.x = ACCELERATION;
        }
        if (FlxG.keyboard.pressed("SPACE")) {
            if (canShoot) {
                shoot(getX(), getY());
                suspendShootingAbility();
            }
        }

        for (touch in FlxG.touches.list) {
            if (touch.pressed) {
                if (touch.x < TOUCH_MARGIN) {
                    acceleration.x = -ACCELERATION;
                }
                else if (touch.x > FlxG.width - TOUCH_MARGIN) {
                    acceleration.x = ACCELERATION;
                }
                else {
                    if (canShoot) {
                        shoot(getX(), getY());
                        suspendShootingAbility();
                    }
                }
            }
        }

        super.update();
    }

    public function lockWithinArena(): Void {
        if (getX() - getAnchor().x < 0) {
            setX(getAnchor().x);
            acceleration.x = 0;
            velocity.x = 0;
        }
        else if (getX() - getAnchor().x + width > FlxG.width) {
            setX(FlxG.width + getAnchor().x - width);
            acceleration.x = 0;
            velocity.x = 0;
        }
    }




    private function suspendShootingAbility(): Void {
        canShoot = false;
        shootTimer = FlxTimer.start(SHOOT_TIME, function(timer: FlxTimer) {
            canShoot = true;
        });
    }
}
