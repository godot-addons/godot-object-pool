extends Area2D

@export var bullet_speed : float = 250

func shoot(bullet, towards):
	if bullet==null:
		return #ran out of pooled bullets?
	
	bullet.global_position = self.global_position 
	# Setting the velocity also sets the bullet to self destruct (see bullet.gd)
	bullet.velocity = self.position.direction_to(towards)*bullet_speed

