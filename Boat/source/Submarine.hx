import flixel.FlxG;
import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.FlxTween.TweenOptions;

class Submarine extends Sprite {
    private var tweenToRight: FlxTween;
    private var tweenToLeft: FlxTween;

    public function new(X: Float = 0, Y: Float = 0) {
        super(X, Y, 'assets/images/submarine.png', false, true);
        if (X * Y == 0) {
            x = FlxG.width + this.width;
            y = 400;
        }
        setAnchor(this.width / 2, this.height / 2);
        moveLeft();
    }

    private function moveLeft(): Void {
        this.facing = FlxObject.LEFT;

        var options: TweenOptions;
        options = {
            type: FlxTween.ONESHOT,
            complete: cast function () {
                this.facing = FlxObject.RIGHT;
                this.moveRight();
            }
        };
        // Explanation: linearMotion(object, fromX, fromY, toX, toY,
        //                           durationOrSpeed, useAsDuration, options)
        FlxTween.linearMotion(this, getX(), getY(), width / 2, getY(),
                              5.0, true, options);
    }

    private function moveRight(): Void {
        this.facing = FlxObject.RIGHT;

        var options: TweenOptions;
        options = {
            type: FlxTween.ONESHOT,
            complete: cast function () {
                this.facing = FlxObject.LEFT;
                this.moveLeft();
            }
        };
        // Explanation: linearMotion(object, fromX, fromY, toX, toY,
        //                           durationOrSpeed, useAsDuration, options)
        FlxTween.linearMotion(this, getX(), getY(), FlxG.width - width / 2,
                              getY(), 5.0, true, options);
    }
}
