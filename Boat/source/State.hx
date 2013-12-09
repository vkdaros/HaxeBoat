package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.util.FlxArrayUtil;

/**
 * A basic state ...
 */
class State {
    public var stateManager(null,default): StateManager;
    private var entities: Array<FlxBasic>;
    private var length: Int;

    public function new() {
        stateManager = null;
        entities = new Array<FlxBasic>();
        length = 0;
    }

    public function create(): Void {
    }

    public function destroy(): Void {
        var i: Int = 0;
        while (i < length) {
            var entity: FlxBasic = entities[i++];
            if (entity != null) {
                entity.destroy();
            }
        }
    }

    public function update(): Void {
        var i: Int = 0;
        while (i < length) {
            var entity: FlxBasic = entities[i++];
            if (entity != null && entity.exists && entity.active) {
                entity.update();
            }
        }
    }

    public function draw(): Void {
        var i: Int = 0;
        while (i < length) {
            var entity: FlxBasic = entities[i++];
            if (entity != null && entity.exists && entity.visible) {
                entity.draw();
            }
        }
    }

    #if !FLX_NO_DEBUG
    public function drawDebug(): Void {
        var i: Int = 0;
        while (i < length) {
            var entity: FlxBasic = entities[i++];
            if (entity != null && entity.exists && entity.visible) {
                entity.drawDebug();
            }
        }
    }
    #end

    public function switchState(newState: State): Void {
        if (stateManager != null) {
            stateManager.switchState(newState);
        }
    }

    public function add(entity: FlxBasic): FlxBasic {
        if (entity != null) {
            // got it already
            if (FlxArrayUtil.indexOf(entities, entity) >= 0) {
                return entity;
            }

            // add entity to the list
            if (++length > entities.length) {
                FlxArrayUtil.setLength(entities, entities.length * 2);
            }
            entities[length - 1] = entity;

            // done!
            return entity;
        }
        else {
            return null;
        }
    }
}
