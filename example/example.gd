extends Node2D

const Pool = preload("res://addons/godot-object-pool/pool.gd")
const Bullet = preload("res://example/bullet.tscn")

const BULLET_POOL_SIZE = 60
const BULLET_POOL_PREFIX = "bullet"

@onready var pool = Pool.new(BULLET_POOL_SIZE, BULLET_POOL_PREFIX, Bullet)

func _ready():
	# Attach pooled objects to the game as children of the root node.
	pool.add_to_node(self)
	
	# Called whenever bullet returns to the pool
	pool.restock.connect(_on_pool_restock)
	
	# Print initial status of the pool
	_on_pool_restock(null)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and\
	   event.button_index == MOUSE_BUTTON_LEFT:
			# Take a bullet from the bool and give it to the player to shoot
			# Taking it from the pool makes it visible
			$Player.shoot(pool.pop_first_dead(), event.position)
			
			# If after some time the bullet is hidden, it returns to the bool
			#  (see bullet.gd) for details.

func _on_pool_restock(object):
	if (object!=null): print("Bullet hidden at "+str(object.position))
	print("Currently %d objects alive in the pool" % pool.get_alive_count())
	print("Currently %d objects dead in the pool" % pool.get_dead_count())
