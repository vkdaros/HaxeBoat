package;

import flixel.FlxG;

class Bomb extends Sprite {

    public var VELOCITY: Float;
    public var seaLevel: Float;
    
    public function new(seaLevel: Float) {
        super(-9999, -9999, "bomb.png");
        VELOCITY = (-100 / 640) * FlxG.height;
        setAnchor(width/2, height/2);
        this.seaLevel = seaLevel;
    }

    override public function update(): Void {
        velocity.y = VELOCITY;
        if (alive) {
            if (getY() - getAnchor().y <= seaLevel) {
                kill();
            }
        }

        super.update();
    }
}
