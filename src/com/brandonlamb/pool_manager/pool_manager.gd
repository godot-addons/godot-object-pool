#
# The design/intent of this pool manager is to be as immutable as possible from the outside.
# With this in mind, I've attempted to not expose many internal to keep things as simple as possible,
# knowing that nothing actually prevents you from modifying the object.
#
# See README.md for example usage
#

# Signal emitted when an object managed by the pool manager is "killed".
# This is called after the pool manager has handled the killed signal from the object.
signal killed(target)

# Prefix to use when adding objects to the scene (becomes "undefined_1, undefined_2, etc")
var prefix setget ,get_prefix

# Pool size on initialization
var size setget ,get_size

# Preloaded scene resource
var scene setget ,get_scene

# Pool of "alive" objects currently in-use
var _alive_pool = {}

# Pool of "dead" objects currently available for use
var _dead_pool = {}

# Constructor accepting pool size, prefix and scene
func _init(size_, prefix_, scene_):
	size = int(size_)
	prefix = str(prefix_)
	scene = scene_
	_init_pool()

# Expand the total pool size by the number of size objects.
# For example, if passed 2, we will instantiate 2 new objects and add to the dead pool.
func _init_pool():
	# If scene has not been set, just return
	if scene == null:
		return

	for i in range(size):
		var s = scene.instance()
		s.set_name(prefix + "_" + str(i))
		s.connect("killed", self, "_on_killed")
		_dead_pool[s.get_name()] = s

func get_prefix(): return prefix
func get_size(): return size
func get_scene():	return scene
func get_alive_size(): return _alive_pool.size()
func get_dead_size(): return _dead_pool.size()

# Get the first dead object and make it alive, adding the object to the alive pool and removing from dead pool
func get_first_dead():
	for i in _dead_pool.keys():
		var o = _dead_pool[i]
		if o.dead:
			var n = o.get_name()
			_alive_pool[n] = o
			_dead_pool.erase(n)
			o.dead = false
			return o

	return null

func get_first_alive():
	for i in _alive_pool.keys():
		var o = _alive_pool[i]
		if !o.dead: return o

	return null

# Convenience method to kill all ALIVE objects managed by the pool manager
func kill_all(): for i in _alive_pool.keys(): _alive_pool[i].kill()

# Attach all objects managed by the pool manager to the node passed
func add_to_node(node):
	for i in _alive_pool.keys():
		node.add_child(_alive_pool[i])

	for i in _dead_pool.keys():
		node.add_child(_dead_pool[i])

# Convenience method to show all objects managed by the pool manager
func show():
	for i in _alive_pool.keys():
		_alive_pool[i].show()

	for i in _dead_pool.keys():
		_dead_pool[i].show()

# Convenience method to hide all objects managed by the pool manager
func hide():
	for i in _alive_pool.keys():
		_alive_pool[i].hide()

	for i in _dead_pool.keys():
		_dead_pool[i].hide()

# Event that all objects should emit so that the pool manager can manage dead/alive pools
func _on_killed(target):
	# Get the name of the target object that was killed
	var name = target.get_name()

	# Remove the killed object from the alive pool
	_alive_pool.erase(name)

	# Add the killed object to the dead pool, now available for use
	_dead_pool[name] = target

	emit_signal("killed", target)
