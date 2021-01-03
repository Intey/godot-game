extends Node2D

onready var craftHud = $HUD/CraftHUD
onready var ammoHud = $HUD/Ammo

func _ready():
    connect_craft()
    connect_clip()
    var gen = InitialGenerator.new(self, $LeftCamp, $RightCamp)
    gen.generate()
    
func connect_craft():
    var p = $Player
    assert(p != null)
    craftHud.init(p)
    craftHud.hide()
    assert($Player/Inventory.connect('update', craftHud, "update_reciepes_view") == 0)

    assert(craftHud.connect('craft', $Player, 'craft') == OK)
    assert($Player.connect('build', self, 'create_building') == OK)
    assert($Player.connect("craft_on", craftHud, "show") == OK)
    assert($Player.connect("craft_off", craftHud, "hide") == OK)
    
func connect_clip():
    var clip = $Player/RangeWeapon/WeaponClip
    var mv = clip.max_value
    var v = clip.value
    ammoHud.upload(v, mv)
    clip.connect("clip_uploaded", ammoHud, "upload")
    clip.connect("clip_value_change", ammoHud, "set_value")    
    clip.connect("clip_reload_done", ammoHud, "reload_done")
    clip.connect("clip_reload_start", ammoHud, "start_reload")
    
    
func create_building(reciepe, position):
    var scene_path = reciepe.scene
    var BuildScene = load(scene_path)
    var instance = BuildScene.instance()
    instance.position = position
    add_child(instance)
