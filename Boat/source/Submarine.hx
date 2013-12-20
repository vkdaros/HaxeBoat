import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxTimer;

class Submarine extends Sprite {
    private var seaLevel: Int;

    private var MIN_VELOCITY: Int;
    private var MAX_VELOCITY: Int;

    private var speed: Int;
    private var tween: FlxTween;
    private var shotTimer: FlxTimer;
    private var shoot: Float->Float->Sprite;

    public function new(?shootCallback: Float->Float->Sprite, X: Float = 0,
                        Y: Float = 0) {
        super(X, Y, "submarine.png", false, true);
        seaLevel = Math.floor(FlxG.height * 201 / 640);
        MIN_VELOCITY = Math.floor(FlxG.width * 50 / 960);
        MAX_VELOCITY = Math.floor(FlxG.width * 150 / 960);

        setAnchor(this.width / 2, this.height / 2);
        if (X == 0 && Y == 0) {
            resetPosition();
        }

        shoot = shootCallback;
        resetTimer();
    }

    private function moveLeft(): Void {
        this.facing = FlxObject.LEFT;

        var options: TweenOptions;
        options = {
            type: FlxTween.ONESHOT,
            complete: cast moveRight
        };
        // Explanation: linearMotion(object, fromX, fromY, toX, toY,
        //                           durationOrSpeed, useAsDuration, options)
        tween = FlxTween.linearMotion(this, getX(), getY(), getAnchor().x,
                                      getY(), speed, false, options);
    }

    private function moveRight(): Void {
        this.facing = FlxObject.RIGHT;

        var options: TweenOptions;
        options = {
            type: FlxTween.ONESHOT,
            complete: cast moveLeft
        };
        // Explanation: linearMotion(object, fromX, fromY, toX, toY,
        //                           durationOrSpeed, useAsDuration, options)
        tween = FlxTween.linearMotion(this, getX(), getY(),
                                      FlxG.width - getAnchor().x, getY(), speed,
                                      false, options);
    }

    private function timerCallback(timer: FlxTimer): Void {
        if (shoot != null && this.alive) {
            shoot(getX(), getY());
        }
        resetTimer(true);
    }

    override public function kill(): Void {
        tween.cancel();
        if (shotTimer != null) {
            shotTimer.abort();
        }
        super.kill();
    }

    public function resetPosition(): Void {
        var signal: Float = FlxRandom.sign();
        x = FlxG.width / 2 + signal * (FlxG.width / 2 + this.width);
        y = FlxRandom.intRanged(seaLevel + 2 * Math.floor(height),
                                FlxG.height - Math.floor(height));
        speed = FlxRandom.intRanged(MIN_VELOCITY, MAX_VELOCITY);
        if (x < 0) {
            moveRight();
        }
        else {
            moveLeft();
        }
    }

    public function resetTimer(keepCurrentTime: Bool = false): Void {
        var time: Float;

        if (shotTimer != null && keepCurrentTime) {
            time = shotTimer.time;
        }
        else {
            time = FlxRandom.floatRanged(3.0, 5.0);
        }

        shotTimer = FlxTimer.start(time, timerCallback);
    }

    public function resetAll(): Void {
        resetPosition();
        resetTimer();
    }

    override public function destroy(): Void {
        if (shotTimer != null) {
            shotTimer.abort();
        }
    }
}
