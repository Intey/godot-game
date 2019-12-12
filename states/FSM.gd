extends Node
class_name FSM

export var debug = false

#warning-ignore:unused_class_variable
var current_state setget , __get_current_state

var __states_stack := []

var states_map: Dictionary

const PREVIOUS_STATE = "previous"

func init(states: Dictionary, initial_state):
    if get_parent().get('debug') != null:
        self.debug = get_parent().debug or self.debug
        
    states_map = states
    assert(initial_state != null)
    states_map[initial_state].on_enter()
    __states_stack.push_back(initial_state)
        
func change_state(state, soft_transit=false):
    var from_state = __get_current_state()
    if state == null: # state not changes
        return
    if soft_transit:
        if not self.states_map[from_state].soft_transit(state):
            return
            
    elif state == PREVIOUS_STATE:
        __states_stack.pop_front()
    else:
        __states_stack.push_front(state)
    # state is changed

    if from_state != state:
        states_map[from_state].on_exit()
        states_map[state].on_enter()        
        if self.debug:
            print_debug("change state from ", from_state, " to ", __get_current_state())
    
    
func _process(delta):
    var state = states_map[__get_current_state()]
    # TODO: when states chages, handle chains of changes in one time
    var new_state = state.update(delta)
    if new_state == null:
        return
    change_state(new_state)
    
func _physics_process(delta):
    var state = states_map[__get_current_state()]
    state.update_physics(delta)
    
func __get_current_state():
    return __states_stack[0]