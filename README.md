# godot-object pool

An object pool for Godot 4.

Object pooling in Godot reduces lag by reusing objects instead of constantly
creating and deleting them. It's great for games with lots of temporary objects
like bullets or enemies. You avoid the performance hit from frequent memory
allocation, making your game run smoother.

The pooled objects are initially hidden and their processing is disabled. 
When they are popped back to the game, they are made visible and their position
is reset. When they are hidden, they return to the pool. Handy.

# Usage example:

```gdscript
const Pool = preload("res://addons/godot-object-pool/pool.gd")
const Bullet = preload("res://example/bullet.tscn")

const BULLET_POOL_SIZE = 60
const BULLET_POOL_PREFIX = "bullet"

@onready var pool = Pool.new(BULLET_POOL_SIZE, BULLET_POOL_PREFIX, Bullet)

func _ready():
	# Attach pooled objects to the game as children of the root node.
	pool.add_to_node(self)
	
	# Called whenever bullet returns to the pool.
	pool.restock.connect(_on_pool_restock)
	
	# Print initial status of the pool.
	_on_pool_restock()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and\
	   event.button_index == MOUSE_BUTTON_LEFT:
			# Take a bullet from the bool and give it to the player to shoot.
			$Player.shoot(pool.pop_first_dead(), event.position)
			
			# After some time the bullet is hidden and it returns to the pool.
			#  (see bullet.gd) for details.

func _on_pool_restock():
	print("Currently %d objects alive in the pool" % pool.get_alive_count())
	print("Currently %d objects dead in the pool" % pool.get_dead_count())
```

See the complete example for more details.
