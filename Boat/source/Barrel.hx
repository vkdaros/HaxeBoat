package;

import flixel.FlxG;

class Barrel extends Sprite {

    public var VELOCITY: Float;
    
    public function new() {
        super(-9999, -9999, "barrel.png");
        VELOCITY = (100 / 640) * FlxG.height;
        setAnchor(width/2, 0);
    }

    override public function update(): Void {
        velocity.y = VELOCITY;
        if (alive) {
            if (getY() - getAnchor().y > FlxG.height) {
                kill();
            }
        }

        super.update();
    }
}
