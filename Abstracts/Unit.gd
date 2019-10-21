extends Node
class_name Unit

var health := Value.new()
var alive := true
var on_dead: FuncRef


func _init(on_dead_ref: FuncRef):
    self.on_dead = on_dead_ref


# TODO: reduce damage with defence value?
func take_damage(dmg: int):
    if not alive:
        return
    self.health.value -= dmg
    if self.health.value == 0:
        alive = false
    if not alive:
        self.on_dead.call_func()