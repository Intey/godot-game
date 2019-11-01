extends KinematicBody2D

var BB = preload("res://Utility/Blackboard.gd").new()


export var detection_radius: int
export var speed: float
export var damage := 10
# FIXME: not react on change from GUI. Making copy on state.init(self)?
export var shoot_range: int = 250 
export var accuracy := 0.2

var unit: Unit

# State machinary
enum {
    PREVIOUS = Machinary.PREVIOUS_STATE,
    ROAMING,
    PURSUIT,
    ATTACK,
    FLEEING,
}


# Debug colors for state visibility
var colors = {
    ROAMING: Color(0, 1, 0),
    PURSUIT: Color(1, 0, 0),
    FLEEING: Color(0, 0, 1),
    ATTACK: Color(1, 1, 0),
}


# ============ State machinary
onready var states_map = {
    ROAMING: $Machinary/Roaming.init(self),
    PURSUIT: $Machinary/Pursuiting.init(self),
    ATTACK: $Machinary/Attack.init(self),
}

func _change_state(state):
    $Machinary.change_state(state)
# ============ END State machinary    
    
    
func _ready():
    $Machinary.init(states_map, ROAMING)
    $DetectionArea/Area.shape.radius = detection_radius
    self.unit = Unit.new(100, funcref(self, "queue_free"))
    $RangeWeapon.init(self)
    
    
func move(delta, direction: Vector2):
    """
    Move self to direction with self.speed
    Interface for state. All logic is in state.
    """
    var collision = move_and_collide(direction.normalized() * speed * delta)
    
     
func _physics_process(delta):
    update() # for redrawing
    
    
func _draw():
    $ColorRect.color = colors.get($Machinary.current_state, Color(1, 1, 1))


func _on_DetectionArea_body_entered(body):
    if body.name == 'Player':
        BB.write('player', body)


func _on_DetectionArea_body_exited(body):
    if body.name == 'Player':
        BB.erase('player')
        
func fire(delta):
    var player: Node2D = BB.get('player')
    var target = accuracy_fix(player.global_position, self.accuracy)
    $RangeWeapon.fire(delta, target)
    player.hit(self.damage)
    
    
func accuracy_fix(vector: Vector2, accuracy: float = 1.0) -> Vector2:
    accuracy = 1.0 - accuracy
    vector.x += rand_range(-accuracy, accuracy)
    vector.y += rand_range(-accuracy, accuracy)
    return vector
    
func hit(dmg: int = 20):
    self.unit.take_damage(dmg)