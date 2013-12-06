import flixel.FlxSprite;
import flixel.util.FlxPoint;

class Sprite extends FlxSprite {
    private var anchor: FlxPoint;

    public function new(X: Float = 0, Y: Float = 0, ?image: Dynamic,
                        animated: Bool = false, reversible: Bool = false,
                        frameWidth: Int = 0, frameHeight: Int = 0,
                        anchorX: Float = 0, anchorY: Float = 0) {
        super(X, Y);

        //loadGraphic(image, animated, reversible, width, height)
        loadGraphic(image, animated, reversible, frameWidth, frameHeight);

        anchor = new FlxPoint(anchorX, anchorY);
        setPosition(X, Y);
    }

    override public function setPosition(X: Float = 0, Y: Float = 0): Void {
        x = X - anchor.x;
        y = Y - anchor.y;
    }

    public function getPosition(): FlxPoint {
        return new FlxPoint(x + anchor.x, y + anchor.y);
    }

    public function setX(X: Float): Float {
        return (x = X - anchor.x);
    }

    public function getX(): Float {
        return x + anchor.x;
    }

    public function setY(Y: Float): Float {
        return (y = Y - anchor.y);
    }

    public function getY(): Float {
        return y + anchor.y;
    }

    public function setAnchor(X: Float = 0, Y: Float = 0): Void {
        anchor = new FlxPoint(X, Y);
        setPosition(x, y);
    }

    public function getAnchor(): FlxPoint {
        return anchor;
    }
}
