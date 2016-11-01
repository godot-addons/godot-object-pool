# godot-pool-manager

An object pool for Godot.

# Usage example:

PlayerController.gd

```gdscript
const Pool = preload("res://com/brandonlamb/pool/pool.gd")
const GreenBullet = preload("res://com/example/bullets/green_bullet.tscn")

const BULLET_POOL_SIZE = 60
const BULLET_POOL_PREFIX = "bullet"

onready var _bullets = get_node("bullets")
onready var _player = get_node("player")
onready var _pm = PoolManager.new(BULLET_POOL_SIZE, BULLET_POOL_PREFIX, GreenBullet)

func _ready():
	#Attach pool of objects to the bullets node
	_pm.add_to_node(bullets)

	#Attach the "on_pm_killed" method to the pool manager's "killed" signal
	_pm.connect("killed", self, "_on_pm_killed")

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_select"):
		var bullet = _pm.get_first_dead()
		if bullet: bullet.shoot(_player.get_node("weapon_position"), _player)

func _on_pm_killed(target):
	target.hide()
```
