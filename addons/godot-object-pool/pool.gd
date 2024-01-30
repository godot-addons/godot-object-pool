#
# The design/intent of this object pool is to be as immutable as possible from the outside.
# With this in mind, an attempt was made to not expose internals and make it as simple as possible.
# Nothing prevents you from modifying the pooled objects. Only their visibility and their `hidden`
# signaling affect the pool.
#
# See README.md for example usage.
# 
#

signal restock(object)

# Prefix to use when adding objects to the scene (becomes "undefined_1, undefined_2, etc")
var prefix: get = get_prefix

# Pool size on initialization
var size: get = get_size

# Preloaded scene resource to instantiate into objects and pool
var template: get = get_template

# Dictionary of "alive" objects currently in-use.
# Using a dictionary for fast lookup/deletion
var _alive = {} 

# Array of "dead" objects currently available for use
var _dead = []

# Constructor accepting pool size, prefix and scene
# Expands the total pool size by the number of requested objects.
# For example, if passed 2, we will instantiate 2 new objects and add them 
# to the dead pool 👽.
func _init(size_, prefix_, template_):
	size = int(size_)
	prefix = str(prefix_)
	template = template_

	if template == null:
		return

	for i in range(size):
		var o = template.instantiate()
		o.set_name(prefix + "_" + str(i))
		o.visible = false
		o.set_process_mode(4) # 4 = PROCESS_MODE_DISABLED
		o.hidden.connect(self._on_hidden.bind(o))
		_dead.push_back(o)

func get_prefix():
	return prefix
func get_size():
	return size
func get_template():
	return template
func get_alive_count():
	return _alive.size()
func get_dead_count():
	return _dead.size()

# Get the first dead object and make it alive, adding the object to the alive pool and removing from dead pool
func pop_first_dead():
	if _dead.is_empty():
		return null
	
	var o = _dead.pop_back()
	var n = o.get_name()
	_alive[n] = o
	# Turn its processing on and make it visible
	o.set_process_mode(0) # 0 = PROCESS_MODE_INHERIT
	o.visible = true
	o.position = Vector2.ZERO
	return o

# Get the first alive object. Does not affect / change the object's dead value
func get_first_alive():
	if _alive.is_empty():
		return null
	return _alive.values()[0]

# Hide all ALIVE objects and, hence, return them to the dead pool
func hide_all_alive():
	for a in _alive.values():
		a.visible = false # Calls _on_hidden, returns to dead

# Attach all objects managed by the pool to the node passed
func add_to_node(node):
	for a in _alive.values():
		node.add_child(a)
	for o in _dead:
		node.add_child(o)

# Hiding a pool managed object calls this 
func _on_hidden(pooled_object):
	# Remove the killed object from the alive pool
	var n = pooled_object.get_name()
	_alive.erase(n)

	# Add the killed object to the dead pool, now available for use
	_dead.push_back(pooled_object)
	
	# Disable it to save those precious, precious CPU cycles
	pooled_object.set_process_mode(4) # 4 = PROCESS_MODE_DISABLE
	
	# Signal those that are interested of restock events
	restock.emit(pooled_object)
