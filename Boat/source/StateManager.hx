package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.util.FlxArrayUtil;


/**
 * State Manager
 */
class StateManager extends FlxState {

    private var currentState: State;
    private var nextState: State;

    public function new() {
        super();
        currentState = null;
        nextState = null;
    }

    public function switchState(state: State): Void {
        state.stateManager = this;
        nextState = state;
    }

	override public function create(): Void {
		FlxG.cameras.bgColor = 0xff0000ff;
        switchState(new MenuState());
		super.create();
	}

	override public function destroy(): Void {
        if (currentState != null) {
            currentState.destroy();
            currentState = null;
        }

		super.destroy();
	}

	override public function update(): Void	{
        if (currentState != null) {
            currentState.update();
        }

        if (nextState != null) {
            if (currentState != null) {
                currentState.destroy();
            }
            nextState.create();
            currentState = nextState;
            nextState = null;
        }

		super.update();
	}

	override public function draw(): Void {
        if (currentState != null && nextState == null) {
            currentState.draw();
        }

		super.draw();
	}

    #if !FLX_NO_DEBUG
	override public function drawDebug(): Void	{
        if (currentState != null && nextState == null) {
            currentState.drawDebug();
        }

		super.drawDebug();
	}
    #end
}
