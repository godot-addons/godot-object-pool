# godot-object pool

An object pool for Godot.

# Usage example:

PlayerController.gd

```gdscript
const Pool = preload("res://addons/godot-object-pool/pool.gd")
const GreenBullet = preload("res://com/example/bullets/green_bullet.tscn")

const BULLET_POOL_SIZE = 60
const BULLET_POOL_PREFIX = "bullet"

onready var bullets = get_node("bullets")
onready var player = get_node("player")
onready var pool = Pool.new(BULLET_POOL_SIZE, BULLET_POOL_PREFIX, GreenBullet)

func _ready():
	# Attach pool of objects to the bullets node
	pool.add_to_node(bullets)

	# Attach the "on_pool_killed" method to the pool's "killed" signal
	pool.connect("killed", self, "_on_pool_killed")

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_select"):
		var bullet = pool.get_first_dead()
		if bullet: bullet.shoot(player.get_node("weapon_position"), player)

func _on_pool_killed(target):
	target.hide()
	print("Currently %d objects alive in pool" % pool.get_alive_count())
	print("Currently %d objects dead in pool" % pool.get_dead_count())
```
