extends Area2D

var velocity : Vector2 = Vector2.ZERO : set = _set_velocity
	
var state = null 

func _set_velocity(v):
	velocity = v
	
	# After the timer timeouts, call hide for the bullet.
	# Also hiding on a collision would work.
	# Hiding the bullet automatically returns it to the pool.
	$DropTimer.timeout.connect( func (): self.hide() )
	$DropTimer.start()

func _process(delta):
	# Makes the bullet fly.
	self.position+=velocity*delta
