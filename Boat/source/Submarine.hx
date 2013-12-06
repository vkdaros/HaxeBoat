import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxTimer;

class Submarine extends Sprite {
    private var speed: Int;
    private var tweenToRight: FlxTween;
    private var tweenToLeft: FlxTween;
    private var shotTimer: FlxTimer;
    private var shoot: Float->Float->Sprite;

    public function new(?shootCallback: Float->Float->Sprite, X: Float = 0,
                        Y: Float = 0) {
        super(X, Y, 'assets/images/submarine.png', false, true);
        if (X == 0 && Y == 0) {
            var foo: Float = FlxRandom.sign();
            x = FlxG.width / 2 + foo * (FlxG.width / 2 + this.width);
            y = FlxRandom.intRanged(240, FlxG.height - 30);
            speed = FlxRandom.intRanged(50, 150);
        }
        setAnchor(this.width / 2, this.height / 2);
        if (x < 0) {
            moveRight();
        }
        else {
            moveLeft();
        }

        shoot = shootCallback;
        var interval: Float = FlxRandom.floatRanged(3.0, 5.0);
        shotTimer = FlxTimer.start(interval, timerCallback);
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
        FlxTween.linearMotion(this, getX(), getY(), getAnchor().x, getY(),
                              speed, false, options);
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
        FlxTween.linearMotion(this, getX(), getY(), FlxG.width - getAnchor().x,
                              getY(), speed, false, options);
    }

    private function timerCallback(timer: FlxTimer): Void {
        if (shoot != null && this.alive) {
            shoot(getX(), getY());
        }
        shotTimer.reset();
    }
}
