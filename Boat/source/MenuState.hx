package;

import flash.Lib;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.system.System;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends State {
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create(): Void {
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;

        #if mobile
        var str: String = "Tap to start the game.";
        #else
        var str: String = "Press SPACE to start the game.";
        #end

        str += "\nW: " + Lib.current.stage.stageWidth +
               " H: " + Lib.current.stage.stageHeight;
        var text: FlxText = new FlxText(20, 20, 600, str);
        text.color = 0xFFFFFF;
        text.size = 30;
        add(text);

		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy(): Void {
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(): Void	{
        if (FlxG.keyboard.justReleased("SPACE")) {
            switchState(new PlayState());
        }

        #if android
        for (touch in FlxG.touches.list) {
            if (touch.justPressed) {
                switchState(new PlayState());
            }
        }
        #end

		super.update();
	}

    override public function onBackButton(event: KeyboardEvent): Void {
        // Get ESCAPE from keyboard or BACK from android.
        if (event.keyCode == 27) {
            #if android
            System.exit(0);
            event.stopImmediatePropagation();
            #end
        }
    }
}
