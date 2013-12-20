package;

import flash.events.Event;
import flash.events.KeyboardEvent;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class WinState extends State {
    private var text: FlxText;

	override public function create(): Void {
		FlxG.cameras.bgColor = 0xff131c1b;
        text = new FlxText(FlxG.width / 2 - 110, FlxG.height/2 - 40, 220,
                           "You WIN!");
        text.alignment = 'center';
        text.color = 0x88ff88;
        text.size = 40;
        add(text);

		super.create();
	}

	override public function destroy(): Void {
        text.destroy();
        text = null;

		super.destroy();
	}

	override public function update(): Void {
        if (FlxG.keyboard.justReleased("SPACE")) {
            switchState(new PlayState());
        }

        #if android
        for (touch in FlxG.touches.list) {
            if (touch.justReleased) {
                switchState(new PlayState());
            }
        }
        #end

		super.update();
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
